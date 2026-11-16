# async-compiler.vim
An async wrapper around the builtin |:make|.

## INTRODUCTION

This plugin provides the ability to run compiler commands, set via `'makeprg'`,
and `:compiler`. But allows you to run those asynchronously. It does so by
running those commands inside a terminal buffer, and capturing the output
using the appropriate primitives present in vim and neovim.

## INSTALLATION

You should be able to install this plugin using any plugin manager of your choice.

(If some plugin manager does not work then feel free to open an issue).

### vim.pack

```lua
vim.pack.add {
    "https://github.com/tomshoo/async-compiler.vim",
}
```

### lazy.vim

```lua
{
    "tomshoo/async-compiler.vim",
}
```

### vim-plug

```vim
Plug 'tomshoo/async-compiler.vim'
```

## VERSIONING
There is no specific versioning for this plugin. If you want you can pin to the
most recent stable commit. Apart from that I'll try to keep the master branch
as stable as possible.

## CONTRIBUTING
This plugin is a fully handcrafted product. I do not like to use AI, but if you
have something that you might want in this plugin then you can craft a PR even
with AI. Just make sure that your code is thoroughly reviewed by you, and any
code written by AI is properly disclosed.

## INSPIRATION
- [Emacs Compilation Mode](https://www.gnu.org/software/emacs/manual/html_node/emacs/Compilation-Mode.html) The superior way to compiler code.
