# Shardpool

Shared NixOS and home-manager modules for Dusty's headless hosts: comin,
impermanence, btrfs-rollback, guest-access, ssh-server, meta, nix-defaults and
the Helix chain. Public on GitHub because `dotfiles` imports it.

Consumers: `dotfiles` (re-exports everything under its old names), `ashyn`,
`khriss`, `wayne`, `oathgate`.

Nothing desktop-specific belongs here. If a module needs hyprland, niri,
stylix, a compositor or a GPU, it stays in `dotfiles`.

The source of truth for decisions, acceptance evidence and chronology is
Arcanum (`~/projects/arcanum`), especially
`archive/specs/shardpool/` and `log/YYYY-MM.md`. Record each assisted change
there; keep no wiki or plans in this repository.
