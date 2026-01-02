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
}
