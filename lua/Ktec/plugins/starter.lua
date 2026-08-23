return {
  "echasnovski/mini.starter",
  version = false,
  config = function()
    local starter = require("mini.starter")

    starter.setup({
      header = table.concat({
      "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗ ██████╗ ",
      "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║██╔═══██╗",
      "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██║   ██║",
      "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██║██║██║   ██║",
      "██║ ╚████║███████╗╚██████╔╝ ╚█████║ ██║╚██████╔╝",
      "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚════╝ ╚═╝ ╚═════╝ ",
    }, "\n"),
      content_hooks = {
        starter.gen_hook.adding_bullet("│ "),
        starter.gen_hook.aligning("center", "center"),
      },
      items = {
        starter.sections.builtin_actions(),
        starter.sections.recent_files(5, false),
        starter.sections.sessions(5, false),
      },
    })
  end,
}
