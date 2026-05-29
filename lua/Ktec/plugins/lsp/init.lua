local servers = {
    "ts_ls", "html", "cssls", "tailwindcss", "svelte",
    "graphql", "emmet_ls", "prismals", "eslint",
    "lua_ls", "bashls", "pyright", "gopls", "rust_analyzer",
    "jsonls", "yamlls", "dockerls", "docker_compose_language_service",
    "omnisharp",  -- VB.NET + C# LSP (install dotnet-sdk first)
}

return {
    -- Mason
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>lm", "<cmd>Mason<CR>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            ui = {
                border = "rounded",
                icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
            },
        },
    },

    -- nvim-lspconfig + mason-lspconfig v2
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local cmp_lsp   = require("cmp_nvim_lsp")

            local capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }

            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN]  = " ",
                        [vim.diagnostic.severity.INFO]  = " ",
                        [vim.diagnostic.severity.HINT]  = "󰠠 ",
                    },
                },
                virtual_text = { source = "if_many", prefix = "●" },
            })

            local on_attach = function(client, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end
                map("gd",         vim.lsp.buf.definition,      "Go to definition")
                map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
                map("gr",         vim.lsp.buf.references,      "References")
                map("gI",         vim.lsp.buf.implementation,  "Go to implementation")
                map("gy",         vim.lsp.buf.type_definition, "Type definition")
                map("K",          vim.lsp.buf.hover,           "Hover docs")
                map("<leader>lR", vim.lsp.buf.rename,          "Rename symbol")
                map("<leader>la", vim.lsp.buf.code_action,     "Code action")
                map("<leader>lf", vim.lsp.buf.format,          "Format")
                map("<leader>li", "<cmd>LspInfo<CR>",          "LSP info")
                map("<leader>lr", "<cmd>LspRestart<CR>",       "LSP restart")
                map("<C-k>",      vim.lsp.buf.signature_help,  "Signature help")

                if client.supports_method("textDocument/inlayHint") then
                    map("<leader>lh", function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                            { bufnr = bufnr }
                        )
                    end, "Toggle inlay hints")
                end

                if client.supports_method("textDocument/documentHighlight") then
                    local group = vim.api.nvim_create_augroup("lsp_hl_" .. bufnr, { clear = true })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = bufnr, group = group, callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = bufnr, group = group, callback = vim.lsp.buf.clear_references,
                    })
                end
            end

            local server_settings = {
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            completion  = { callSnippet = "Replace" },
                            workspace   = { checkThirdParty = false },
                            telemetry   = { enable = false },
                        },
                    },
                },
                ts_ls = {
                    settings = {
                        typescript = { inlayHints = { includeInlayParameterNameHints = "all", includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true } },
                        javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            analyses    = { unusedparams = true },
                            staticcheck = true,
                            gofumpt     = true,
                            hints       = { parameterNames = true, assignVariableTypes = true },
                        },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = { typeCheckingMode = "basic", autoSearchPaths = true, useLibraryCodeForTypes = true },
                        },
                    },
                },
                emmet_ls = {
                    filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
                },
                tailwindcss = {
                    settings = {
                        tailwindCSS = {
                            experimental = { classRegex = { { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" } } },
                        },
                    },
                },
            }

            -- mason-lspconfig v2: handlers go inside setup(), not setup_handlers()
            require("mason-lspconfig").setup({
                ensure_installed       = servers,
                automatic_installation = true,
                handlers = {
                    function(server_name)
                        local cfg = vim.tbl_deep_extend("force", {
                            capabilities = capabilities,
                            on_attach    = on_attach,
                        }, server_settings[server_name] or {})
                        lspconfig[server_name].setup(cfg)
                    end,
                },
            })
        end,
    },

    -- none-ls: formatters + linters
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim", "williamboman/mason.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.prettier.with({ extra_filetypes = { "svelte" } }),
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.isort,
                    -- NOTE: eslint linting is handled by ts_ls / eslint LSP server
                    -- none-ls no longer ships eslint builtins
                    null_ls.builtins.diagnostics.pylint.with({
                        condition = function(utils)
                            return utils.root_has_file({ "pylintrc", ".pylintrc" })
                        end,
                    }),
                },
            })
        end,
    },

    -- mason-null-ls: auto-install formatters/linters
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        opts = {
            ensure_installed       = { "prettier", "stylua", "black", "isort", "pylint" },
            automatic_installation = true,
        },
    },

    -- nvim-cmp: completions
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
                dependencies = { "rafamadriz/friendly-snippets" },
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                completion = { completeopt = "menu,menuone,noinsert" },
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"]     = cmp.mapping.select_prev_item(),
                    ["<C-j>"]     = cmp.mapping.select_next_item(),
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "buffer",   priority = 500 },
                    { name = "path",     priority = 250 },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text", maxwidth = 50, ellipsis_char = "...",
                        menu = { nvim_lsp = "[LSP]", luasnip = "[Snip]", buffer = "[Buf]", path = "[Path]" },
                    }),
                },
                window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                experimental = { ghost_text = true },
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            })
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
                matching = { disallow_symbol_nonprefix_matching = false },
            })
        end,
    },

    -- Trouble: VS Code-style problems panel
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = { modes = { lsp_base = { params = { include_current = true } } } },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer diagnostics" },
            { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP sidebar" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location list" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix" },
        },
    },

    -- inc-rename: live rename preview
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        config = true,
        keys = {
            { "<leader>rn", function() return ":IncRename " .. vim.fn.expand("<cword>") end, expr = true, desc = "Rename (live)" },
        },
    },
}
