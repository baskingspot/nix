{ mattware, version }:
{ lib, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    let
      # "0.16" -> "0_16", the nixpkgs attribute suffix
      v = builtins.replaceStrings [ "." ] [ "_" ] version;
    in
    {
      # The imported version is `devShells.zig`. Import exactly one: two
      # versions conflict on this attrpath, and that failure is the point.
      devShells.zig = pkgs.mkShell {
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
