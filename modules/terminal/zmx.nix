{ inputs, self, ... }:
{
  flake.modules.homeManager.zmx =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.homeManager.starshipFormat ];

      # `zsm` came from a dotfiles overlay. Taking it straight from the input
      # removes the overlay, and with it the need for any consumer of this
      # module to apply one.
      home.packages =
        [ pkgs.zmx ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          inputs.zmx-session-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

      programs.starship = lib.mkIf config.programs.starship.enable {
        prependFormat = lib.mkBefore [ "\${env_var.ZMX_SESSION}" ];
        settings.env_var.ZMX_SESSION = {
          symbol = " ";
          format = "[$symbol$env_value]($style) ";
          description = "zmx session name";
          style = "bold magenta";
        };
      };

      programs.nushell = lib.mkIf config.programs.nushell.enable {
        extraConfig = ''
          source ${
            pkgs.runCommand "zmx-nushell-completions.nu" { nativeBuildInputs = [ pkgs.zmx ]; } ''
              export HOME="$TMPDIR"
              zmx completions nu > "$out"
            ''
          }
        '';
      };
    };
}
