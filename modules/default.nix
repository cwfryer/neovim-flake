{ config, lib, pkgs, ... }:

{
  imports = [
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
