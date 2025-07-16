# Neovim Configuration Customizations

This document outlines all the custom configurations, keybindings, and quality of life improvements added to this Neovim setup based on LazyVim.

## 🤖 Claude Code Integration (Terminal-based)

This configuration uses the stable `greggh/claude-code.nvim` plugin for reliable terminal-based Claude Code integration.

### Primary Shortcut
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<C-k>` | `ClaudeCode` | **Main shortcut** - Open Claude Code terminal |

### Core Operations
| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ac` | `ClaudeCode` | Toggle Claude Code terminal |
| `<leader>ar` | `ClaudeCodeResume` | Show conversation picker |
| `<leader>aC` | `ClaudeCodeContinue` | Resume recent conversation |
| `<leader>av` | `ClaudeCodeVerbose` | Enable verbose logging |

### Plugin Features
- **Terminal Integration**: Opens Claude Code CLI in a dedicated terminal window
- **Auto-detection**: Automatically detects git projects
- **File Refresh**: Auto-refreshes modified files in the editor
- **Window Configuration**: 
  - Positioned on the right side
  - 40% width, 80% height
  - Non-floating window for stable interaction
- **Command Support**: Full Claude Code CLI command support
- **Plenary.nvim**: Uses plenary.nvim for enhanced functionality

### Workflow
1. Press `<C-k>` to open Claude Code terminal
2. Interact directly with Claude Code CLI
3. Files are automatically refreshed when modified
4. Use resume/continue commands to manage conversations

### Requirements
- Neovim 0.7.0+
- Claude Code CLI installed and configured
- plenary.nvim dependency

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

### Auto-save Functionality
The configuration includes intelligent auto-save that triggers on:
- Buffer switch (`BufLeave`)
- Focus lost (`FocusLost`)
- Idle timeout (`CursorHold`)

Only saves files that are:
- Modified
- Regular files (not special buffers)
- Not read-only

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

### Enhanced LSP & Code Actions
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ca` | Code actions | Show available code actions |
| `<leader>ca` (visual) | Code actions | Show code actions for selection |
| `<leader>cr` | Rename symbol | Rename symbol under cursor |
| `<leader>cl` | Run code lens | Execute code lens action |
| `<leader>qf` | Quick fix | Apply preferred code action |
| `K` | Hover documentation | Show hover information |
| `<C-k>` | Signature help | Show signature help |
| `<C-k>` (insert) | Signature help | Show signature help in insert mode |

### Enhanced Diagnostic Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `[d` | Previous diagnostic | Go to previous diagnostic (with float) |
| `]d` | Next diagnostic | Go to next diagnostic (with float) |
| `<leader>cd` | Show diagnostic | Show diagnostic float |
| `[e` | Previous error | Go to previous error only |
| `]e` | Next error | Go to next error only |
| `[w` | Previous warning | Go to previous warning only |
| `]w` | Next warning | Go to next warning only |

### Multi-cursor Editing
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-d>` | Add cursor on word | Add cursor to word under cursor |
| `<C-d>` (visual) | Add cursor on selection | Add cursor to visual selection |
| `<M-C-j>` | Add cursor down | Add cursor below current |
| `<M-C-k>` | Add cursor up | Add cursor above current |
| `<C-x>` | Skip region | Skip current region in multi-cursor |
| `<C-p>` | Remove region | Remove current region from multi-cursor |
| `\A` | Select all | Select all occurrences |
| `\a` | Add selection | Add to selection |
| `\f` | Find selection | Find selection |
| `\c` | Create cursors | Create cursors from selection |
| `gS` | Reselect last | Reselect last multi-cursor selection |

### Bookmark System
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>mm` | Toggle bookmark | Toggle bookmark at current line |
| `<leader>mi` | Annotate bookmark | Add annotation to bookmark |
| `<leader>ma` | Show all bookmarks | Show all bookmarks in quickfix |
| `<leader>mn` | Next bookmark | Navigate to next bookmark |
| `<leader>mp` | Previous bookmark | Navigate to previous bookmark |
| `<leader>mc` | Clear bookmarks | Clear bookmarks in current buffer |
| `<leader>mx` | Clear all bookmarks | Clear all bookmarks |
| `<leader>ms` | Save bookmarks | Save bookmarks to file |
| `<leader>ml` | Load bookmarks | Load bookmarks from file |
| `<leader>fb` | Find bookmarks (file) | Telescope: bookmarks in current file |
| `<leader>fB` | Find bookmarks (all) | Telescope: bookmarks in all files |

### Clipboard Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>fy` | Clipboard history | Show clipboard history (neoclip) |
| `<leader>fY` | System clipboard | Show system clipboard history |
| `<leader>fm` | Macro history | Show macro history |
| `<leader>p` | Put after | Smart put after with yanky |
| `<leader>P` | Put before | Smart put before with yanky |
| `<leader>gp` | Put after (cursor) | Put after, leave cursor |
| `<leader>gP` | Put before (cursor) | Put before, leave cursor |
| `[y` | Cycle forward | Cycle forward through yank history |
| `]y` | Cycle backward | Cycle backward through yank history |

