# Shardpool

Shared NixOS and home-manager modules for Dusty's headless hosts.

Named for the Cosmere's Shardpools: the source everything draws its
Investiture from.

## What lives here

| Class | Modules |
|---|---|
| `nixos` | `comin`, `impermanence`, `btrfs-rollback`, `guest-access`, `ssh-server`, `meta`, `nix-defaults`, `helix-guest`, `helix-root` |
| `homeManager` | `helix`, `helix-lxc`, `television`, `yazi`, `zmx`, `starshipFormat` |
| `lib` | `dustySshKeys` |

Public, because `dotfiles` imports it. Nothing here is secret —
`dustySshKeys` holds public keys only.

## Why it exists

Standalone host repos used to take `dotfiles` as an input just to reach these
modules, which meant fetching 40 top-level inputs and 123 locked nodes —
hyprland, niri, stylix, zen-browser, nix-gaming — onto a headless box. This
flake has nine inputs.

It also removed a load-bearing hack: `nix-defaults` used to set
`nixpkgs.overlays` from `inputs.self.overlays.*`, which forced consumers to
splice `inputs = dotfiles.inputs // { self = dotfiles; }` into `specialArgs`.
That block is gone; `dotfiles` carries it in its own `dotfiles-overlays`
module.

## Consumers

`dotfiles` (re-exports everything under its previous names, so its own hosts
are unaffected), `ashyn`, `khriss`, `wayne`, `oathgate`.

## Scope

Nothing desktop-specific. If a module needs a compositor, a GPU or a Wayland
session, it belongs in `dotfiles`.

## Usage

```nix
inputs.shardpool.url = "github:rykugur/shardpool";
# ...
imports = [ inputs.shardpool.modules.nixos.comin ];
ryk.comin.url = "git@github.com:rykugur/myhost.git";   # required
ryk.comin.deployKeyPath = config.sops.secrets.deploy_key.path;  # private repos
```

## Documentation

Design, decisions and chronology live in Arcanum (`~/projects/arcanum`), under
`archive/specs/shardpool/` and the monthly log. This repository keeps no wiki.
