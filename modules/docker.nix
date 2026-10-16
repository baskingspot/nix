_: {
  perSystem =
    { pkgs, ... }:
    {
      # The Docker CLI with buildx, and `hadolint`, the Dockerfile linter.
      # Dockerfiles are always checked. The daemon is not here: a person runs
      # one, and CI runners have one.
      devShells.docker = pkgs.mkShell {
        packages = with pkgs; [
          docker
          hadolint
        ];
      };
    };
}
