# RegVim

Real-time regex conversion for Neovim command line - Write extended regex patterns that automatically convert to Vim basic regex syntax while preserving full native functionality.

## 🚀 Quick Start

1. **Install with lazy.nvim:**
   ```lua
   -- In your Neovim config
   return {
     dir = "/home/enemo/project/regvim", -- Update this path
     name = "regvim",
     event = "CmdlineEnter",
     config = function() require("regvim").setup() end,
   }
   ```

2. **Restart Neovim and try:**
   ```
   # Type this in search mode:
   /(test)+

   # Watch it become:
   /\(test\)\+

   # Then press Enter - it works!
   ```

3. **That's it!** RegVim now converts your regex patterns automatically.

## Features

- **Real-time Conversion**: Type `(test)+` and it automatically becomes `\(test\)\+` as you type
- **Smart Context Detection**: Only converts in search (`/`, `?`) and substitute (`:s/`, `:%s/`) modes
- **Native Vim Experience**: Full `inccommand` support with live preview and highlighting
- **Cursor Position Preservation**: Maintains cursor position correctly even after text expansion
- **Zero Overhead**: No custom windows or buffers - pure command line enhancement
- **Configurable**: Toggle on/off, customize conversion behavior

## Installation & Setup

### Prerequisites
- Neovim 0.5+ (for Lua API support)
- No external dependencies required

### Method 1: Using lazy.nvim (Recommended)

1. **Add to your lazy.nvim configuration:**
```lua
-- In ~/.config/nvim/lua/plugins/regvim.lua or your main plugin config
return {
  dir = "/home/enemo/project/regvim", -- Update this path to your regvim location
  name = "regvim",
  event = "CmdlineEnter", -- Load when entering command line (efficient)
  config = function()
    require("regvim").setup({
      enabled = true,          -- Enable by default
      auto_convert = true,     -- Auto-convert patterns
      show_conversion = false, -- Hide conversion messages (set true for debugging)
    })
  end,
}
```

2. **Restart Neovim** and RegVim will be active immediately!

### Method 2: Using packer.nvim
```lua
-- In your packer configuration
use {
  "/home/enemo/project/regvim", -- Update this path
  config = function()
    require("regvim").setup({
      enabled = true,
      auto_convert = true,
      show_conversion = false,
    })
  end
}
```

### Method 3: Using vim-plug
```vim
" In your init.vim
Plug '/home/enemo/project/regvim' " Update this path

" Then add to your init.lua or in init.vim:
lua << EOF
require("regvim").setup({
  enabled = true,
  auto_convert = true,
  show_conversion = false,
})
EOF
```

### Method 4: Manual Installation
```bash
# 1. Copy plugin to Neovim's runtime path
mkdir -p ~/.local/share/nvim/site/pack/plugins/start/regvim
cp -r /home/enemo/project/regvim/* ~/.local/share/nvim/site/pack/plugins/start/regvim/

# 2. Add to your ~/.config/nvim/init.lua
echo 'require("regvim").setup()' >> ~/.config/nvim/init.lua

# 3. Restart Neovim
```

### Method 5: For Plugin Development/Testing
```lua
-- If you're developing or testing the plugin locally
vim.opt.runtimepath:prepend("/home/enemo/project/regvim") -- Update path
require("regvim").setup()
```

## How to Use RegVim

**RegVim works automatically!** Once installed, just start using Vim's command line normally. Your extended regex patterns will be converted in real-time.

### ✨ Live Demo - Try These Examples

After installing RegVim, open any file in Neovim and try these:

#### 1. **Search Patterns** (Type after pressing `/`)
```
/(test)           → /\(test\)        # Simple grouping
/(foo|bar)        → /\(foo\|bar\)    # Alternation
/word+            → /word\+          # One or more
/colou?r          → /colou\?r        # Optional character
/test{2,3}        → /test\{2,3\}     # Quantifiers
/(word)+end       → /\(word\)\+end   # Complex patterns
```

