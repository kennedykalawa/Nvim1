return {
  "SmiteshP/nvim-navic",
  event = "LspAttach",
  opts = {
    icons = {
      File          = "󰈙 ",
      Module        = " ",
      Namespace     = "󰌗 ",
      Package       = " ",
      Class         = "󰌗 ",
      Method        = "󰊕 ",
      Property      = " ",
      Field         = " ",
      Constructor   = " ",
      Enum          = "󰕘",
      Interface     = "󰕘",
      Function      = "󰊕 ",
      Variable      = "󰀫 ",
      Constant      = "󰏿 ",
      String        = "󰀬 ",
      Number        = "󰎠 ",
      Boolean       = "󰨙 ",
      Array         = "󰅪 ",
      Object        = "󰅩 ",
      Key           = "󰌆 ",
      Null          = "󰟢 ",
      EnumMember    = "󰕘",
      Struct        = "󰌗 ",
      Event         = "󰆋 ",
      Operator      = "󰆕 ",
      TypeParameter = "󰊄 ",
    },
    highlight = true,
    separator = "  ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = true,
    click = false,
    lsp = {
      auto_attach = true,
      preference = nil,
    },
  },
  config = function(_, opts)
    require("nvim-navic").setup(opts)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.supports_method("textDocument/documentSymbol") then
          local navic = require("nvim-navic")
          if navic then
            navic.attach(client, args.buf)
          end
        end
      end,
    })
  end,
}
