# `_dusty-ssh-keys.nix` used to be imported by relative path, including from
# other repos via `dotfiles.outPath + "/modules/misc/..."`. That is a contract
# nobody declared and it broke the moment the file moved. Expose it as a real
# flake output instead; dotfiles re-exports this as `dotfiles.lib.dustySshKeys`
# so callers that only have a dotfiles input keep working.
{
  flake.lib.dustySshKeys = import ./_dusty-ssh-keys.nix;
}
