return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lspconfig",
  },
  event = "LspAttach",
  opts = {
    ui = {
      border = "rounded",
      title = true,
      winblend = 0,
      expand = "",
      collapse = "",
      code_action = "💡",
    },
    symbol_in_winbar = {
      enable = false, -- we use navic for winbar
    },
    lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    outline = {
      layout = "float",
      detail = true,
    },
    callhierarchy = {
      layout = "float",
    },
    finder = {
      edit = { "o", "<CR>" },
      vsplit = "s",
      split = "i",
      tabe = "t",
      quit = { "q", "<ESC>" },
    },
    definition = {
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>i",
      tabe = "<C-c>t",
      quit = "q",
      close = "<Esc>",
    },
    code_action = {
      num_shortcut = true,
      show_server_name = true,
      extend_gitsigns = true,
    },
    lightbulb_enable = true,
    lightbulb_virtual_text = true,
    lightbulb_sign = true,
    lightbulb_sign_priority = 40,
    finder = {
      height = 0.6,
      width = 0.6,
      methods = {
        "textDocument/definition",
        "textDocument/typeDefinition",
        "textDocument/implementation",
        "textDocument/references",
      },
    },
    implement = {
      enable = true,
      sign = true,
      virtual_text = true,
      priority = 100,
    },
  },
}
