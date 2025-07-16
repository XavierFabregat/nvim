-- Enhanced clipboard management with history
return {
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
      
      -- Load telescope extension with error handling
      local ok, telescope = pcall(require, "telescope")
      if ok then
        telescope.load_extension("yank_history")
      end
    end,
    keys = {
      { "<leader>p", "<Plug>(YankyPutAfter)", desc = "Put after" },
      { "<leader>P", "<Plug>(YankyPutBefore)", desc = "Put before" },
      { "<leader>gp", "<Plug>(YankyGPutAfter)", desc = "Put after (leave cursor)" },
      { "<leader>gP", "<Plug>(YankyGPutBefore)", desc = "Put before (leave cursor)" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Clipboard history" },
    },
  },
}