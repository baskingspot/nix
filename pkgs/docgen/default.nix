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
  version = "0.0.0-unstable-2026-11-23";

  src = fetchFromGitHub {
    owner = "baskingspot";
    repo = "docgen";
    rev = "a195b6038ae1f921ed9898f9efc285c30080e1ce";
    hash = "sha256-ucH8zxFKDs2Id5bidR9S71DTrLAnRN/+AKgFAfoJIqs=";
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
