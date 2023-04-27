{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.vim.neovim.package = mkOption {
    type = types.package;
    default = pkgs.neovim-nightly;
    description = "The NeoVim package to use. Default pkgs.neovim-nightly.";
    example = "pkgs.neovim-nightly";
  };
}
