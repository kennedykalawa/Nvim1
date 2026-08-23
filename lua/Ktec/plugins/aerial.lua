return {
  "stevearc/aerial.nvim",
  opts = {
    attach_mode = "global",
    backends = { "lsp", "treesitter" },
    layout = {
      max_width = { 40, 0.2 },
      width = nil,
      min_width = 20,
      default_direction = "prefer_left",
    },
    show_guides = true,
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    filter_kind = false,
  },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Aerial (outline) toggle" },
  },
}
