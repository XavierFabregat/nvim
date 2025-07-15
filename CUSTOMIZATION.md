# Neovim Configuration Customizations

This document outlines all the custom configurations, keybindings, and quality of life improvements added to this Neovim setup based on LazyVim.

## 🤖 Claude Code Integration

### Core Operations
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ac` | `ClaudeCode` | Toggle Claude interface |
| `<leader>af` | `ClaudeCodeFocus` | Focus Claude window |
| `<leader>ar` | `ClaudeCode --resume` | Resume Claude session |
| `<leader>aC` | `ClaudeCode --continue` | Continue Claude conversation |
| `<leader>aq` | `ClaudeCodeQuit` | Quit Claude |

### File Management
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ab` | `ClaudeCodeAdd %` | Add current buffer to Claude |
| `<leader>aB` | `ClaudeCodeAdd .` | Add current directory to Claude |
| `<leader>al` | `ClaudeCodeList` | List files added to Claude |
| `<leader>ax` | `ClaudeCodeClear` | Clear all files from Claude |

### Send Content to Claude
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>as` | `ClaudeCodeSend` (visual) | Send visual selection to Claude |
| `<leader>aS` | `ClaudeCodeSend` | Send current line to Claude |
| `<leader>ap` | `ClaudeCodeSendParagraph` | Send paragraph to Claude |
| `<leader>aw` | `ClaudeCodeSendWord` | Send word under cursor to Claude |

### Diff Management
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>aa` | `ClaudeCodeDiffAccept` | Accept diff changes |
| `<leader>ad` | `ClaudeCodeDiffDeny` | Deny diff changes |
| `<leader>an` | `ClaudeCodeDiffNext` | Navigate to next diff |
| `<leader>aP` | `ClaudeCodeDiffPrev` | Navigate to previous diff |

### Quick AI Actions
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ai` | `ClaudeCode implement this function` | Ask Claude to implement function |
| `<leader>ae` | `ClaudeCode explain this code` | Ask Claude to explain code |
| `<leader>at` | `ClaudeCode write tests for this` | Ask Claude to write tests |
| `<leader>ao` | `ClaudeCode optimize this code` | Ask Claude to optimize code |
| `<leader>aD` | `ClaudeCode add documentation` | Ask Claude to add documentation |

## 🍿 Snacks.nvim Enhancements

### Productivity Features
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<leader>z` | `Snacks.zen()` | Toggle Zen Mode (distraction-free) |
| `<leader>Z` | `Snacks.zen.zoom()` | Toggle Zoom (focus current window) |
| `<leader>.` | `Snacks.scratch()` | Toggle scratch buffer |
| `<leader>S` | `Snacks.scratch.select()` | Select scratch buffer |

### Terminal Integration
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<C-/>` | `Snacks.terminal()` | Toggle terminal (bottom, 40% height) |
| `<C-_>` | `Snacks.terminal()` | Toggle terminal (alternative binding) |

### Git Integration
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<leader>gB` | `Snacks.gitbrowse()` | Open current file/line in browser |
| `<leader>gb` | `Snacks.git.blame_line()` | Show git blame for current line |
| `<leader>gf` | `Snacks.lazygit.log_file()` | Lazygit history for current file |
| `<leader>gl` | `Snacks.lazygit.log()` | Lazygit log for current directory |

### Notifications & UI
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<leader>n` | `Snacks.notifier.show_history()` | Show notification history |
| `<leader>un` | `Snacks.notifier.hide()` | Dismiss all notifications |
| `<leader>N` | Open Neovim News | View latest Neovim updates |

### Buffer & File Management
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<leader>bd` | `Snacks.bufdelete()` | Smart buffer delete |
| `<leader>cR` | `Snacks.rename.rename_file()` | Rename current file |

### Word Navigation
| Keybinding | Function | Description |
|------------|----------|-------------|
| `]]` | `Snacks.words.jump(1)` | Jump to next word reference |
| `[[` | `Snacks.words.jump(-1)` | Jump to previous word reference |

### Enhanced Configurations

