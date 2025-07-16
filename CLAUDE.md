# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration based on LazyVim with extensive customizations for enhanced productivity. The configuration includes Claude Code integration, modern UI enhancements via Snacks.nvim, and numerous quality-of-life improvements.

## Architecture

### Configuration Structure
- **Entry Point**: `init.lua` - Bootstraps lazy.nvim and loads core configurations
- **Core Config**: `lua/config/` - Contains fundamental Neovim settings
  - `lazy.lua` - Plugin manager setup with LazyVim integration
  - `options.lua` - Enhanced editor settings, transparency, scrolling, search improvements
  - `keymaps.lua` - Custom keybindings for productivity
  - `autocmds.lua` - Automated behaviors and file handling
  - `colorscheme.lua` & `highlights.lua` - Visual theming
- **Plugins**: `lua/plugins/` - Plugin configurations extending LazyVim
  - `claudecode.lua` - Claude Code integration with comprehensive keybindings
  - `snacks.lua` - Modern UI components (terminal, notifications, zen mode, etc.)
  - Other plugin overrides and extensions

### Plugin Management
- Uses lazy.nvim as the plugin manager
- Built on LazyVim foundation with custom plugin overrides
- Plugin updates managed via lazy.nvim with update checking enabled
- Version locking via `lazy-lock.json`

### Key Integrations
- **Claude Code**: Seamless AI assistance with dedicated keybinding namespace (`<leader>a`)
- **Snacks.nvim**: Modern UI components replacing built-in functionality
- **LazyVim**: Base configuration providing sensible defaults

## Development Commands

### Neovim Operations
- **Start Neovim**: `nvim` (configuration loads automatically)
- **Plugin Management**: 
  - `:Lazy` - Open plugin manager
  - `:Lazy update` - Update plugins
  - `:Lazy clean` - Remove unused plugins
- **Configuration Reload**: `:source %` (when editing config files)

### Code Formatting
- **Lua Formatting**: Uses StyLua (configured in `stylua.toml`)
  - Indent: 2 spaces
  - Column width: 120 characters
  - Format command: `stylua .` (if StyLua is installed)

### Testing Configuration
- Test changes by opening Neovim and verifying:
  - Plugin loading (`:Lazy` to check status)
  - Keybindings work as expected
  - No error messages on startup
  - Claude Code integration functional (`<space>ac`)

## Key Features for Development

### Claude Code Integration (Terminal-based)
- **Primary Shortcut**: `<C-k>` - Chat with Claude (main interaction)
- **Plugin**: Uses `greggh/claude-code.nvim` for stable terminal-based integration
- **Core Operations**: 
  - Toggle (`<leader>ac`) - Opens Claude Code terminal
  - Resume (`<leader>ar`) - Show conversation picker
  - Continue (`<leader>aC`) - Resume recent conversation
  - Verbose (`<leader>av`) - Enable verbose logging
- **Configuration**: 
  - Terminal positioned on right side (40% width)
  - Auto-detects git projects
  - Auto-refreshes modified files
  - Uses standard Claude Code CLI commands

### Quality of Life Enhancements
- **Enhanced Navigation**: Smooth scrolling, better search centering
- **Smart Auto-commands**: Highlight on yank, auto-resize splits, cursor position memory
- **Better Defaults**: Persistent undo, faster timeouts, auto-write, confirmation dialogs
- **Visual Improvements**: Transparency support, relative line numbers, invisible character display

### Modern UI Components (Snacks.nvim)
- **Terminal**: Bottom-positioned terminal (`<C-/>`)
- **Zen Mode**: Distraction-free coding (`<leader>z`)
- **Notifications**: Enhanced notification system with history
- **Git Integration**: Browse, blame, file history
- **File Explorer**: Modern sidebar replacing netrw

## Configuration Guidelines

### Adding New Plugins
1. Create plugin file in `lua/plugins/`
2. Follow LazyVim plugin specification format
3. Use lazy loading when appropriate
4. Add keybindings with descriptive names for which-key integration

### Modifying Keybindings
- Preserve existing `<leader>a` namespace for Claude Code
- Use descriptive names for which-key display
- Consider both normal and visual mode variants
- Test for conflicts with LazyVim defaults

### Customizing Options
- Add new options to `lua/config/options.lua`
- Group related settings together
- Include comments explaining non-obvious settings
- Test changes don't conflict with plugin expectations

## File Organization
- **Configuration**: Files in `lua/config/` for core Neovim settings
- **Plugins**: Individual plugin files in `lua/plugins/`
- **Documentation**: `CUSTOMIZATION.md` contains detailed user-facing documentation
- **Locking**: `lazy-lock.json` ensures reproducible plugin versions
- **Settings**: `lazyvim.json` for LazyVim-specific configuration

## Development Workflow
1. Edit configuration files
2. Reload Neovim or use `:source %` for immediate changes
3. Test functionality, especially keybindings and plugin interactions
4. Update documentation if adding new features
5. Commit changes with descriptive messages