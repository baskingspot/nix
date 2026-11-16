{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  zig_0_17,
}:

let
  zig = zig_0_17;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "docgen";
  version = "0.0.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "baskingspot";
    repo = "docgen";
    rev = "6318476020a620b291e891d557045dc74b67256e";
    hash = "sha256-ypedgjdfXOwpU53uM8GS4PNSnVRT/3RnsMVv08VmdLU=";
  };

  deps = callPackage ./build.zig.zon.nix { };

  nativeBuildInputs = [ zig ];

  # The zon2nix linkFarm is a real directory of Zig packages, not symlinks.
  # Zig can resolve the dependency hashes from it without network access.
  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  strictDeps = true;

  __structuredAttrs = true;

  meta = {
    description = "Static API reference generator for Zig packages";
    homepage = "https://github.com/baskingspot/docgen";
    license = lib.licenses.mit;
    mainProgram = "docgen";
    inherit (zig.meta) platforms;
  };
})
