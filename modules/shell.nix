_: {
  perSystem =
    { pkgs, ... }:
    {
      # Shell scripts are always checked: `shfmt` formats and `shellcheck`
      # lints. Neither runs through `nix fmt`.
      devShells.shell = pkgs.mkShell {
        packages = with pkgs; [
          shellcheck
          shfmt
        ];
      };
    };
}
