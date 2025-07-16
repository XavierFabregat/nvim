-- Smart spell checking for comments and strings
return {
  {
    "lewis6991/spellsitter.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("spellsitter").setup({
        -- Enable spell checking for these filetypes
        enable = true,
        -- Debug mode
        debug = false,
        -- Spell check these capture groups
        captures = {
          -- Comments
          "comment",
          -- Strings  
          "string",
          -- Documentation
          "doc",
          "documentation",
          -- Markdown-specific
          "text",
          "markdown",
        },
        -- Additional spell checking options
        spellcheck_lang = "en",
        -- Ignored patterns
        ignored_patterns = {
          -- URLs
          "https?://[%w-_%.%?%.:/%+=&]+",
          -- Email addresses
          "[%w-_%.%+]+@[%w-_%.]+%.[%w-_%.]+",
          -- File paths
          "[%w-_%.%/]+%.[%w-_%.]+",
          -- Hex colors
          "#[0-9a-fA-F]+",
          -- Numbers with units
          "%d+[px|em|rem|%|s|ms|kb|mb|gb]",
          -- Common code patterns
          "%w+%(%)",
          "%w+%[%]",
          "%w+%{%}",
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure we have the parsers needed for spell checking
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "comment",
        "markdown",
        "markdown_inline",
      })
    end,
  },
}