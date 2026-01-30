-- Dressing.nvim - Beautiful UI for vim.ui.select and vim.ui.input
return {
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
    opts = {
      input = {
        -- Set to false to disable the vim.ui.input implementation
        enabled = true,
        -- Default prompt string
        default_prompt = "Input",
        -- Trim trailing `:` from prompt
        trim_prompt = true,
        -- Can be 'left', 'right', or 'center'
        title_pos = "center",
        -- When true, <Esc> will close the modal
        insert_only = true,
        -- When true, input will start in insert mode
        start_in_insert = true,
        -- These are passed to nvim_open_win
        border = "rounded",
        -- 'editor' and 'win' will default to being centered
        relative = "cursor",
        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        buf_options = {},
        win_options = {
          -- Disable line wrapping
          wrap = false,
          -- Indicator for when text exceeds window
          list = true,
          listchars = "precedes:…,extends:…",
          -- Increase this for more context
          sidescrolloff = 0,
          -- Transparency
          winblend = 0,
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
        -- Set to `false` to disable
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          i = {
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
            ["<Up>"] = "HistoryPrev",
            ["<Down>"] = "HistoryNext",
          },
        },
        override = function(conf)
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          return conf
        end,
        -- see :help dressing_get_config
        get_config = nil,
      },
      select = {
        -- Set to false to disable the vim.ui.select implementation
        enabled = true,
        -- Priority list of preferred vim.select implementations
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        -- Trim trailing `:` from prompt
        trim_prompt = true,
        -- Options for telescope selector
        telescope = require("telescope.themes").get_dropdown({
          layout_config = {
            width = 0.8,
            height = 0.8,
          },
          borderchars = {
            prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          },
        }),
        -- Options for fzf-lua selector
        fzf_lua = {
          winopts = {
            height = 0.5,
            width = 0.5,
          },
        },
        -- Options for nui Menu
        nui = {
          position = "50%",
          size = nil,
          relative = "editor",
          border = {
            style = "rounded",
          },
          buf_options = {
            swapfile = false,
            filetype = "DressingSelect",
          },
          win_options = {
            winblend = 0,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
          max_width = 80,
          max_height = 40,
          min_width = 40,
          min_height = 10,
        },
        -- Options for built-in selector
        builtin = {
          border = "rounded",
          relative = "editor",
          buf_options = {},
          win_options = {
            winblend = 0,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
          width = nil,
          max_width = { 140, 0.8 },
          min_width = { 40, 0.2 },
          height = nil,
          max_height = 0.9,
          min_height = { 10, 0.2 },
          mappings = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          override = function(conf)
            return conf
          end,
        },
        -- Used to override format_item. See :help dressing-format
        format_item_override = {},
        -- see :help dressing_get_config
        get_config = nil,
      },
    },
  },
}
