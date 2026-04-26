-- ─────────────────────────────────────────────────────────────────────────────
-- AI Integration — Gemini sidebar via CodeCompanion
-- Ollama can be used directly in the floating terminal: ollama run <model>
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Keymaps:
--   <leader>cc  → Toggle Gemini chat sidebar
--   <leader>cn  → New Gemini chat
--   <leader>ca  → Actions menu (fix, explain, review, tests, docs...)
--   <leader>ci  → Inline prompt (edits your code directly)
--   <leader>cb  → Add current buffer as context to chat
--   <leader>cs  → Add visual selection as context
-- ─────────────────────────────────────────────────────────────────────────────

return {
    -- ─── dressing.nvim: better input/select UI ───────────────────────────────
    {
        "stevearc/dressing.nvim",
        lazy = true,
        opts = {},
    },

    -- ─── codecompanion.nvim: Gemini sidebar ──────────────────────────────────
    {
        "olimorris/codecompanion.nvim",
        event        = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "stevearc/dressing.nvim",
            "hrsh7th/nvim-cmp",
        },
        opts = {
            strategies = {
                -- All strategies use Gemini
                chat   = { adapter = "gemini" },
                inline = { adapter = "gemini" },
                agent  = { adapter = "gemini" },
            },

            adapters = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        env = {
                            -- Reads from your environment
                            -- Add to ~/.bashrc: export GEMINI_API_KEY=your_key
                            api_key = "GEMINI_API_KEY",
                        },
                        schema = {
                            model = {
                                default = "gemini-2.0-flash",
                            },
                        },
                    })
                end,
            },

            display = {
                -- Sidebar chat window
                chat = {
                    window = {
                        layout  = "vertical",  -- opens on the right
                        width   = 0.35,        -- 35% of screen
                        border  = "rounded",
                        title   = "  Gemini",
                    },
                    show_settings    = false,
                    show_token_count = true,
                    start_in_insert  = false,
                },
                -- Inline diff when gemini edits your code
                inline = {
                    layout = "vertical",
                    diff = {
                        enabled  = true,
                        provider = "mini_diff",
                    },
                },
                -- Action palette (the menu that pops up)
                action_palette = {
                    width    = 90,
                    height   = 12,
                    border   = "rounded",
                    prompt   = "  Action: ",
                    provider = "telescope",
                },
            },

            -- Useful slash commands inside the chat buffer
            -- Type / in the chat to use them
            prompt_library = {
                ["Review Code"] = {
                    strategy = "chat",
                    description = "Review the code for bugs and improvements",
                    prompts = {
                        {
                            role    = "user",
                            content = function(context)
                                return "Review this "
                                    .. context.filetype
                                    .. " code for bugs, improvements and best practices:\n\n"
                                    .. require("codecompanion.helpers.actions").get_code(
                                        context.start_line,
                                        context.end_line
                                    )
                            end,
                        },
                    },
                },
                ["Explain Code"] = {
                    strategy = "chat",
                    description = "Explain how the code works",
                    prompts = {
                        {
                            role    = "user",
                            content = function(context)
                                return "Explain how this "
                                    .. context.filetype
                                    .. " code works step by step:\n\n"
                                    .. require("codecompanion.helpers.actions").get_code(
                                        context.start_line,
                                        context.end_line
                                    )
                            end,
                        },
                    },
                },
                ["Fix Code"] = {
                    strategy = "inline",
                    description = "Fix any bugs in the code",
                    prompts = {
                        {
                            role    = "user",
                            content = function(context)
                                return "Fix any bugs in this "
                                    .. context.filetype
                                    .. " code:\n\n"
                                    .. require("codecompanion.helpers.actions").get_code(
                                        context.start_line,
                                        context.end_line
                                    )
                            end,
                        },
                    },
                },
                ["Add Comments"] = {
                    strategy = "inline",
                    description = "Add comments to the code",
                    prompts = {
                        {
                            role    = "user",
                            content = function(context)
                                return "Add clear comments to this "
                                    .. context.filetype
                                    .. " code:\n\n"
                                    .. require("codecompanion.helpers.actions").get_code(
                                        context.start_line,
                                        context.end_line
                                    )
                            end,
                        },
                    },
                },
            },
        },
        keys = {
            -- Sidebar
            { "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "Gemini: toggle sidebar" },
            { "<leader>cn", "<cmd>CodeCompanionChat<CR>",        mode = { "n", "v" }, desc = "Gemini: new chat" },

            -- Actions
            { "<leader>ca", "<cmd>CodeCompanionActions<CR>",     mode = { "n", "v" }, desc = "Gemini: actions menu" },

            -- Inline edit
            { "<leader>ci", "<cmd>CodeCompanion<CR>",            mode = { "n", "v" }, desc = "Gemini: inline edit" },

            -- Add context to chat
            { "<leader>cb", "<cmd>CodeCompanionChat Add<CR>",    mode = { "n", "v" }, desc = "Gemini: add to chat" },
        },
    },
}
