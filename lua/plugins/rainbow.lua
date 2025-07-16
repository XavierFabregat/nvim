-- Rainbow brackets for visual hierarchy
return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          tsx = "rainbow-parens",
          jsx = "rainbow-parens",
          typescript = "rainbow-parens",
          javascript = "rainbow-parens",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow", 
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
        -- Blacklist certain filetypes
        blacklist = { "html", "xml" },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure we have queries for rainbow delimiters
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "query",
      })
    end,
  },
}