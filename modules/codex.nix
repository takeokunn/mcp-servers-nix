{ mkServerModule, ... }:
{
  imports = [
    (mkServerModule {
      name = "codex";
      packageName = "codex";
    })
  ];
}
