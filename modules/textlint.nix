{
  config,
  pkgs,
  lib,
  mkServerModule,
  ...
}:
let
  cfg = config.programs.textlint;

  allExtensions = cfg.rules ++ cfg.plugins ++ cfg.presets ++ cfg.filterRules ++ cfg.configs;

  finalPackage =
    if allExtensions == [ ] then
      pkgs.textlint
    else
      (pkgs.textlint.withPackages allExtensions).overrideAttrs (old: {
        meta = (old.meta or { }) // {
          mainProgram = "textlint";
        };
      });
in
{
  imports = [
    (mkServerModule {
      name = "textlint";
      packageName = "textlint";
    })
  ];

  options.programs.textlint = {
    rules = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.textlint-rule-alex pkgs.textlint-rule-terminology ]";
      description = ''
        List of textlint rule packages (textlint-rule-*).
        These packages will be available via NODE_PATH.
      '';
    };

    plugins = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.textlint-plugin-org pkgs.textlint-plugin-latex2e ]";
      description = ''
        List of textlint plugin packages (textlint-plugin-*).
        Plugins add support for additional file formats.
      '';
    };

    presets = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.textlint-rule-preset-ja-technical-writing ]";
      description = ''
        List of textlint preset packages (textlint-rule-preset-*).
        Presets bundle multiple rules together.
      '';
    };

    filterRules = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.textlint-filter-rule-comments ]";
      description = ''
        List of textlint filter rule packages (textlint-filter-rule-*).
        Filter rules suppress specific linting errors.
      '';
    };

    configs = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.textlint-config-example ]";
      description = ''
        List of textlint shareable config packages (textlint-config-*).
        Shareable configs provide complete textlint configurations.
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = lib.literalExpression "./.textlintrc.json";
      description = ''
        Path to .textlintrc configuration file.
        This file specifies which rules to enable and their settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.textlint.package = lib.mkDefault finalPackage;

    settings.servers.textlint = {
      args =
        [ "--mcp" ]
        ++ lib.optionals (cfg.configFile != null) [
          "--config"
          (toString cfg.configFile)
        ];
    };
  };
}
