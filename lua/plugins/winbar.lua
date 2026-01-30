-- Winbar with breadcrumbs showing code context
return {
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    opts = {
      theme = "auto",
      include_buftypes = { "" },
      exclude_filetypes = {
        "gitcommit",
        "toggleterm",
        "neo-tree",
        "dashboard",
        "lazy",
        "mason",
        "notify",
        "snacks_dashboard",
      },
      show_modified = true,
      show_dirname = true,
      show_basename = true,
      modifiers = {
        dirname = ":~:.",
        basename = "",
      },
      symbols = {
        modified = "●",
        ellipsis = "…",
        separator = "",
      },
      kinds = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = "◩ ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = "ﳠ ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      },
    },
    config = function(_, opts)
      require("barbecue").setup(opts)

      -- Custom highlight groups for transparency
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "Winbar", { bg = "none" })
          vim.api.nvim_set_hl(0, "WinbarNC", { bg = "none" })
        end,
      })
    end,
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      separator = "  ",
      highlight = true,
      depth_limit = 5,
      depth_limit_indicator = "..",
      safe_output = true,
      lazy_update_context = true,
      click = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Attach navic to LSP
      vim.g.navic_silence = true

      local on_attach = opts.on_attach
      opts.on_attach = function(client, buffer)
        if on_attach then
          on_attach(client, buffer)
        end

        if client.supports_method("textDocument/documentSymbol") then
          local navic_ok, navic = pcall(require, "nvim-navic")
          if navic_ok then
            navic.attach(client, buffer)
          end
        end
      end

      return opts
    end,
  },
}
