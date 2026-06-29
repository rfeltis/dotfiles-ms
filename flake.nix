{
  description = "Reproducible Codespace pool bootstrap (Nix + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Codespace images run as different default users depending on the base
      # image (node, codespace, vscode, ...). Build an identical config for each
      # so install.sh can apply `.#$(whoami)` on any pool machine.
      users = [ "node" "codespace" "vscode" "root" ];

      homeDir = user: if user == "root" then "/root" else "/home/${user}";

      mkHome = user:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = user;
              home.homeDirectory = homeDir user;
            }
          ];
        };
    in
    {
      homeConfigurations = nixpkgs.lib.genAttrs users mkHome;
    };
}