#### Notifications
- **Timeout**: 3 seconds
- **Icons**: Error (󰅚), Warning (󰀪), Info (󰋽), Debug (󰃠), Trace (✎)
- **Smart positioning**: Top-right with margins
- **Level filtering**: All levels (TRACE to ERROR)

#### Explorer
- **Replace netrw**: Disabled built-in file explorer
- **Sidebar integration**: Modern file tree interface

#### Terminal
- **Position**: Bottom of screen
- **Height**: 40% of window
- **Smart toggling**: Hide/show with same keybinding

#### Animations
- **Indent guides**: Smooth animation (500ms total, 20ms steps)
- **Smooth scrolling**: Linear easing (250ms total, 15ms steps)

## ⚡ Quality of Life Improvements

### Editor Settings

#### Enhanced Scrolling
```lua
scrolloff = 8           -- Keep 8 lines above/below cursor
sidescrolloff = 8       -- Keep 8 columns left/right of cursor
smoothscroll = true     -- Smooth scrolling
```

#### Better Search
```lua
ignorecase = true       -- Ignore case in search
smartcase = true        -- Unless uppercase is used
incsearch = true        -- Incremental search
hlsearch = true         -- Highlight search results
```

#### Enhanced Editing
```lua
undofile = true         -- Persistent undo
undolevels = 10000      -- More undo levels
updatetime = 200        -- Faster completion (default 4000ms)
timeoutlen = 300        -- Faster key timeout
autowrite = true        -- Auto write when switching buffers
confirm = true          -- Confirm before discarding changes
```

#### Visual Experience
```lua
cursorline = true       -- Highlight current line
colorcolumn = "100"     -- Show column at 100 characters
number = true           -- Show line numbers
relativenumber = true   -- Show relative line numbers
list = true             -- Show invisible characters
```

#### Invisible Characters Display
- **Tab**: `→ `
- **Trailing spaces**: `·`
- **Line extends**: `…`
- **Non-breaking space**: `␣`

### Window Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-h>` | `<C-w>h` | Move to left window |
| `<C-j>` | `<C-w>j` | Move to bottom window |
| `<C-k>` | `<C-w>k` | Move to top window |
| `<C-l>` | `<C-w>l` | Move to right window |

### Window Resizing
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-Up>` | `resize +2` | Increase window height |
| `<C-Down>` | `resize -2` | Decrease window height |
| `<C-Left>` | `vertical resize -2` | Decrease window width |
| `<C-Right>` | `vertical resize +2` | Increase window width |

### Text Manipulation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<A-j>` | Move line down | Move current line down |
| `<A-k>` | Move line up | Move current line up |
| `<A-j>` (visual) | Move selection down | Move visual selection down |
| `<A-k>` (visual) | Move selection up | Move visual selection up |
| `<leader>d` | Duplicate line | Duplicate current line |
| `<leader>d` (visual) | Duplicate selection | Duplicate visual selection |

### Better Indenting
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<` (visual) | `<gv` | Indent left and reselect |
| `>` (visual) | `>gv` | Indent right and reselect |

### Search & Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `n` | `nzzzv` | Next search result (centered) |
| `N` | `Nzzzv` | Previous search result (centered) |
| `<Esc>` | Clear search highlights | Remove search highlighting |
| `<C-d>` | `<C-d>zz` | Scroll down (centered) |
| `<C-u>` | `<C-u>zz` | Scroll up (centered) |

### File Operations
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-s>` | Save file | Quick save (normal mode) |
| `<C-s>` (insert) | Save file | Quick save (insert mode) |
| `<C-a>` | Select all | Select entire buffer |

### Buffer Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `[b` | Previous buffer | Navigate to previous buffer |
| `]b` | Next buffer | Navigate to next buffer |
| `<leader>bb` | Switch to other buffer | Toggle between current and previous |

### Quick Fix & Location Lists
| Keybinding | Action | Description |
|------------|--------|-------------|
| `[q` | Previous quickfix | Navigate to previous quickfix item |
| `]q` | Next quickfix | Navigate to next quickfix item |
| `[l` | Previous location | Navigate to previous location item |
| `]l` | Next location | Navigate to next location item |

