{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./basic
    ./coding
    ./colorscheme
    ./core
    ./editor
    ./keys
    ./lsp
    ./neovim
    ./treesitter
    ./ui
    ./util
  ];
}
