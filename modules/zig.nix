{ mattware, version }:
{ lib, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    let
      # "0.16" -> "0_16", the nixpkgs attribute suffix
      v = builtins.replaceStrings [ "." ] [ "_" ] version;
      # A dot in a devShell name breaks `nix develop .#name`: the attrpath
      # parser reads it as a separator, so `0.16` becomes `0-16`.
      name = "zig-${builtins.replaceStrings [ "." ] [ "-" ] version}";
    in
    {
      # Every supported version is its own shell, so a tree can import more
      # than one and pick the toolchain per command.
      devShells.${name} = pkgs.mkShell {
        packages = [
          pkgs."zig_${v}"
          mattware.packages.${system}.ziglint
          mattware.packages.${system}.zigdoc
        ]
        # zls trails Zig. A version without a zls_<v> in nixpkgs gets a shell
        # with no language server, and gains one when nixpkgs adds it.
        ++ lib.optional (pkgs ? "zls_${v}") pkgs."zls_${v}";
      };
    };
}
