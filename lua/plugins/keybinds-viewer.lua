-- Interactive keybindings viewer with real-time filtering
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local M = {}
      M.search_query = ""
      M.buf = nil
      M.win = nil

      -- Get all keymaps
      local function get_all_keymaps()
        local all_maps = {}

        for _, mode in ipairs({ "n", "v", "i", "t" }) do
          local keymaps = vim.api.nvim_get_keymap(mode)

          for _, map in ipairs(keymaps) do
            local key = map.lhs or ""
            local desc = map.desc or map.rhs or ""

            -- Skip internal/unmapped keys
            if key ~= "" and not key:match("^<Plug>") and not key:match("^<SNR>") then
              table.insert(all_maps, {
                mode = mode,
                key = key:gsub("<leader>", "<space>"):gsub(" ", "<space>"),
                desc = desc,
                raw_key = key,
              })
            end
          end
        end

        return all_maps
      end

      -- Filter keymaps based on search query
      local function filter_keymaps(query)
        local all = get_all_keymaps()

        if query == "" then
          return all
        end

        local filtered = {}
        local search_lower = query:lower()

        for _, map in ipairs(all) do
          local key_lower = map.key:lower()
          local desc_lower = map.desc:lower()

          -- Check if query matches key or description
          if key_lower:match(search_lower) or desc_lower:match(search_lower) then
            table.insert(filtered, map)
          end
        end

        return filtered
      end

      -- Update the display
      local function update_display()
        if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
          return
        end

        local filtered = filter_keymaps(M.search_query)

        -- Sort by mode then key
        table.sort(filtered, function(a, b)
          if a.mode ~= b.mode then
            return a.mode < b.mode
          end
          return a.key < b.key
        end)

        local lines = {}

        -- Header
        table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        table.insert(lines, "                           ⚡ KEYBINDINGS SEARCH ⚡")
        table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        table.insert(lines, "")

        -- Search box
        local search_display = M.search_query == "" and "Type to filter..." or M.search_query
        table.insert(lines, "  Search: " .. search_display .. "▊")
        table.insert(lines, "")
        table.insert(lines, string.rep("─", 75))
        table.insert(lines, "")

        -- Results
        if #filtered == 0 then
          table.insert(lines, "")
          table.insert(lines, "  No keybindings found matching: " .. M.search_query)
          table.insert(lines, "")
        else
          table.insert(lines, "  Found " .. #filtered .. " keybindings:")
          table.insert(lines, "")

          local current_mode = nil
          for _, map in ipairs(filtered) do
            -- Mode header
            if map.mode ~= current_mode then
              current_mode = map.mode
              local mode_names = { n = "NORMAL", v = "VISUAL", i = "INSERT", t = "TERMINAL" }
              table.insert(lines, "")
              table.insert(lines, "  ▸ " .. (mode_names[map.mode] or map.mode) .. " MODE")
              table.insert(lines, "  " .. string.rep("─", 70))
            end

            -- Keybinding with mode badge
            local mode_badge = string.format("[%s]", map.mode:upper())
            local key_display = string.format("    %-4s %-28s", mode_badge, map.key)
            table.insert(lines, key_display .. " → " .. map.desc)
          end
        end

        table.insert(lines, "")
        table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        table.insert(lines, "  Type to filter • <BS> to delete • <Esc> to close • <C-c> to clear")
        table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        -- Update buffer
        vim.api.nvim_buf_set_option(M.buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(M.buf, "modifiable", false)
      end

      -- Show keybindings viewer
      local function show_keybinds()
        M.search_query = ""

        -- Create buffer
        M.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
        vim.api.nvim_buf_set_option(M.buf, "filetype", "keybinds")

        -- Create centered floating window
        local width = math.min(100, math.floor(vim.o.columns * 0.85))
        local height = math.min(45, math.floor(vim.o.lines * 0.85))

        M.win = vim.api.nvim_open_win(M.buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = math.floor((vim.o.columns - width) / 2),
          row = math.floor((vim.o.lines - height) / 2),
          style = "minimal",
          border = "rounded",
          title = " Keybindings Explorer ",
          title_pos = "center",
        })

        -- Window options
        vim.api.nvim_win_set_option(M.win, "winblend", 0)
        vim.api.nvim_win_set_option(M.win, "winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder")
        vim.api.nvim_win_set_option(M.win, "cursorline", false)

        -- Initial display
        update_display()

        -- Set up keybindings
        local function close_window()
          if M.win and vim.api.nvim_win_is_valid(M.win) then
            vim.api.nvim_win_close(M.win, true)
          end
          M.win = nil
          M.buf = nil
          M.search_query = ""
        end

        -- Close on escape
        vim.api.nvim_buf_set_keymap(M.buf, "n", "<Esc>", "", {
          noremap = true,
          silent = true,
          callback = close_window,
        })

        -- Clear search on Ctrl-C
        vim.api.nvim_buf_set_keymap(M.buf, "n", "<C-c>", "", {
          noremap = true,
          silent = true,
          callback = function()
            M.search_query = ""
            update_display()
          end,
        })

        -- Backspace to delete last character
        vim.api.nvim_buf_set_keymap(M.buf, "n", "<BS>", "", {
          noremap = true,
          silent = true,
          callback = function()
            if #M.search_query > 0 then
              M.search_query = M.search_query:sub(1, -2)
              update_display()
            end
          end,
        })

        -- Capture all printable characters for search
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_<>[](){}:;'\",.?/\\|`~!@#$%^&*+= "
        for i = 1, #chars do
          local char = chars:sub(i, i)
          vim.api.nvim_buf_set_keymap(M.buf, "n", char, "", {
            noremap = true,
            silent = true,
            callback = function()
              M.search_query = M.search_query .. char
              update_display()
            end,
          })
        end

        -- Scrolling
        vim.api.nvim_buf_set_keymap(M.buf, "n", "j", "j", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.buf, "n", "k", "k", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.buf, "n", "<C-d>", "<C-d>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.buf, "n", "<C-u>", "<C-u>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.buf, "n", "gg", "gg", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.buf, "n", "G", "G", { noremap = true, silent = true })
      end

      -- Create commands
      vim.api.nvim_create_user_command("Keybinds", show_keybinds, { desc = "Show all keybindings" })
      vim.api.nvim_create_user_command("Keys", show_keybinds, { desc = "Show all keybindings" })

      -- Add keybinding
      vim.keymap.set("n", "<leader>sk", show_keybinds, { desc = "Show All Keybindings" })

      return opts
    end,
  },
}
