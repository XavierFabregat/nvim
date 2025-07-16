-- Package management integration for npm/yarn/pnpm
return {
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "json",
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
          invalid = "#ee4b2b",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
            invalid = "|  ",
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = "npm",
      })
    end,
    keys = {
      { "<leader>pv", "<cmd>lua require('package-info').show()<cr>", desc = "Show package versions" },
      { "<leader>ph", "<cmd>lua require('package-info').hide()<cr>", desc = "Hide package versions" },
      { "<leader>pt", "<cmd>lua require('package-info').toggle()<cr>", desc = "Toggle package versions" },
      { "<leader>pu", "<cmd>lua require('package-info').update()<cr>", desc = "Update package" },
      { "<leader>pd", "<cmd>lua require('package-info').delete()<cr>", desc = "Delete package" },
      { "<leader>pi", "<cmd>lua require('package-info').install()<cr>", desc = "Install package" },
      { "<leader>pc", "<cmd>lua require('package-info').change_version()<cr>", desc = "Change package version" },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Package manager detection
      local function detect_package_manager()
        local package_managers = {
          { file = "pnpm-lock.yaml", cmd = "pnpm" },
          { file = "yarn.lock", cmd = "yarn" },
          { file = "bun.lockb", cmd = "bun" },
          { file = "package-lock.json", cmd = "npm" },
          { file = "package.json", cmd = "npm" }, -- fallback
        }
        
        for _, pm in ipairs(package_managers) do
          if vim.fn.filereadable(pm.file) == 1 then
            return pm.cmd
          end
        end
        
        return "npm" -- ultimate fallback
      end
      
      -- Run package manager scripts
      local function run_package_script(script_name)
        local pm = detect_package_manager()
        local cmd
        
        if pm == "npm" then
          cmd = "npm run " .. script_name
        elseif pm == "yarn" then
          cmd = "yarn " .. script_name
        elseif pm == "pnpm" then
          cmd = "pnpm " .. script_name
        elseif pm == "bun" then
          cmd = "bun run " .. script_name
        end
        
        if cmd then
          -- Use Snacks terminal for better integration
          if pcall(require, "snacks") then
            require("snacks").terminal.open({ cmd = cmd })
          else
            vim.cmd("terminal " .. cmd)
          end
        end
      end
      
      -- Get available scripts from package.json
      local function get_package_scripts()
        local package_json = vim.fn.readfile("package.json")
        if not package_json then return {} end
        
        local content = table.concat(package_json, "\n")
        local ok, decoded = pcall(vim.json.decode, content)
        if not ok or not decoded.scripts then return {} end
        
        local scripts = {}
        for name, _ in pairs(decoded.scripts) do
          table.insert(scripts, name)
        end
        
        return scripts
      end
      
      -- Package manager commands
      local function install_dependencies()
        local pm = detect_package_manager()
        local cmd = pm == "npm" and "npm install" or pm == "yarn" and "yarn install" or pm == "pnpm" and "pnpm install" or "bun install"
        
        if pcall(require, "snacks") then
          require("snacks").terminal.open({ cmd = cmd })
        else
          vim.cmd("terminal " .. cmd)
        end
      end
      
      local function add_dependency(dev)
        local pm = detect_package_manager()
        local package_name = vim.fn.input("Package name: ")
        if package_name == "" then return end
        
        local cmd
        if pm == "npm" then
          cmd = dev and "npm install --save-dev " .. package_name or "npm install " .. package_name
        elseif pm == "yarn" then
          cmd = dev and "yarn add --dev " .. package_name or "yarn add " .. package_name
        elseif pm == "pnpm" then
          cmd = dev and "pnpm add --save-dev " .. package_name or "pnpm add " .. package_name
        elseif pm == "bun" then
          cmd = dev and "bun add --dev " .. package_name or "bun add " .. package_name
        end
        
        if cmd then
          if pcall(require, "snacks") then
            require("snacks").terminal.open({ cmd = cmd })
          else
            vim.cmd("terminal " .. cmd)
          end
        end
      end
      
      local function remove_dependency()
        local pm = detect_package_manager()
        local package_name = vim.fn.input("Package name to remove: ")
        if package_name == "" then return end
        
        local cmd
        if pm == "npm" then
          cmd = "npm uninstall " .. package_name
        elseif pm == "yarn" then
          cmd = "yarn remove " .. package_name
        elseif pm == "pnpm" then
          cmd = "pnpm remove " .. package_name
        elseif pm == "bun" then
          cmd = "bun remove " .. package_name
        end
        
        if cmd then
          if pcall(require, "snacks") then
            require("snacks").terminal.open({ cmd = cmd })
          else
            vim.cmd("terminal " .. cmd)
          end
        end
      end
      
      local function run_script_picker()
        local scripts = get_package_scripts()
        if #scripts == 0 then
          vim.notify("No scripts found in package.json", vim.log.levels.WARN)
          return
        end
        
        vim.ui.select(scripts, {
          prompt = "Select script to run:",
          format_item = function(item)
            return item
          end,
        }, function(choice)
          if choice then
            run_package_script(choice)
          end
        end)
      end
      
      -- Create user commands
      vim.api.nvim_create_user_command("PackageInstall", install_dependencies, {})
      vim.api.nvim_create_user_command("PackageAdd", function() add_dependency(false) end, {})
      vim.api.nvim_create_user_command("PackageAddDev", function() add_dependency(true) end, {})
      vim.api.nvim_create_user_command("PackageRemove", remove_dependency, {})
      vim.api.nvim_create_user_command("PackageRun", run_script_picker, {})
      
      -- Keybindings for package management
      vim.keymap.set("n", "<leader>Pi", install_dependencies, { desc = "Install dependencies" })
      vim.keymap.set("n", "<leader>Pa", function() add_dependency(false) end, { desc = "Add dependency" })
      vim.keymap.set("n", "<leader>Pd", function() add_dependency(true) end, { desc = "Add dev dependency" })
      vim.keymap.set("n", "<leader>Pr", remove_dependency, { desc = "Remove dependency" })
      vim.keymap.set("n", "<leader>Ps", run_script_picker, { desc = "Run script" })
      
      -- Quick access to common scripts
      vim.keymap.set("n", "<leader>Psd", function() run_package_script("dev") end, { desc = "Run dev script" })
      vim.keymap.set("n", "<leader>Psb", function() run_package_script("build") end, { desc = "Run build script" })
      vim.keymap.set("n", "<leader>Pst", function() run_package_script("test") end, { desc = "Run test script" })
      vim.keymap.set("n", "<leader>Psl", function() run_package_script("lint") end, { desc = "Run lint script" })
      vim.keymap.set("n", "<leader>Pss", function() run_package_script("start") end, { desc = "Run start script" })
      
      -- Show package manager info
      vim.keymap.set("n", "<leader>Pm", function()
        local pm = detect_package_manager()
        vim.notify("Detected package manager: " .. pm, vim.log.levels.INFO)
      end, { desc = "Show package manager" })
    end,
  },
}