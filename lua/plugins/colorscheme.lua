return {
  -- Configure LazyVim to use cyberdream
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },

  -- Keep tokyonight installed as fallback (LazyVim dependency)
  { "folke/tokyonight.nvim", lazy = true },

  -- Cyberdream - high-contrast, modern colorscheme
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Enable transparent background
      transparent = true,
      -- Use italics for comments for a modern look
      italic_comments = true,
      -- Show fillchars for visible window separators
      hide_fillchars = false,
      -- Modern borderless pickers (telescope, fzf, etc.)
      borderless_pickers = false,
      -- Enable terminal colors
      terminal_colors = true,
      -- Cache highlights for faster startup
      cache = false,
      -- Theme extensions for plugins (using correct extension names)
      extensions = {
        alpha = true,
        blinkcmp = true,
        cmp = true,
        dashboard = true,
        fzflua = true,
        gitsigns = true,
        indentblankline = true,
        lazy = true,
        markdown = true,
        mini = true,
        noice = true,
        notify = true,
        rainbow_delimiters = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesittercontext = true,
        trouble = true,
        whichkey = true,
      },
    },
  },
}
