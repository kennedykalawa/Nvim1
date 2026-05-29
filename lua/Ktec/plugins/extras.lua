-- Extra plugins that bring Neovim to VS Code feature parity
return {

    -- ─── Highlight colors (CSS/Tailwind color preview) ───────────────────────
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            render = "background",
            enable_named_colors = true,
            enable_tailwind = true,
        },
    },

    -- ─── LSP signature help as you type ─────────────────────────────────────
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = { border = "rounded" },
            hint_enable = true,
            hint_prefix = "󰏪 ",
            floating_window = true,
            floating_window_above_cur_line = true,
            auto_close_after = 3,
            toggle_key = "<C-x>",
            select_signature_key = "<C-n>",
        },
    },

    -- ─── Better code folding ─────────────────────────────────────────────────
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = { "BufReadPost" },
        opts = {
            provider_selector = function(_, filetype, _)
                local lsp_filetypes = {
                    "javascript", "typescript", "typescriptreact",
                    "javascriptreact", "go", "rust", "python", "lua",
                }
                if vim.tbl_contains(lsp_filetypes, filetype) then
                    return { "lsp", "indent" }
                end
                return { "treesitter", "indent" }
            end,
            open_fold_hl_timeout = 150,
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d lines"):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "MoreMsg" })
                return newVirtText
            end,
        },
        keys = {
            { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
            { "zK", function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then vim.lsp.buf.hover() end
            end, desc = "Peek fold" },
        },
    },

    -- ─── Git conflict resolver ───────────────────────────────────────────────
    {
        "akinsho/git-conflict.nvim",
        event = "BufReadPre",
        version = "*",
        opts = {
            default_mappings = true,
            default_commands = true,
            disable_diagnostics = false,
            list_opener = "copen",
            highlights = {
                incoming = "DiffAdd",
                current  = "DiffText",
            },
        },
    },

    -- ─── Better quickfix ────────────────────────────────────────────────────
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        opts = {
            keys = {
                { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand context" },
                { "<", function() require("quicker").collapse() end, desc = "Collapse context" },
            },
        },
    },

    -- ─── Multi-cursor (Ctrl+D like VS Code) ──────────────────────────────────
    {
        "mg979/vim-visual-multi",
        branch = "master",
        event = { "BufReadPost" },
        init = function()
            vim.g.VM_maps = {
                ["Find Under"]         = "<C-d>",
                ["Find Subword Under"] = "<C-d>",
                ["Select All"]         = "<C-M-l>",
                ["Add Cursor Down"]    = "<M-j>",
                ["Add Cursor Up"]      = "<M-k>",
            }
            vim.g.VM_theme = "iceblue"
            vim.g.VM_highlight_matches = "underline"
        end,
    },

    -- ─── Smarter word motions ────────────────────────────────────────────────
    {
        "chrisgrieser/nvim-spider",
        event = { "BufReadPost" },
        keys = {
            { "w",  function() require("spider").motion("w") end,  mode = { "n", "o", "x" }, desc = "Spider w" },
            { "e",  function() require("spider").motion("e") end,  mode = { "n", "o", "x" }, desc = "Spider e" },
            { "b",  function() require("spider").motion("b") end,  mode = { "n", "o", "x" }, desc = "Spider b" },
            { "ge", function() require("spider").motion("ge") end, mode = { "n", "o", "x" }, desc = "Spider ge" },
        },
    },

    -- ─── Flash: jump anywhere fast ───────────────────────────────────────────
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                char = { jump_labels = true, multi_line = false },
            },
        },
        keys = {
            { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash jump" },
            { "S",     function() require("flash").treesitter() end,        mode = { "n", "x", "o" }, desc = "Flash treesitter" },
            { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Flash remote" },
            { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Flash TS search" },
            { "<C-s>", function() require("flash").toggle() end,            mode = "c",               desc = "Toggle Flash" },
        },
    },

    -- ─── Bufferline: VS Code-style tab bar ───────────────────────────────────
    -- FIX: style_preset must be referenced inside config, not opts={},
    -- because the plugin isn't loaded yet when the spec table is evaluated.
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        config = function()
            local bufferline = require("bufferline")
            bufferline.setup({
                options = {
                    mode = "buffers",
                    -- Safe to reference here — plugin is loaded at this point
                    style_preset = bufferline.style_preset.default,
                    themable = true,
                    numbers = "none",
                    close_command       = function(n) require("snacks").bufdelete(n) end,
                    right_mouse_command = function(n) require("snacks").bufdelete(n) end,
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(_, _, diag)
                        local icons = { error = " ", warning = " " }
                        local ret = (diag.error and icons.error .. diag.error .. " " or "")
                            .. (diag.warning and icons.warning .. diag.warning or "")
                        return vim.trim(ret)
                    end,
                    offsets = {
                        { filetype = "oil", text = "Oil", text_align = "center", separator = true },
                    },
                    color_icons = true,
                    separator_style = "slant",
                    always_show_bufferline = false,
                    hover = {
                        enabled = true,
                        delay = 200,
                        reveal = { "close" },
                    },
                },
            })
        end,
        keys = {
            { "<S-h>",      "<cmd>BufferLineCyclePrev<CR>",              desc = "Prev buffer" },
            { "<S-l>",      "<cmd>BufferLineCycleNext<CR>",              desc = "Next buffer" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",              desc = "Pin buffer" },
            { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>",   desc = "Close unpinned" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>",            desc = "Close others" },
            { "<leader>bl", "<cmd>BufferLineCloseRight<CR>",             desc = "Close right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<CR>",              desc = "Close left" },
            { "<leader>1",  "<cmd>BufferLineGoToBuffer 1<CR>",           desc = "Buffer 1" },
            { "<leader>2",  "<cmd>BufferLineGoToBuffer 2<CR>",           desc = "Buffer 2" },
            { "<leader>3",  "<cmd>BufferLineGoToBuffer 3<CR>",           desc = "Buffer 3" },
            { "<leader>4",  "<cmd>BufferLineGoToBuffer 4<CR>",           desc = "Buffer 4" },
            { "<leader>5",  "<cmd>BufferLineGoToBuffer 5<CR>",           desc = "Buffer 5" },
        },
    },

    -- ─── Better marks ────────────────────────────────────────────────────────
    {
        "chentoast/marks.nvim",
        event = { "BufReadPost" },
        opts = {
            default_mappings = true,
            builtin_marks = { ".", "<", ">", "^" },
            cyclic = true,
            force_write_shada = false,
            refresh_interval = 250,
            sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
            excluded_filetypes = { "qf", "NvimTree", "neo-tree", "oil" },
        },
    },

    -- ─── Rainbow bracket pairs ───────────────────────────────────────────────
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = { "BufReadPost" },
        config = function()
            local rd = require("rainbow-delimiters")
            require("rainbow-delimiters.setup").setup({
                strategy = {
                    [""] = rd.strategy["global"],
                    vim  = rd.strategy["local"],
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua  = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            })
        end,
    },

    -- ─── Markdown preview in browser ─────────────────────────────────────────
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && npm install",
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown preview" },
        },
    },

    -- ─── Render markdown inside Neovim ───────────────────────────────────────
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "norg", "rmd", "org" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {
            heading  = { enabled = true },
            code     = { enabled = true, style = "full" },
            bullet   = { enabled = true },
            checkbox = {
                enabled  = true,
                unchecked = { icon = "󰄱 " },
                checked   = { icon = "󰱒 " },
            },
        },
    },

    -- ─── Diffview: git diffs & file history ──────────────────────────────────
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gdo", "<cmd>DiffviewOpen<CR>",          desc = "Diffview open" },
            { "<leader>gdc", "<cmd>DiffviewClose<CR>",         desc = "Diffview close" },
            { "<leader>gdh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
            { "<leader>gdH", "<cmd>DiffviewFileHistory<CR>",   desc = "Repo history" },
        },
        opts = {
            enhanced_diff_hl = true,
            view = {
                default      = { layout = "diff2_horizontal" },
                file_history = { layout = "diff2_horizontal" },
            },
        },
    },

    -- ─── Neogit: Magit-style git UI ───────────────────────────────────────────
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
        keys = {
            { "<leader>gn", "<cmd>Neogit<CR>", desc = "Neogit" },
        },
        opts = {
            integrations = { diffview = true },
            graph_style  = "unicode",
        },
    },

    -- ─── Comment box ─────────────────────────────────────────────────────────
    {
        "LudoPinelli/comment-box.nvim",
        event = { "BufReadPost" },
        keys = {
            { "<leader>qb", function() require("comment-box").lbox(2) end,   mode = { "n", "v" }, desc = "Comment box" },
            { "<leader>qc", function() require("comment-box").lcbox(10) end, mode = { "n", "v" }, desc = "Centered box" },
            { "<leader>ql", function() require("comment-box").line(2) end,   mode = { "n", "v" }, desc = "Comment line" },
        },
    },

    -- ─── sniprun: run lines/selection inline with output ───────────────────────
    {
        "michaelb/sniprun",
        branch = "master",
        build  = "sh install.sh",
        cmd    = { "SnipRun", "SnipClose", "SnipReset" },
        opts = {
            display = { "NvimNotify" },
            live_mode_toggle = "off",
            repl_enable = { "Python3_original", "JavaScript_original" },
        },
        keys = {
            { "<leader>rl", "<Plug>SnipRun",   mode = { "n", "v" }, desc = "Sniprun line/selection" },
            { "<leader>rX", "<cmd>SnipClose<CR>",                   desc = "Close sniprun output" },
        },
    },
}
