# Tests for textlint MCP server module
{ pkgs }:
let
  mcp-servers = import ../. { inherit pkgs; };
in
{
  test-textlint-config =
    let
      evaluated-module = mcp-servers.lib.evalModule pkgs {
        flavor = "claude";
        format = "json";
        programs.textlint.enable = true;
      };
      serverConfig = evaluated-module.config.settings.servers.textlint;
    in
    pkgs.runCommand "test-textlint-config" { nativeBuildInputs = with pkgs; [ jq ]; } ''
      touch $out
      # Verify textlint is configured
      test -n "${serverConfig.command}"
      # Verify --mcp arg is present
      echo '${builtins.toJSON serverConfig.args}' | jq -e 'contains(["--mcp"])'
    '';

  test-textlint-with-rules =
    let
      evaluated-module = mcp-servers.lib.evalModule pkgs {
        flavor = "claude";
        format = "json";
        programs.textlint = {
          enable = true;
          rules = [ pkgs.textlint-rule-alex ];
        };
      };
      serverConfig = evaluated-module.config.settings.servers.textlint;
    in
    pkgs.runCommand "test-textlint-with-rules" { nativeBuildInputs = with pkgs; [ jq ]; } ''
      touch $out
      # Verify textlint is configured with rules
      test -n "${serverConfig.command}"
      # Verify command points to textlint-with-packages (not bare textlint)
      echo "${serverConfig.command}" | grep -q "textlint-with-packages"
      # Verify --mcp arg is present
      echo '${builtins.toJSON serverConfig.args}' | jq -e 'contains(["--mcp"])'
    '';

  test-textlint-with-multiple-extensions =
    let
      evaluated-module = mcp-servers.lib.evalModule pkgs {
        flavor = "claude";
        format = "json";
        programs.textlint = {
          enable = true;
          rules = [ pkgs.textlint-rule-alex ];
          plugins = [ pkgs.textlint-plugin-org ];
          presets = [ pkgs.textlint-rule-preset-ja-technical-writing ];
        };
      };
      serverConfig = evaluated-module.config.settings.servers.textlint;
    in
    pkgs.runCommand "test-textlint-with-multiple-extensions" { nativeBuildInputs = with pkgs; [ jq ]; }
      ''
        touch $out
        # Verify textlint is configured with multiple extension types
        test -n "${serverConfig.command}"
        # Verify command points to textlint-with-packages
        echo "${serverConfig.command}" | grep -q "textlint-with-packages"
        # Verify --mcp arg is present
        echo '${builtins.toJSON serverConfig.args}' | jq -e 'contains(["--mcp"])'
      '';

  test-textlint-bare =
    let
      evaluated-module = mcp-servers.lib.evalModule pkgs {
        flavor = "claude";
        format = "json";
        programs.textlint.enable = true;
      };
      serverConfig = evaluated-module.config.settings.servers.textlint;
    in
    pkgs.runCommand "test-textlint-bare" { } ''
      touch $out
      # Verify bare textlint is used (not textlint-with-packages) when no extensions
      echo "${serverConfig.command}" | grep -qv "textlint-with-packages"
      # Verify command ends with /bin/textlint
      echo "${serverConfig.command}" | grep -q "/bin/textlint$"
    '';

  test-textlint-with-plugins-only =
    let
      evaluated-module = mcp-servers.lib.evalModule pkgs {
        flavor = "claude";
        format = "json";
        programs.textlint = {
          enable = true;
          plugins = [ pkgs.textlint-plugin-org ];
        };
      };
      serverConfig = evaluated-module.config.settings.servers.textlint;
    in
    pkgs.runCommand "test-textlint-with-plugins-only" { nativeBuildInputs = with pkgs; [ jq ]; } ''
      touch $out
      # Verify textlint is configured with plugins
      test -n "${serverConfig.command}"
      # Verify command points to textlint-with-packages
      echo "${serverConfig.command}" | grep -q "textlint-with-packages"
      # Verify --mcp arg is present
      echo '${builtins.toJSON serverConfig.args}' | jq -e 'contains(["--mcp"])'
    '';
}
