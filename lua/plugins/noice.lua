-- Modern UI overhaul for cmdline, messages, and notifications
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        -- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        -- Signature help
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
        },
        -- Hover documentation
        hover = {
          enabled = true,
        },
        -- Progress messages
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30,
        },
      },
      -- Beautiful command line
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        },
      },
      -- Message handling
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      -- Popup menu
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      -- Routes for message handling
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d fewer lines" },
              { find = "%d more lines" },
            },
          },
          opts = { skip = true },
        },
      },
      -- Presets for easier configuration
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      -- Transparency settings
      views = {
        cmdline_popup = {
          border = {
            style = "rounded",
          },
          win_options = {
            winblend = 0,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
        popupmenu = {
          border = {
            style = "rounded",
          },
          win_options = {
            winblend = 0,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      },
    },
    keys = {
      { "<leader>sn", "<cmd>Noice<cr>", desc = "Noice Message History" },
      { "<leader>snl", "<cmd>NoiceLast<cr>", desc = "Noice Last Message" },
      { "<leader>snd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss All Notifications" },
      { "<leader>sne", "<cmd>NoiceErrors<cr>", desc = "Noice Errors" },
    },
  },
}
