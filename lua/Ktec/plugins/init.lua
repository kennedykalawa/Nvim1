return {
    "nvim-lua/plenary.nvim",
    "christoomey/vim-tmux-navigator",
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },
    -- which-key: shows pending keybinds (like VS Code's command palette hints)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 300,
            icons = { mappings = true },
            spec = {
                { "<leader>p",  group = "picker/find" },
                { "<leader>a",  group = "ai cli" },
                { "<leader>g",  group = "git" },
                { "<leader>h",  group = "harpoon" },
                { "<leader>l",  group = "lsp" },
                { "<leader>r",  group = "run/tasks/request" },
                { "<leader>v",  group = "preview" },
                { "<leader>w",  group = "workspace/session" },
                { "<leader>c",  group = "code/ai" },
                { "<leader>d",  group = "debug/delete" },
                { "<leader>b",  group = "buffer" },
                { "<leader>db", group = "database" },
                },
        },
        keys = {
            { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps (which-key)" },
        },
    },
    -- Noice: replaces cmdline, messages and popupmenu (the big VS Code-feel upgrade)
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                signature = { enabled = false }, -- handled by lsp-signature below
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },
            routes = {
                -- Suppress noisy messages
                { filter = { event = "msg_show", any = {
                    { find = "%d+L, %d+B" },
                    { find = "; after #%d+" },
                    { find = "; before #%d+" },
                    { find = "fewer lines" },
                    { find = "written" },
                }}, opts = { skip = true } },
            },
        },
        keys = {
            { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss notifications" },
            { "<leader>nh", function() require("noice").cmd("history") end, desc = "Notification history" },
        },
    },
    -- nvim-notify for beautiful notifications
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 3000,
            max_height = function() return math.floor(vim.o.lines * 0.75) end,
            max_width = function() return math.floor(vim.o.columns * 0.75) end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
            render = "wrapped-compact",
            stages = "fade_in_slide_out",
        },
    },
}
