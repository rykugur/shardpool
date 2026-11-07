{
  description = "Shared NixOS and home-manager modules for Dusty's headless hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    helix.url = "github:helix-editor/helix";

    umbrella = {
      url = "github:PZ-Umbrella/Umbrella";
      flake = false;
    };

    zmx-session-manager.url = "github:mdsakalu/zmx-session-manager";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Defines `flake.modules.<class>.<name>`. dotfiles imports this too;
        # wayne does not, because wayne only consumes modules.
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
