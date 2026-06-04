-- In-buffer markdown rendering: styled headings, bullets, code blocks, tables.
-- Renders in normal mode; un-renders the line under the cursor for editing.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown", "markdown.mdx", "Avante" },
  ---@module "render-markdown"
  ---@type render.md.UserConfig
  opts = {
    -- Render while viewing, reveal raw text when editing the line.
    render_modes = { "n", "c", "t" },
    heading = { sign = false },
    code = { sign = false, width = "block", left_pad = 1, right_pad = 1 },
    completions = { blink = { enabled = true } },
  },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown render" },
  },
}
