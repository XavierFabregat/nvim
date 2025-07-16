# 🚀 Modern Neovim Configuration

A highly customized Neovim configuration built on [LazyVim](https://github.com/LazyVim/LazyVim) with Claude Code integration, modern UI enhancements, TypeScript/Next.js development tools, and extensive productivity improvements.

## ✨ Features

- 🤖 **Claude Code Integration** - Seamless AI assistance with dedicated terminal
- 🍿 **Snacks.nvim** - Modern UI components and smooth animations  
- ⚡ **Enhanced UX** - Quality of life improvements and better defaults
- 🎨 **Modern Explorer** - Sidebar file management replacing netrw
- 🔧 **Smart Auto-commands** - Intelligent behavior automation
- 📁 **Extensible Architecture** - Easy to customize and extend
- 🟦 **TypeScript/Next.js** - Auto-imports, templates, and smart navigation
- 📦 **Package Management** - npm/yarn/pnpm integration with script runner
- 🎯 **Multi-cursor** - Advanced multi-cursor editing capabilities
- 🔖 **Bookmarks** - Persistent bookmark system with annotations
- 📋 **Clipboard History** - Enhanced clipboard management with history
- 🌈 **Rainbow Brackets** - Visual code hierarchy with colored brackets
- 📝 **Smart Spell Check** - Context-aware spell checking for comments/strings

## 🛠️ Installation

### Prerequisites

- Neovim 0.9.0+ (recommended: latest stable)
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for proper icons
- [Claude Code CLI](https://claude.ai/code) installed and configured
- Node.js (for LSP servers, formatters, and package management)
- TypeScript (for TypeScript projects): `npm install -g typescript`

### Quick Install

```bash
# Backup existing config (optional)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this configuration
git clone https://github.com/XavierFabregat/nvim ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

### Manual Setup

1. **Install Neovim**: Follow [official installation guide](https://github.com/neovim/neovim/wiki/Installing-Neovim)

2. **Install Claude Code CLI**:
   ```bash
   npm install -g @anthropic-ai/claude-code
   claude code auth  # Follow authentication flow
   ```

3. **Install dependencies**:
   ```bash
   # For TreeSitter parsers and LSP servers
   npm install -g tree-sitter-cli
   
   # For Lua formatting (optional)
   cargo install stylua
   ```

4. **Clone and configure**:
   ```bash
   git clone git@github.com:XavierFabregat/nvim.git ~/.config/nvim
   cd ~/.config/nvim
   nvim  # Let lazy.nvim install plugins
   ```

## 🎯 Core Features

### 🤖 Claude Code Integration

Primary shortcut: **`<C-k>`** - Opens Claude Code terminal

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ac` | Toggle Claude terminal | Main interface |
| `<leader>ar` | Show conversation picker | Resume conversations |
| `<leader>aC` | Continue recent conversation | Quick resume |
| `<leader>av` | Enable verbose logging | Debug mode |

**Features:**
- Terminal-based integration using `greggh/claude-code.nvim`
- Auto-detects git projects and refreshes files
- 40% width sidebar positioning for stable workflow
- Full Claude Code CLI command support

### 🍿 Snacks.nvim Enhancements

Modern UI components replacing built-in functionality:

#### Productivity
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>z` | Zen Mode | Distraction-free coding |
| `<leader>Z` | Zoom | Focus current window |
| `<leader>.` | Scratch buffer | Quick notes |
| `<C-/>` | Terminal | Bottom terminal (40% height) |

#### Git Integration
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>gB` | Browse file | Open in browser |
| `<leader>gb` | Blame line | Git blame current line |
| `<leader>gf` | File history | Lazygit file log |
| `<leader>gl` | Repository log | Lazygit repo log |

#### File Management
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>e` | File explorer | Modern sidebar explorer |
| `<leader>bd` | Smart delete | Close buffer intelligently |
| `<leader>cR` | Rename file | Rename current file |

### 🟦 TypeScript/Next.js Development

#### TypeScript Tools
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>to` | Organize imports | Auto-organize TypeScript imports |
| `<leader>tr` | Remove unused imports | Clean up unused imports |
| `<leader>ta` | Add missing imports | Auto-add missing imports |
| `<leader>tf` | Fix all issues | Fix all TypeScript problems |
| `<leader>tc` | TypeScript check | Run compiler check |
| `<leader>tw` | TypeScript watch | Start watch mode |

#### Next.js Navigation
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>np` | Find pages | Navigate to pages directory |
| `<leader>nc` | Find components | Navigate to components |
| `<leader>na` | Find API routes | Navigate to API routes |
| `<leader>nh` | Find hooks | Navigate to custom hooks |
| `<leader>nr` | Switch related file | Toggle component ↔ test, page ↔ API |

#### Component Templates
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>ncc` | Create component | Generate React component |
| `<leader>ncp` | Create page | Generate Next.js page |
| `<leader>nca` | Create API route | Generate API route |
| `<leader>nch` | Create hook | Generate custom hook |

### 📦 Package Management

#### Package Operations
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>Pi` | Install deps | Install all dependencies |
| `<leader>Pa` | Add dependency | Add new dependency |
| `<leader>Pd` | Add dev dependency | Add dev dependency |
| `<leader>Pr` | Remove dependency | Remove dependency |
| `<leader>Ps` | Run script | Show script picker |

#### Quick Scripts
| Key | Function | Description |
|-----|----------|-------------|
| `<leader>Psd` | Run dev | Start development server |
| `<leader>Psb` | Run build | Build project |
| `<leader>Pst` | Run test | Run test suite |
| `<leader>Psl` | Run lint | Run linter |
| `<leader>Pss` | Run start | Start production server |

**Features:**
- Auto-detects npm/yarn/pnpm/bun from lock files
- Integrates with Snacks terminal for better UX
- Inline package version display in package.json
- Quick dependency management

### ⚡ Quality of Life Improvements

#### Enhanced Editor Settings
```lua
-- Better scrolling and search
scrolloff = 8, sidescrolloff = 8
ignorecase = true, smartcase = true
smoothscroll = true

-- Improved editing experience  
undofile = true, undolevels = 10000
updatetime = 200, timeoutlen = 300
autowrite = true, confirm = true

-- Visual enhancements
cursorline = true, colorcolumn = "100"
relativenumber = true, list = true
```

#### Smart Keybindings

**Window Management:**
- `<C-hjkl>` - Navigate between windows
- `<C-Arrow>` - Resize windows dynamically

**Text Operations:**
- `<A-jk>` - Move lines up/down
- `<leader>d` - Duplicate line/selection
- `</>` (visual) - Better indenting with reselection

**Navigation:**
- `n/N` - Search with auto-centering
- `<C-du>` - Scroll with centering
- `[]/b` - Buffer navigation

**Multi-cursor & Productivity:**
- `<C-d>` - Add cursor to word under cursor
- `<leader>mm` - Toggle bookmark at current line
- `<leader>fy` - Access clipboard history
- `<leader>us` - Toggle spell checking
- `<leader>ca` - Show code actions

## 📁 Architecture

### File Structure
```
~/.config/nvim/
├── init.lua                  # Bootstrap entry point
├── CLAUDE.md                 # AI assistant instructions
├── CUSTOMIZATION.md          # Detailed feature documentation
├── lazy-lock.json           # Plugin version locking
├── lazyvim.json            # LazyVim settings
├── stylua.toml             # Lua formatter config
└── lua/
    ├── config/              # Core configuration
    │   ├── lazy.lua        # Plugin manager setup
    │   ├── options.lua     # Editor settings & QoL
    │   ├── keymaps.lua     # Custom keybindings  
    │   ├── autocmds.lua    # Auto-commands
    │   ├── colorscheme.lua # Theme configuration
    │   └── highlights.lua  # Custom highlights
    └── plugins/             # Plugin configurations
        ├── claudecode.lua  # Claude Code integration
        ├── snacks.lua      # Modern UI components
        ├── typescript.lua  # TypeScript tools & enhancements
        ├── nextjs.lua      # Next.js navigation & templates
        ├── package-manager.lua # Package management integration
        ├── multicursor.lua # Multi-cursor editing
        ├── bookmarks.lua   # Bookmark system
        ├── clipboard.lua   # Clipboard history
        ├── rainbow.lua     # Rainbow brackets
        ├── spell.lua       # Smart spell checking
        ├── dashboard.lua   # Startup dashboard
        ├── copilot.lua     # GitHub Copilot
        ├── treesitter.lua  # Syntax highlighting
        └── which-key.lua   # Keybinding discovery
```

### Plugin Management

**Based on lazy.nvim:**
- LazyVim foundation with custom overrides
- Automatic plugin updates with version locking
- Performance optimizations and disabled built-ins
- Lazy loading for optimal startup times

**Key Design Principles:**
- Extend LazyVim, don't replace it
- Maintain compatibility with LazyVim updates
- Focus on productivity and workflow enhancement
- Terminal-based integrations for stability
- TypeScript/Next.js first-class support
- Smart package management integration

## 🔧 Customization

### Adding New Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- Lazy loading
  opts = {
    -- Plugin configuration
  },
  keys = {
    { "<leader>mp", "<cmd>MyPlugin<cr>", desc = "My Plugin" },
  },
}
```

### Modifying Keybindings

Edit `lua/config/keymaps.lua`:

```lua
-- Add new keybinding
vim.keymap.set("n", "<leader>my", function()
  -- Your function here
end, { desc = "My custom function" })

-- Override existing keybinding
vim.keymap.set("n", "<C-k>", "<cmd>MyCommand<cr>", { desc = "My override" })
```

### Customizing Options

Edit `lua/config/options.lua`:

```lua
-- Add new vim options
vim.opt.my_option = true
vim.opt.another_setting = "value"
```

### Extending Auto-commands

Edit `lua/config/autocmds.lua`:

```lua
-- Create new autocommand group
local augroup = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = "*.lua",
  callback = function()
    -- Your custom logic
  end,
})
```

## 🎨 Theming

### Color Scheme Configuration

Edit `lua/config/colorscheme.lua`:

```lua
-- Set your preferred colorscheme
vim.cmd.colorscheme("tokyonight-storm")  -- or your choice

-- Custom highlights in lua/config/highlights.lua
vim.api.nvim_set_hl(0, "MyHighlight", { 
  fg = "#ffffff", 
  bg = "#000000" 
})
```

### Transparency Support

The configuration includes transparency support:

```lua
-- In lua/config/options.lua
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Transparency handled in colorscheme configuration
```

## 🚀 Development Workflow

### Essential Commands

```bash
# Plugin Management
:Lazy                    # Open plugin manager
:Lazy update            # Update all plugins  
:Lazy clean             # Remove unused plugins
:Lazy profile           # Performance profiling

# Configuration Reload
:source %               # Reload current file
:LuaSnip reload         # Reload snippets

# TypeScript/Next.js Development
:TSC                    # TypeScript check
:TSCWatch               # TypeScript watch mode
:NextComponent component MyComponent  # Create component template

# Package Management
:PackageRun             # Show script picker
:PackageInstall         # Install dependencies
:PackageAdd             # Add new dependency

# Health Checks
:checkhealth            # System health check
:checkhealth lazy       # Plugin manager health
```

### Testing Changes

1. **Edit configuration files** in `lua/config/` or `lua/plugins/`
2. **Reload with** `:source %` or restart Neovim
3. **Test functionality** - keybindings, plugins, etc.
4. **Check for errors** - `:messages` for any issues
5. **Verify Claude Code** - `<space>ac` should work

### Code Formatting

The configuration includes StyLua for Lua formatting:

```bash
# Format Lua files (if stylua installed)
stylua .

# Configuration in stylua.toml:
# - 2 space indentation
# - 120 character line width
# - Standard Lua conventions
```

## 🔍 Troubleshooting

### Common Issues

**Claude Code not working:**
```bash
# Check Claude CLI installation
claude --version

# Re-authenticate if needed
claude auth

# Check Neovim plugin installation
:Lazy load claude-code.nvim
```

**Plugins not loading:**
```bash
# Check plugin status
:Lazy

# Clear cache and reinstall
rm -rf ~/.local/share/nvim
nvim  # Will reinstall everything
```

**Performance issues:**
```bash
# Profile startup time
nvim --startuptime startup.log

# Check health
:checkhealth
```

### Getting Help

- **Documentation**: See `CUSTOMIZATION.md` for detailed feature guide
- **LazyVim**: Check [LazyVim documentation](https://lazyvim.github.io/)
- **Claude Code**: Visit [Claude Code docs](https://claude.ai/code)
- **Issues**: Create issue in your repository

## 📚 Resources

### Learning Materials
- [Neovim Documentation](https://neovim.io/doc/)
- [LazyVim Guide](https://lazyvim.github.io/)
- [Lua for Neovim](https://github.com/nanotee/nvim-lua-guide)

### Useful Plugins
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- [LazyVim Extras](https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim/plugins/extras)

## 🤝 Contributing

### Making Changes
1. Fork this repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Test changes thoroughly
4. Update documentation if needed
5. Submit pull request

### Plugin Suggestions
- Should enhance productivity or workflow
- Must be actively maintained
- Should integrate well with LazyVim
- Performance impact should be minimal

## 📄 License

This configuration is provided under the MIT License. See `LICENSE` file for details.

---

**Happy coding!** 🎉

For detailed feature documentation, see [`CUSTOMIZATION.md`](CUSTOMIZATION.md).
For AI assistant instructions, see [`CLAUDE.md`](CLAUDE.md).
