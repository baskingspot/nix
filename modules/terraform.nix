_: {
  perSystem =
    { pkgs, ... }:
    {
      # OpenTofu and its linter. `tofu fmt` is the formatter and `tflint` the
      # linter. Neither runs through `nix fmt`, which is for Nix files only.
      devShells.terraform = pkgs.mkShell {
        packages = with pkgs; [
          opentofu
          tflint
        ];
      };
    };
}