### Spell Checking
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>us` | Toggle spell check | Enable/disable spell checking |
| `]s` | Next spelling mistake | Jump to next spelling error |
| `[s` | Previous spelling mistake | Jump to previous spelling error |
| `z=` | Spelling suggestions | Show spelling suggestions |
| `zg` | Add word to dictionary | Add word to personal dictionary |
| `zw` | Mark word incorrect | Mark word as incorrect |
| `zug` | Remove from dictionary | Remove word from personal dictionary |
| `<leader>cs` | Quick fix spelling | Apply first spelling suggestion |

### Utility Functions
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>uw` | Toggle word wrap | Enable/disable line wrapping |
| `<leader>ur` | Toggle relative numbers | Enable/disable relative line numbers |
| `<leader>uR` | Clear all registers | Clear all vim registers |
| `<leader>cf` | Format document | Format current file using LSP |
| `<leader>qq` | Quit all | Close all windows |
| `<leader>qQ` | Force quit all | Force close all windows |

### TypeScript/Next.js Development
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>to` | Organize imports | Auto-organize TypeScript imports |
| `<leader>tr` | Remove unused imports | Remove unused import statements |
| `<leader>ta` | Add missing imports | Add missing import statements |
| `<leader>tf` | Fix all issues | Fix all TypeScript fixable issues |
| `<leader>tR` | Rename file | Rename file and update imports |
| `<leader>ts` | Go to source definition | Navigate to source definition |
| `<leader>tc` | TypeScript check | Run TypeScript compiler check |
| `<leader>tC` | TypeScript check (open) | Run TypeScript check and open results |
| `<leader>tw` | TypeScript watch | Start TypeScript watch mode |

### Next.js File Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>np` | Find pages | Find pages in pages/app directory |
| `<leader>nc` | Find components | Find components in components directory |
| `<leader>na` | Find API routes | Find API routes in pages/api or app/api |
| `<leader>nh` | Find hooks | Find custom hooks in hooks directory |
| `<leader>nu` | Find utils | Find utilities in utils/lib directory |
| `<leader>ns` | Find styles | Find styles in styles directory |
| `<leader>nt` | Find types | Find TypeScript types in types directory |
| `<leader>nr` | Switch to related file | Switch between component/test, page/API |

### Next.js Component Templates
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ncc` | Create component | Generate React component template |
| `<leader>ncp` | Create page | Generate Next.js page template |
| `<leader>nca` | Create API route | Generate Next.js API route template |
| `<leader>nch` | Create hook | Generate custom hook template |

### Package Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>Pi` | Install dependencies | Install all dependencies |
| `<leader>Pa` | Add dependency | Add new dependency |
| `<leader>Pd` | Add dev dependency | Add new dev dependency |
| `<leader>Pr` | Remove dependency | Remove dependency |
| `<leader>Ps` | Run script | Show script picker and run |
| `<leader>Pm` | Show package manager | Display detected package manager |

### Quick Package Scripts
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>Psd` | Run dev | Run development server |
| `<leader>Psb` | Run build | Run build process |
| `<leader>Pst` | Run test | Run test suite |
| `<leader>Psl` | Run lint | Run linting |
| `<leader>Pss` | Run start | Run start script |

### Package.json Integration
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>pv` | Show package versions | Display package version info |
| `<leader>ph` | Hide package versions | Hide package version info |
| `<leader>pt` | Toggle package versions | Toggle package version display |
| `<leader>pu` | Update package | Update package under cursor |
| `<leader>pd` | Delete package | Delete package under cursor |
| `<leader>pi` | Install package | Install package under cursor |
| `<leader>pc` | Change package version | Change package version |

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

## 🎨 Visual Enhancements

### Rainbow Brackets
The configuration includes rainbow bracket highlighting for better code hierarchy visualization:
- **Plugin**: `HiPhish/rainbow-delimiters.nvim`
- **Strategy**: Global rainbow delimiters with language-specific queries
- **Colors**: 7-color rotation (Red, Yellow, Blue, Orange, Green, Violet, Cyan)
- **Language Support**: Special queries for Lua, TypeScript, JavaScript, TSX, JSX
- **Blacklisted**: HTML and XML files (to avoid conflicts)

### Spell Checking
Smart spell checking that only activates in appropriate contexts:
- **Plugin**: `lewis6991/spellsitter.nvim`
- **Context-aware**: Only checks comments, strings, and documentation
- **Language**: English (en) dictionary
- **Ignored Patterns**: URLs, email addresses, file paths, hex colors, code patterns
- **Treesitter Integration**: Uses treesitter capture groups for precision

### TypeScript/Next.js Enhancements
Advanced TypeScript and Next.js development features:
- **Plugin**: `pmizio/typescript-tools.nvim` for comprehensive TypeScript support
- **Auto-imports**: Automatic import organization, addition, and removal
- **Type Checking**: Integrated TypeScript compiler with real-time diagnostics
- **Template Generation**: Ready-to-use templates for components, pages, API routes, and hooks
- **File Navigation**: Quick access to pages, components, API routes, hooks, utils, and types
- **Smart Switching**: Intelligent file switching between related files (component ↔ test, page ↔ API)
- **JSX Support**: Auto-tag closing and template string conversion
- **Inlay Hints**: Parameter names, types, and return type hints for better code understanding

### Package Management Integration
Comprehensive package management with automatic detection:
- **Plugin**: `vuki656/package-info.nvim` for package.json integration
- **Smart Detection**: Automatically detects npm, yarn, pnpm, or bun based on lock files
- **Script Runner**: Quick access to package.json scripts with picker interface
- **Dependency Management**: Add, remove, and update dependencies directly from editor
- **Version Display**: Show package versions inline in package.json
- **Terminal Integration**: Uses Snacks terminal for better command execution experience
- **Quick Scripts**: One-key access to common scripts (dev, build, test, lint, start)

## 🔧 Auto-commands

### Smart Behaviors
- **Highlight on yank**: Brief highlight when copying text (200ms)
- **Auto-resize splits**: Automatically balance windows when terminal is resized
- **Remember cursor position**: Return to last cursor position when reopening files
- **Auto-reload files**: Detect and reload files changed outside Neovim
- **Quick close**: Press `q` to close help, man pages, and info windows
- **Auto-save**: Intelligent auto-save on buffer switch, focus lost, and idle timeout

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
│       ├── multicursor.lua # Multi-cursor editing
│       ├── bookmarks.lua   # Bookmark system
│       ├── spell.lua       # Smart spell checking
│       ├── clipboard.lua   # Enhanced clipboard management
│       ├── rainbow.lua     # Rainbow bracket highlighting
│       ├── typescript.lua  # TypeScript tools and enhancements
│       ├── nextjs.lua      # Next.js navigation and templates
│       ├── package-manager.lua # Package management integration
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
8. **Multi-cursor**: Use `<C-d>` on a word to add cursors, `<C-x>` to skip, `<C-p>` to remove
9. **Bookmarks**: Use `<space>mm` to bookmark important lines, `<space>ma` to see all
10. **Clipboard history**: Use `<space>fy` to access previous yanks, `[y`/`]y` to cycle through
11. **Spell checking**: Use `<space>us` to toggle, `]s` to jump to errors, `z=` for suggestions
12. **Code actions**: Use `<space>ca` for quick fixes, `<space>qf` for preferred actions
13. **Diagnostic filtering**: Use `[e`/`]e` for errors only, `[w`/`]w` for warnings only
14. **TypeScript workflow**: Use `<space>to` to organize imports, `<space>tf` to fix all issues
15. **Next.js navigation**: Use `<space>nc` for components, `<space>np` for pages, `<space>na` for API routes
16. **Component templates**: Use `<space>ncc` for components, `<space>ncp` for pages, `<space>nca` for API routes
17. **Package management**: Use `<space>Ps` for script runner, `<space>Pa` to add deps, `<space>Pi` to install
18. **Quick scripts**: Use `<space>Psd` for dev, `<space>Psb` for build, `<space>Pst` for test

## 📝 Notes

- All keybindings use `<leader>` which is mapped to the space key
- Visual mode selections work with most text manipulation commands
- The configuration maintains LazyVim defaults while adding enhancements
- Claude Code integration provides seamless AI assistance workflow
- Snacks.nvim adds modern UI components and smooth animations
- Auto-save works intelligently and only saves when necessary
- Multi-cursor editing provides VSCode-like multiple selection capabilities
- Bookmark system persists across sessions and supports annotations
- Clipboard history maintains 100 entries with persistent storage
- Spell checking uses treesitter for context-aware operation
- Rainbow brackets improve code readability with 7-color rotation
- TypeScript tools provide comprehensive import management and type checking
- Next.js integration offers smart file navigation and template generation
- Package management automatically detects npm/yarn/pnpm/bun and provides unified interface
- Component templates include TypeScript types and Next.js best practices
