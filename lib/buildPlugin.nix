{
  pkgs,
  inputs,
  plugins,
  lib ? pkgs.lib,
  ...
}: final: prev:
with lib;
with builtins; let
  inherit (prev.vimUtils) buildVimPlugin;

  treeSitterPlug = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.tree-sitter-c
    p.tree-sitter-nix
    p.tree-sitter-python
    p.tree-sitter-rust
    p.tree-sitter-markdown
    p.tree-sitter-comment
    p.tree-sitter-toml
    p.tree-sitter-make
    p.tree-sitter-tsx
    p.tree-sitter-typescript
    p.tree-sitter-html
    p.tree-sitter-javascript
    p.tree-sitter-css
    p.tree-sitter-graphql
    p.tree-sitter-json
    p.tree-sitter-go
    p.tree-sitter-lua
    p.tree-sitter-markdown-inline
    p.tree-sitter-bash
    p.tree-sitter-regex
    p.tree-sitter-vim
    p.tree-sitter-query
    p.tree-sitter-ocaml
    p.tree-sitter-ocaml-interface
    p.tree-sitter-svelte
    # TODO at some point tree-sitter-help will become tree-sitter-vimdoc
  ]);

  buildPlug = name:
    buildVimPlugin {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
    };

  vimPlugins = {
    inherit treeSitterPlug;
  };
in {
  neovimPlugins = let
    xs = listToAttrs (map (n: nameValuePair n (buildPlug n)) plugins);
  in
    xs // vimPlugins;
}
