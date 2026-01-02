{
  config,
  pkgs,
  lib,
  mkServerModule,
  ...
}:
let
  cfg = config.programs.textlint;
in
{
  imports = [
    (mkServerModule {
      name = "textlint";
      packageName = "textlint";
    })
  ];

  # Use pkgs.textlint directly since textlint v15+ in nixpkgs already supports --mcp
  config.programs.textlint.package = lib.mkDefault pkgs.textlint;

  config.settings.servers = lib.mkIf cfg.enable {
    textlint = {
      args = ["--mcp"];
    };
  };
}
