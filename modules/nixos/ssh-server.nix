{ self, ... }:
{
  flake.modules.nixos.ssh-server =
    { username, ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      users.users.${username}.openssh.authorizedKeys.keys = builtins.attrValues self.lib.dustySshKeys;
    };
}
