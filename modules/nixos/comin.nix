# Pull-based deployment: the host polls this repo and switches itself, so a
# push to the tracked branch is the deploy. Hosts that import this must never
# also be deployed by hand, or comin will fight the manual generation on its
# next poll.
{ inputs, ... }:
{
  flake.modules.nixos.comin =
    { config, lib, ... }:
    let
      cfg = config.ryk.comin;
    in
    {
      imports = [ inputs.comin.nixosModules.comin ];

      options.ryk.comin.branch = lib.mkOption {
        type = lib.types.str;
        default = "master";
        description = ''
          Remote branch comin deploys from. Override this for a pilot branch;
          remove the override to promote the host to master.
        '';
      };

      options.ryk.comin.url = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          Repository this host polls for its own configuration. Required: this
          module used to default to the dotfiles repository, which was correct
          for exactly one host and silently wrong for every other consumer.
        '';
      };

      options.ryk.comin.deployKeyPath = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = ''
          Read-only SSH deploy key for a private configuration repository. Null
          means the repository is public and comin clones anonymously. When set,
          `url` must be in `git@host:owner/repo.git` form, because an access
          token and a deploy key are mutually exclusive upstream and an HTTPS
          URL will not use the key.
        '';
      };

      options.ryk.comin.knownHostsPath = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = ''
          `known_hosts` file used to verify the Git server's SSH host key.
          Required alongside `deployKeyPath`: comin verifies the host key and
          has no trust-on-first-use fallback, so an SSH remote without this
          fails every poll with
          `ssh: handshake failed: knownhosts: key is unknown`.
        '';
      };

      options.ryk.comin.manualHosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "jezrien"
          "taln"
        ];
        description = ''
          Hosts that are deployed by hand and must never poll. Importing this
          module on one of them would let a push overwrite a workstation's
          running generation, so it fails evaluation instead.
        '';
      };

      config.assertions = [
        {
          assertion = !(lib.elem config.networking.hostName cfg.manualHosts);
          message = ''
            ${config.networking.hostName} is deployed by hand: remove the comin
            module from its module list, or drop it from `ryk.comin.manualHosts`
            if it really should pull from git.
          '';
        }
        {
          assertion = cfg.url != null;
          message = ''
            ${config.networking.hostName} imports the comin module but sets no
            `ryk.comin.url`. Say which repository this host polls.
          '';
        }
        {
          assertion = cfg.deployKeyPath == null || !(lib.hasPrefix "http" cfg.url);
          message = ''
            ${config.networking.hostName} sets `ryk.comin.deployKeyPath` with an
            HTTPS `ryk.comin.url`. A deploy key is only used for SSH remotes;
            use the `git@host:owner/repo.git` form.
          '';
        }
        {
          assertion = cfg.deployKeyPath == null || cfg.knownHostsPath != null;
          message = ''
            ${config.networking.hostName} sets `ryk.comin.deployKeyPath` without
            `ryk.comin.knownHostsPath`. comin verifies the Git server's SSH host
            key and has no trust-on-first-use fallback, so every poll would fail
            with `ssh: handshake failed: knownhosts: key is unknown`.
          '';
        }
      ];

      config.services.comin = {
        enable = true;

        remotes = [
          (
            {
              name = "origin";
              url = cfg.url;
              # `main` is comin's role name for the production branch, not a
              # branch named "main". The per-host testing branch keeps comin's
              # default name, `testing-<hostname>`, and runs as `test`.
              branches.main.name = cfg.branch;
              poller.period = 60;
            }
            // lib.optionalAttrs (cfg.deployKeyPath != null) {
              auth.ssh_deploy_key_path = cfg.deployKeyPath;
              auth.ssh_known_hosts_path = cfg.knownHostsPath;
            }
          )
        ];
      };
    };
}
