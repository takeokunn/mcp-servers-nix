{ mkServerModule, ... }:
{
  imports = [ (mkServerModule { name = "codex"; }) ];
}
