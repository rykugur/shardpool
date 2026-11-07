# `_dusty-ssh-keys.nix` used to be imported by relative path, including from
# other repos via `dotfiles.outPath + "/modules/misc/..."`. That is a contract
# nobody declared and it broke the moment the file moved. Expose it as a real
# flake output instead; dotfiles re-exports this as `dotfiles.lib.dustySshKeys`
# so callers that only have a dotfiles input keep working.
{
  flake.lib.dustySshKeys = import ./_dusty-ssh-keys.nix;

  # The editor snippet directory moved here with the Helix chain, but dotfiles'
  # zed-editor module wants it too and is staying put. Expose it rather than
  # leaving a second copy behind or letting a relative path reach across repos.
  flake.lib.editorSnippets = ../configs/snippets;
}
