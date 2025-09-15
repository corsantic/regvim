# RegVim
This plugin is made because i forget everytime to escape after writing the characters in Vim command line.

Press Tab to escape regex characters in Vim command line. Position cursor after `(`, `+`, `?`, `|`, `{`, `}` and press Tab to add backslash.

## Install

```lua
-- lazy.nvim
{
  "corsantic/regvim",
  event = "CmdlineEnter",
  config = true,
}
```

## Usage

1. Type `/hello(world)+` in search mode
2. Move cursor after `(` and press Tab → `/hello\(world)+`
3. Move cursor after `+` and press Tab → `/hello\(world)\+`
4. Press Enter to search

Works in `/` search and `:s/` substitute modes.

## Commands

- `:RegVim` - Toggle on/off
- `:RegVimEnable` / `:RegVimDisable` - Enable/disable

## Config

```lua
require("regvim").setup({
  convert_key = '<Tab>', -- Change key if needed
  escape_characters = { "(", ")", "+", "?", "|", "{", "}" }, -- Change default characters as needed
})
```

That's it!