### Diagnostic Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `[d` | Previous diagnostic | Go to previous diagnostic |
| `]d` | Next diagnostic | Go to next diagnostic |

### Utility Functions
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>uw` | Toggle word wrap | Enable/disable line wrapping |
| `<leader>ur` | Toggle relative numbers | Enable/disable relative line numbers |
| `<leader>uR` | Clear all registers | Clear all vim registers |
| `<leader>cf` | Format document | Format current file using LSP |
| `<leader>qq` | Quit all | Close all windows |
| `<leader>qQ` | Force quit all | Force close all windows |

### Better Text Operations
| Keybinding | Action | Description |
|------------|--------|-------------|
| `J` | `mzJ`z` | Join lines without moving cursor |
| `p` (visual) | `"_dP` | Paste without yanking replaced text |

## 🎨 Explorer Configuration

### File Explorer
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>e` | Snacks Explorer | Open modern sidebar file explorer |
| `\` | Netrw Explorer | Open built-in file explorer |

The new Snacks explorer replaces netrw and provides:
- Modern sidebar interface
- Tree-style navigation
- Better integration with LazyVim
- Consistent theming

## 🔧 Auto-commands

### Smart Behaviors
- **Highlight on yank**: Brief highlight when copying text (200ms)
- **Auto-resize splits**: Automatically balance windows when terminal is resized
- **Remember cursor position**: Return to last cursor position when reopening files
- **Auto-reload files**: Detect and reload files changed outside Neovim
- **Quick close**: Press `q` to close help, man pages, and info windows

### File Type Handling
Special handling for these file types with `q` to close:
- Quickfix lists
- Help files
- Man pages
- Notifications
- LSP info
- Various plugin windows

## 📁 File Structure

```
~/.config/nvim/
├── CUSTOMIZATION.md          # This documentation file
├── init.lua                  # Main configuration entry point
├── lazy-lock.json           # Plugin version lock file
├── lazyvim.json            # LazyVim settings
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto-commands
│   │   ├── keymaps.lua     # Custom keybindings
│   │   ├── lazy.lua        # Lazy.nvim setup
│   │   ├── options.lua     # Quality of life settings
│   │   ├── colorscheme.lua # Color scheme configuration
│   │   └── highlights.lua  # Custom highlights
│   └── plugins/
│       ├── claudecode.lua  # Claude Code configuration
│       ├── snacks.lua      # Snacks.nvim configuration
│       ├── dashboard.lua   # Dashboard configuration
│       ├── noe-tree.lua    # Neo-tree disabled
│       ├── copilot.lua     # GitHub Copilot
│       ├── treesitter.lua  # Treesitter configuration
│       └── which-key.lua   # Which-key configuration
└── stylua.toml             # Lua formatter configuration
```

## 🚀 Getting Started

1. **Open Neovim**: All configurations load automatically
2. **Explore keybindings**: Press `<leader>` (space) to see available options via which-key
3. **Start Claude**: Press `<space>ac` to toggle Claude interface
4. **File exploration**: Press `<space>e` for the modern file explorer
5. **Terminal**: Press `<C-/>` for integrated terminal
6. **Zen mode**: Press `<space>z` for distraction-free coding

## 🔍 Tips & Tricks

1. **Quick file operations**: Use `<space>e` for file explorer, then navigate with vim motions
2. **Claude workflow**: Add files with `<space>ab`, send selections with `<space>as` (visual mode)
3. **Split management**: Use `<C-hjkl>` for navigation, arrow keys for resizing
4. **Search workflow**: Use `/` to search, then `n`/`N` for navigation (automatically centered)
5. **Buffer management**: Use `[b`/`]b` for navigation, `<space>bd` for smart deletion
6. **Git integration**: Use `<space>gb` for blame, `<space>gf` for file history
7. **Notifications**: Check `<space>n` for notification history, `<space>un` to dismiss all

## 📝 Notes

- All keybindings use `<leader>` which is mapped to the space key
- Visual mode selections work with most text manipulation commands
- The configuration maintains LazyVim defaults while adding enhancements
- Claude Code integration provides seamless AI assistance workflow
- Snacks.nvim adds modern UI components and smooth animations