#### 2. **Substitute Commands** (Type after pressing `:`)
```
:%s/(.*)/[\1]/g           → :%s/\(.*\)/[\1]/g           # Wrap in brackets
:%s/(hello|hi)/bye/g      → :%s/\(hello\|hi\)/bye/g    # Replace greetings
:%s/test+/PASS/g          → :%s/test\+/PASS/g          # Replace repeated 'test'
:%s/(\d+)/num:\1/g        → :%s/\(\d\+\)/num:\1/g     # Number formatting
:%s/(start).*(end)/\1-\2/ → :%s/\(start\).*\(end\)/\1-\2/ # Extract parts
```

#### 3. **Watch the Magic Happen**
- **Type normally** using familiar regex syntax
- **Watch it convert** in real-time as you type
- **See live preview** with Vim's native `inccommand`
- **Execute as usual** with Enter

### 🎮 Interactive Example

1. **Open Neovim with a text file:**
   ```bash
   echo -e "hello world\ntest 123\nfoo bar" > sample.txt
   nvim sample.txt
   ```

2. **Try a search pattern:**
   ```
   # Press / and type:
   (hello|test)

   # You'll see it become:
   \(hello\|test\)

   # Press Enter to search!
   ```

3. **Try a substitution:**
   ```
   # Press : and type:
   %s/(.*) (.*)/\2 \1/

   # You'll see it become:
   %s/\(.*\) \(.*\)/\2 \1/

   # Press Enter to swap words!
   ```

### 🔧 Commands & Controls

| Command | Action | Example Usage |
|---------|--------|---------------|
| `:RegVim` | Toggle on/off | `:RegVim` |
| `:RegVimEnable` | Enable RegVim | `:RegVimEnable` |
| `:RegVimDisable` | Disable temporarily | `:RegVimDisable` |
| `:RegVimSetup` | Manual initialization | `:RegVimSetup` |

### 📋 When RegVim Activates

RegVim **only works** in these contexts (smart detection):
- **Search mode**: After pressing `/` or `?`
- **Substitute commands**: Starting with `:s/` or `:%s/`
- **Does NOT interfere** with other commands like `:echo`, `:let`, etc.

### 💡 Pro Tips

1. **Check if working**: Type `:RegVim` to see current status
2. **Debug mode**: Set `show_conversion = true` in config to see conversions
3. **Temporary disable**: Use `:RegVimDisable` for complex regex that shouldn't convert
4. **Works with**: All Vim regex features, flags (`g`, `i`, `c`), ranges, etc.

### Configuration

```lua
require("regvim").setup({
  enabled = true,          -- Enable RegVim by default
  auto_convert = true,     -- Auto-convert patterns in real-time
  show_conversion = false, -- Show conversion messages (can be noisy)
})
```

## Supported Conversions

| Extended Regex | Vim Basic Regex | Description |
|---------------|-----------------|-------------|
| `(pattern)` | `\(pattern\)` | Grouping |
| `{n,m}` | `\{n,m\}` | Quantifiers |
| `+` | `\+` | One or more |
| `?` | `\?` | Zero or one |
| `\|` | `\\\|` | Alternation |

## How It Works

RegVim uses Neovim's `CmdlineChanged` autocommand to monitor command line input in real-time. When you type extended regex patterns, it:

1. **Detects context** - Only activates in search/substitute modes
2. **Converts patterns** - Transforms extended to Vim basic regex syntax
3. **Updates command line** - Uses `setcmdline()` to replace text in real-time
4. **Preserves cursor** - Maintains cursor position with proper offset calculations
5. **Maintains native features** - Full `inccommand` and highlighting support

## Requirements

- Neovim 0.5+ (for Lua API and autocommands)
- No external dependencies

## License

MIT License - Feel free to use and modify as needed.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality (see [TESTING.md](TESTING.md) for details)
4. Ensure all tests pass
5. Submit a pull request

## Troubleshooting

### Common Issues

**RegVim not working?**
- Check if enabled: `:RegVimEnable`
- Verify setup was called: `:RegVimSetup`

**Conversion not happening?**
- Only works in `:s/` and `/` contexts
- Check if disabled with `:RegVim`

**Need help?**
- Check current config: `:lua print(vim.inspect(require("regvim").config))`
- Enable debug mode: `show_conversion = true` in setup

## Documentation

- **[TESTING.md](TESTING.md)** - Comprehensive testing documentation for developers
- **[test/README.md](test/README.md)** - Basic test suite overview