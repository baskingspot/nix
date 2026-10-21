{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  zig_0_16,
}:

let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "docgen";
  version = "0.0.0-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "baskingspot";
    repo = "docgen";
    rev = "1cc087b3cc906dd18c020b393eecf2ca37ea96e1";
    hash = "sha256-V6gWOY9D/JGIwk5UwWy+ZC4Z7qoHt0Rx+KGLFtMHtNI=";
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
