-- Enhanced clipboard management with history
return {
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
    config = function()
      require("neoclip").setup({
        -- Number of entries to keep in history
        history = 100,
        -- Enable persistent history across sessions
        enable_persistent_history = true,
        -- Length of preview in telescope
        length_limit = 1000,
        -- Continuous sync with system clipboard
        continuous_sync = true,
        -- Database path for persistent history
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
        -- Filter out certain entries
        filter = nil,
        -- Preview settings
        preview = true,
        -- Prompt for confirmation when selecting from history
        prompt = "Neoclip",
        -- Default register to use
        default_register = '"',
        -- Default register for macros
        default_register_macros = "q",
        -- Enable macro history
        enable_macro_history = true,
        -- Content spec for different types
        content_spec = {
          -- For regular yanks
          ['"'] = {
            lines = 1,
            chars = 50,
          },
          -- For system clipboard
          ["+"] = {
            lines = 1,
            chars = 50,
          },
          -- For selection clipboard
          ["*"] = {
            lines = 1,
            chars = 50,
          },
        },
        -- Disable for certain filetypes
        disable_for = {},
      })
      
      -- Load telescope extension
      require("telescope").load_extension("neoclip")
    end,
    keys = {
      { "<leader>fy", "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
      { "<leader>fY", "<cmd>Telescope neoclip plus<cr>", desc = "System clipboard history" },
      { "<leader>fm", "<cmd>Telescope neoclip macros<cr>", desc = "Macro history" },
    },
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
    config = function()
      require("yanky").setup({
        -- Ring settings
        ring = {
          history_length = 100,
          storage = "shada",
          sync_with_numbered_registers = true,
          cancel_event = "update",
        },
        -- Picker settings
        picker = {
          select = {
            action = nil,
          },
          telescope = {
            use_default_mappings = true,
            mappings = {
              default = require("yanky.telescope.mapping").put("p"),
              i = {
                ["<c-g>"] = require("yanky.telescope.mapping").put("p"),
                ["<c-k>"] = require("yanky.telescope.mapping").put("P"),
                ["<c-x>"] = require("yanky.telescope.mapping").delete(),
                ["<c-r>"] = require("yanky.telescope.mapping").set_register(),
              },
              n = {
                p = require("yanky.telescope.mapping").put("p"),
                P = require("yanky.telescope.mapping").put("P"),
                d = require("yanky.telescope.mapping").delete(),
                r = require("yanky.telescope.mapping").set_register(),
              },
            },
          },
        },
        -- System clipboard integration
        system_clipboard = {
          sync_with_ring = true,
        },
        -- Highlight settings
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 300,
        },
        -- Preserve cursor position
        preserve_cursor_position = {
          enabled = true,
        },
      })
      
      -- Load telescope extension
      require("telescope").load_extension("yank_history")
    end,
    keys = {
      { "<leader>p", "<Plug>(YankyPutAfter)", desc = "Put after" },
      { "<leader>P", "<Plug>(YankyPutBefore)", desc = "Put before" },
      { "<leader>gp", "<Plug>(YankyGPutAfter)", desc = "Put after (leave cursor)" },
      { "<leader>gP", "<Plug>(YankyGPutBefore)", desc = "Put before (leave cursor)" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Yank history" },
    },
  },
}