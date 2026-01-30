-- Beautiful indent guides with scope highlighting
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
        highlight = "IblIndent",
        smart_indent_cap = true,
        priority = 2,
      },
      whitespace = {
        highlight = "IblWhitespace",
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        char = "│",
        show_start = true,
        show_end = false,
        show_exact_scope = true,
        injected_languages = true,
        highlight = "IblScope",
        priority = 1024,
        include = {
          node_type = {
            ["*"] = {
              "argument_list",
              "arguments",
              "assignment_statement",
              "Block",
              "chunk",
              "class",
              "ContainerDecl",
              "dictionary",
              "do_block",
              "do_statement",
              "element",
              "except",
              "FnCallArguments",
              "for",
              "for_statement",
              "function",
              "function_declaration",
              "function_definition",
              "if_statement",
              "IfExpr",
              "import",
              "InitList",
              "list_literal",
              "method",
              "object",
              "ParamDeclList",
              "repeat_statement",
              "selector",
              "SwitchExpr",
              "table",
              "table_constructor",
              "try",
              "tuple",
              "type",
              "var",
              "while",
              "while_statement",
              "with",
            },
          },
        },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        buftypes = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)

      -- Custom colors for indent guides
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b4261", nocombine = true })
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#7c3aed", bold = true, nocombine = true })
        vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#2d3149", nocombine = true })
      end)
    end,
  },
}
