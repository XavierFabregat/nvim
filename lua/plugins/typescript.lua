-- TypeScript and Next.js enhancements
return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      on_attach = function(client, bufnr)
        -- Auto-import organization
        vim.keymap.set("n", "<leader>to", function()
          vim.cmd("TSToolsOrganizeImports")
        end, { buffer = bufnr, desc = "Organize imports" })
        
        -- Remove unused imports
        vim.keymap.set("n", "<leader>tr", function()
          vim.cmd("TSToolsRemoveUnusedImports")
        end, { buffer = bufnr, desc = "Remove unused imports" })
        
        -- Add missing imports
        vim.keymap.set("n", "<leader>ta", function()
          vim.cmd("TSToolsAddMissingImports")
        end, { buffer = bufnr, desc = "Add missing imports" })
        
        -- Fix all fixable errors
        vim.keymap.set("n", "<leader>tf", function()
          vim.cmd("TSToolsFixAll")
        end, { buffer = bufnr, desc = "Fix all issues" })
        
        -- Rename file and update imports
        vim.keymap.set("n", "<leader>tR", function()
          vim.cmd("TSToolsRenameFile")
        end, { buffer = bufnr, desc = "Rename file" })
        
        -- Go to source definition
        vim.keymap.set("n", "<leader>ts", function()
          vim.cmd("TSToolsGoToSourceDefinition")
        end, { buffer = bufnr, desc = "Go to source definition" })
      end,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = {},
        tsserver_path = nil,
        tsserver_plugins = {},
        tsserver_max_memory = "auto",
        tsserver_format_options = {},
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        tsserver_locale = "en",
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        code_lens = "off",
        disable_member_code_lens = true,
        jsx_close_tag = {
          enable = false,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    },
  },
  {
    "dmmulroy/tsc.nvim",
    ft = { "typescript", "typescriptreact" },
    config = function()
      require("tsc").setup({
        auto_open_qflist = true,
        auto_close_qflist = false,
        auto_focus_qflist = false,
        auto_start_watch_mode = false,
        use_trouble_qflist = false,
      })
    end,
    keys = {
      { "<leader>tc", "<cmd>TSC<cr>", desc = "TypeScript check" },
      { "<leader>tC", "<cmd>TSCOpen<cr>", desc = "TypeScript check (open)" },
      { "<leader>tw", "<cmd>TSCWatch<cr>", desc = "TypeScript watch" },
    },
  },
  {
    "axelvc/template-string.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      require("template-string").setup({
        filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        jsx_brackets = true,
        remove_template_string = false,
        restore_quotes = {
          normal = [["]],
          jsx = [["]],
        },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "tsx", "jsx", "svelte", "vue", "markdown" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        per_filetype = {
          ["html"] = { enable_close = false },
        },
      })
    end,
  },
}