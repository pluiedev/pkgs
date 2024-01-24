{
  description = "Leah's custom package expressions";

  inputs.nixpkgs.url = "nixpkgs";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (sys: f nixpkgs.legacyPackages.${sys});
  in {
    packages = forAllSystems (
      pkgs: let
        inherit (pkgs.lib) pipe mapAttrs filterAttrs;
      in
        pipe ./. [
          builtins.readDir
          (mapAttrs
            (n: ty:
              if ty == "directory"
              then pkgs.callPackage ./${n} {}
              else null))
          (filterAttrs (_: v: v != null))
        ]
    );
  };
}
