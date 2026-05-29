return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            styles = {
                input = {
                    keys = {
                        n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
                        i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
                    },
                },
                terminal = {
                    bo = { filetype = "snacks_terminal" },
                    wo = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                    keys = {
                        q = "hide",
                        gf = function(self)
                            local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
                            if #f > 0 then vim.cmd("e " .. f) end
                        end,
                    },
                },
            },
            terminal = {
                enabled = true,
                shell = os.getenv("SHELL") or "/bin/zsh",
                win = {
                    position = "float",
                    border = "rounded",
                    height = 0.7,
                    width = 0.85,
                    zindex = 50,
                    title = "  Terminal",
                    title_pos = "center",
                    style = "minimal",
                },
                bo = {
                    filetype = "snacks_terminal",
                },
                wo = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
                keys = {
                    q = "hide",
                    ["<Esc>"] = "stopinsert",
                    ["<C-c>"] = "stopinsert",
                },
            },
            input = { enabled = true },
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            scope = {
                enabled = true,
                animate = {
                    enabled = false,
                },
            },
            indent = {
                enabled = true,
                indent = {
                    char = "│",
                    only_scope = false,
                    only_current = false,
                },
                animate = {
                    enabled = vim.fn.has("nvim-0.10") == 1,
                    style = "out",
                    easing = "linear",
                    duration = {
                        step = 20,
                        total = 500,
                    },
                },
                scope = {
                    enabled = true,
                    char = "│",
                    hl = "SnacksIndentScope",
                },
            },
            statuscolumn = {
                enabled = true,
                left = { "mark", "sign" },
                right = { "fold", "git" },
                folds = {
                    open = false,
                    git_hl = false,
                },
                git = { patterns = { "GitSign", "MiniDiffSign" } },
                refresh = 50,
            },
            words = {
                enabled = true,
                debounce = 200,
                notify_jump = false,
                modes = { "n", "i", "c" },
            },
            bufdelete = { enabled = true },
            rename = { enabled = true },
            lazygit = { enabled = true },
            dashboard = {
                enabled = true,
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { section = "startup" },
                },
            },
            picker = {
                enabled = true,
                matchers = {
                    frecency = true,
                    cwd_bonus = false,
                },
                exclude = { ".git", "node_modules", "dist", "build" },
                formatters = {
                    file = {
                        filename_first = true,
                        filename_only = false,
                        icon_width = 2,
                    },
                },
                layout = {
                    preset = "telescope",
                    cycle = false,
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.6,
                            min_width = 80,
                            height = 0.4,
                            min_height = 10,
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
                        },
                    },
                    telescope = {
                        reverse = true,
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
                                { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center",
                            },
                        },
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            { win = "input", height = 1, border = "bottom" },
                            {
                                box = "horizontal",
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                            },
                        },
                    },
                },
            },
        },
        keys = {
            { "<C-\\>",      function() require("snacks").terminal.toggle() end,          desc = "Toggle terminal",          mode = { "n", "t" } },
            { "<leader>tt",  function() require("snacks").terminal.toggle() end,          desc = "Toggle floating terminal" },
            { "<leader>ts",  function()
                vim.cmd("belowright new")
                require("snacks").terminal(nil, {
                    win = {
                        position = "split",
                        height = 0.35,
                        border = "rounded",
                        title = "  Terminal Split",
                    },
                })
            end, desc = "Terminal in split" },
            { "<leader>tN",  function()
                vim.ui.input({ prompt = "Terminal name: " }, function(name)
                    if name then
                        require("snacks").terminal(nil, {
                            win = {
                                position = "float",
                                border = "rounded",
                                height = 0.7,
                                width = 0.85,
                                title = "  " .. name,
                                title_pos = "center",
                            },
                            env = { SHELL = "/bin/zsh" },
                        })
                    end
                end)
            end, desc = "Named terminal" },
            { "<leader>tP",  function()
                local project_root = vim.fn.getcwd()
                require("snacks").terminal("cd " .. vim.fn.shellescape(project_root) .. " && zsh", {
                    win = {
                        position = "float",
                        border = "rounded",
                        height = 0.7,
                        width = 0.85,
                        title = "  Project: " .. vim.fn.fnamemodify(project_root, ":t"),
                        title_pos = "center",
                    },
                    env = { SHELL = "/bin/zsh" },
                })
            end, desc = "Project terminal" },
            { "<leader>lg",  function() require("snacks").lazygit() end,                 desc = "Lazygit" },
            { "<leader>gl",  function() require("snacks").lazygit.log() end,             desc = "Lazygit log" },
            { "<leader>gfl", function() require("snacks").lazygit.log_file() end,        desc = "Lazygit file log" },
            { "<leader>rN",  function() require("snacks").rename.rename_file() end,      desc = "Rename file" },
            { "<leader>bd",  function() require("snacks").bufdelete() end,               desc = "Delete buffer" },
            { "<leader>pf",  function() require("snacks").picker.files() end,            desc = "Find files" },
            { "<leader>pr",  function() require("snacks").picker.recent() end,           desc = "Recent files" },
            { "<leader>pc",  function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config files" },
            { "<leader>ps",  function() require("snacks").picker.grep() end,             desc = "Grep (live)" },
            { "<leader>pws", function() require("snacks").picker.grep_word() end,        desc = "Grep word/selection", mode = { "n", "x" } },
            { "<leader>pWs", function()
                require("snacks").picker.grep({ search = vim.fn.expand("<cWORD>") })
            end, desc = "Grep WORD under cursor" },
            { "<leader>pk",  function() require("snacks").picker.keymaps({ layout = "ivy" }) end,       desc = "Keymaps" },
            { "<leader>ph",  function() require("snacks").picker.help() end,             desc = "Help pages" },
            { "<leader>pb",  function() require("snacks").picker.buffers() end,          desc = "Buffers" },
            { "<leader>pd",  function() require("snacks").picker.diagnostics() end,      desc = "Diagnostics" },
            { "<leader>pD",  function() require("snacks").picker.diagnostics_buffer() end, desc = "Buffer diagnostics" },
            { "<leader>po",  function() require("snacks").picker.lsp_symbols() end,      desc = "LSP symbols" },
            { "<leader>gbr", function() require("snacks").picker.git_branches({ layout = "select" }) end, desc = "Git branches" },
            { "<leader>gc",  function() require("snacks").picker.git_log() end,          desc = "Git commits" },
            { "<leader>gs",  function() require("snacks").picker.git_status() end,       desc = "Git status" },
            { "<leader>uc",  function() require("snacks").picker.colorschemes({ layout = "ivy" }) end, desc = "Pick colorscheme" },
            { "]]",          function() require("snacks").words.jump(vim.v.count1) end,  desc = "Next word reference",    mode = { "n", "t" } },
            { "[[",          function() require("snacks").words.jump(-vim.v.count1) end, desc = "Prev word reference",    mode = { "n", "t" } },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        optional = true,
        keys = {
            { "<leader>pt",  function() require("snacks").picker.todo_comments() end,                                          desc = "All TODOs" },
            { "<leader>pT",  function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FORGETNOT", "FIXME" } }) end, desc = "Main TODOs" },
        },
    },
}
