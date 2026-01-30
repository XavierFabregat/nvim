-- Flash.nvim - Enhanced navigation and search
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      -- Default configuration
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        multi_window = true,
        forward = true,
        wrap = true,
        mode = "exact",
        incremental = false,
      },
      jump = {
        jumplist = true,
        pos = "start",
        history = false,
        register = false,
        nohlsearch = false,
        autojump = false,
      },
      label = {
        uppercase = true,
        exclude = "",
        current = true,
        after = true,
        before = false,
        style = "overlay",
        reuse = "lowercase",
        distance = true,
        min_pattern_length = 0,
        rainbow = {
          enabled = true,
          shade = 5,
        },
      },
      highlight = {
        backdrop = true,
        matches = true,
        priority = 5000,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T", ";" },
          search = { wrap = false },
          highlight = { backdrop = true },
          jump = { register = false },
        },
        treesitter = {
          labels = "abcdefghijklmnopqrstuvwxyz",
          jump = { pos = "range" },
          search = { incremental = false },
          label = { before = true, after = true, style = "inline" },
          highlight = {
            backdrop = false,
            matches = false,
          },
        },
        treesitter_search = {
          jump = { pos = "range" },
          search = { multi_window = true, wrap = true, incremental = false },
          remote_op = { restore = true },
          label = { before = true, after = true, style = "inline" },
        },
      },
      prompt = {
        enabled = true,
        prefix = { { "⚡", "FlashPromptIcon" } },
        win_config = {
          relative = "editor",
          width = 1,
          height = 1,
          row = -1,
          col = 0,
          zindex = 1000,
        },
      },
    },
    keys = {
      -- Primary jump key (using 's' by default - see comment below to change to 'w')
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash Jump",
      },

      -- ALTERNATIVE: Uncomment these lines and comment out the 's' mapping above to use 'w' instead:
      -- {
      --   "w",
      --   mode = { "n", "x", "o" },
      --   function()
      --     require("flash").jump()
      --   end,
      --   desc = "Flash Jump",
      -- },

      -- Treesitter selection (select code blocks)
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },

      -- Remote operation (like d{motion} but with flash)
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },

      -- Treesitter search
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },

      -- Toggle flash search in command mode
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)

      -- Custom highlight colors to match your theme
      vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "#545c7e" })
      vim.api.nvim_set_hl(0, "FlashMatch", { bg = "#7c3aed", fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "FlashCurrent", { bg = "#a855f7", fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#ff007c", fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = "#7c3aed", bold = true })
    end,
  },
}
