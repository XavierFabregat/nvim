-- Next.js specific enhancements
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- Next.js specific file navigation
      { "<leader>np", "<cmd>Telescope find_files search_dirs=pages,app<cr>", desc = "Find pages" },
      { "<leader>nc", "<cmd>Telescope find_files search_dirs=components,src/components<cr>", desc = "Find components" },
      { "<leader>na", "<cmd>Telescope find_files search_dirs=pages/api,app/api<cr>", desc = "Find API routes" },
      { "<leader>nh", "<cmd>Telescope find_files search_dirs=hooks,src/hooks<cr>", desc = "Find hooks" },
      { "<leader>nu", "<cmd>Telescope find_files search_dirs=utils,src/utils,lib<cr>", desc = "Find utils" },
      { "<leader>ns", "<cmd>Telescope find_files search_dirs=styles,src/styles<cr>", desc = "Find styles" },
      { "<leader>nt", "<cmd>Telescope find_files search_dirs=types,src/types<cr>", desc = "Find types" },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Next.js file templates
      local function create_nextjs_component(name, component_type)
        local templates = {
          page = function(name)
            return string.format([[
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: '%s',
  description: '%s page',
}

export default function %sPage() {
  return (
    <div>
      <h1>%s</h1>
    </div>
  )
}
]], name, name, name, name)
          end,
          
          component = function(name)
            return string.format([[
interface %sProps {
  // Add your props here
}

export default function %s({}: %sProps) {
  return (
    <div>
      {/* %s component */}
    </div>
  )
}
]], name, name, name, name)
          end,
          
          api = function(name)
            return string.format([[
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // %s API logic here
    return NextResponse.json({ message: 'Success' })
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    // %s API logic here
    return NextResponse.json({ message: 'Created' })
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    )
  }
}
]], name, name)
          end,
          
          hook = function(name)
            return string.format([[
import { useState, useEffect } from 'react'

export function %s() {
  const [state, setState] = useState(null)
  
  useEffect(() => {
    // %s logic here
  }, [])
  
  return {
    state,
    setState,
  }
}
]], name, name)
          end,
        }
        
        return templates[component_type] and templates[component_type](name) or ""
      end
      
      -- Create component command
      vim.api.nvim_create_user_command("NextComponent", function(opts)
        local args = vim.split(opts.args, " ")
        local component_type = args[1] or "component"
        local name = args[2] or vim.fn.input("Component name: ")
        
        if name == "" then
          vim.notify("Component name is required", vim.log.levels.ERROR)
          return
        end
        
        local content = create_nextjs_component(name, component_type)
        local lines = vim.split(content, "\n")
        
        -- Insert template at cursor position
        local buf = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_buf_set_lines(buf, cursor[1] - 1, cursor[1] - 1, false, lines)
        
        vim.notify(string.format("Created %s template for %s", component_type, name), vim.log.levels.INFO)
      end, {
        nargs = "*",
        complete = function()
          return { "component", "page", "api", "hook" }
        end,
      })
      
      -- Quick file switcher for Next.js
      local function switch_to_related_file()
        local current_file = vim.fn.expand("%:p")
        local file_name = vim.fn.expand("%:t:r")
        local file_ext = vim.fn.expand("%:e")
        
        -- Component <-> Test
        if current_file:match("%.test%.") or current_file:match("%.spec%.") then
          -- Switch from test to source
          local source_file = current_file:gsub("%.test%.", "."):gsub("%.spec%.", ".")
          if vim.fn.filereadable(source_file) == 1 then
            vim.cmd("edit " .. source_file)
            return
          end
        else
          -- Switch from source to test
          local test_file = current_file:gsub("%." .. file_ext .. "$", ".test." .. file_ext)
          if vim.fn.filereadable(test_file) == 1 then
            vim.cmd("edit " .. test_file)
            return
          end
          
          local spec_file = current_file:gsub("%." .. file_ext .. "$", ".spec." .. file_ext)
          if vim.fn.filereadable(spec_file) == 1 then
            vim.cmd("edit " .. spec_file)
            return
          end
        end
        
        -- Page <-> API route
        if current_file:match("/pages/") then
          local api_file = current_file:gsub("/pages/", "/pages/api/"):gsub("%.tsx?$", ".ts")
          if vim.fn.filereadable(api_file) == 1 then
            vim.cmd("edit " .. api_file)
            return
          end
        elseif current_file:match("/pages/api/") then
          local page_file = current_file:gsub("/pages/api/", "/pages/"):gsub("%.ts$", ".tsx")
          if vim.fn.filereadable(page_file) == 1 then
            vim.cmd("edit " .. page_file)
            return
          end
        end
        
        -- App directory routing
        if current_file:match("/app/") then
          if current_file:match("/route%.ts$") then
            -- Switch from API route to page
            local page_file = current_file:gsub("/route%.ts$", "/page.tsx")
            if vim.fn.filereadable(page_file) == 1 then
              vim.cmd("edit " .. page_file)
              return
            end
          elseif current_file:match("/page%.tsx$") then
            -- Switch from page to API route
            local api_file = current_file:gsub("/page%.tsx$", "/route.ts")
            if vim.fn.filereadable(api_file) == 1 then
              vim.cmd("edit " .. api_file)
              return
            end
          end
        end
        
        vim.notify("No related file found", vim.log.levels.WARN)
      end
      
      -- Keybindings for Next.js workflows
      vim.keymap.set("n", "<leader>nr", switch_to_related_file, { desc = "Switch to related file" })
      vim.keymap.set("n", "<leader>ncc", "<cmd>NextComponent component<cr>", { desc = "Create component template" })
      vim.keymap.set("n", "<leader>ncp", "<cmd>NextComponent page<cr>", { desc = "Create page template" })
      vim.keymap.set("n", "<leader>nca", "<cmd>NextComponent api<cr>", { desc = "Create API route template" })
      vim.keymap.set("n", "<leader>nch", "<cmd>NextComponent hook<cr>", { desc = "Create hook template" })
    end,
  },
}