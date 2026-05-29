return {
    -- ─── Kulala: API / Backend Visual Preview ──────────────────────────────
    -- Best alternative to Postman/Insomnia inside Neovim
    {
        "mistweaverco/kulala.nvim",
        ft = { "http", "rest" },
        keys = {
            { "<leader>rr", function() require("kulala").run() end,       desc = "Run request" },
            { "<leader>ra", function() require("kulala").run_all() end,   desc = "Run all requests" },
            { "<leader>r[", function() require("kulala").jump_prev() end, desc = "Prev request" },
            { "<leader>r]", function() require("kulala").jump_next() end, desc = "Next request" },
            { "<leader>ri", function() require("kulala").inspect() end,   desc = "Inspect request" },
            { "<leader>ry", function() require("kulala").copy() end,      desc = "Copy as curl" },
            { "<leader>rt", function() require("kulala").toggle_view() end, desc = "Toggle body/headers" },
        },
        opts = {
            -- Default icons and colors
            winbar = true,
            default_view = "body",
            formatters = {
                json = "jq",
                html = "prettier",
            },
        },
    },

    -- ─── Overseer: Visual Task & Server Management ─────────────────────────
    -- Tracks your backend/frontend servers in a side panel
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
        keys = {
            { "<leader>rv", "<cmd>OverseerToggle<CR>", desc = "Tasks status" },
            { "<leader>ro", "<cmd>OverseerRun<CR>",    desc = "Overseer run task" },
            { "<leader>rp", function()
                vim.ui.input({ prompt = "Run on Port: ", default = "5173" }, function(port)
                    if port and port ~= "" then
                        require("Ktec.plugins.previews").run_on_port(port)
                    end
                end)
            end, desc = "Run Dev on specific Port..." },
            { "<leader>rd", function()
                local overseer = require("overseer")

                -- Ensure we are in a directory with a package.json
                if vim.fn.filereadable("package.json") == 0 then
                    vim.notify("No package.json found in this directory.", vim.log.levels.WARN, { title = "Project Runner" })
                    vim.cmd("OverseerRun")
                    return
                end

                -- Try to run the 'dev' script. 
                -- In Overseer, the template name for npm scripts is usually "npm dev"
                overseer.run_task({ 
                    name = "npm run dev",
                    autostart = true 
                }, function(task)
                    if not task then
                        -- If 'dev' fails, try 'start'
                        overseer.run_task({ name = "npm start", autostart = true }, function(task2)
                            if not task2 then
                                -- If both fail, just open the picker
                                vim.cmd("OverseerRun")
                            end
                        end)
                    end
                end)
            end, desc = "Run Dev Server (npm run dev)" },
        },
        opts = {
            templates = { "builtin" },
            task_list = {
                direction = "right",
                bindings = {
                    ["<C-l>"] = false,
                    ["<C-h>"] = false,
                    ["L"] = "IncreaseDetail",
                    ["H"] = "DecreaseDetail",
                },
            },
        },
    },

    -- ─── Web Tools: Browser Sync & HTML Preview ─────────────────────────────
    {
        "brianhuster/live-preview.nvim",
        cmd = { "LivePreview" },
        dependencies = { "folke/snacks.nvim" },
        init = function()
            -- Helper to run on port
            local M = require("Ktec.plugins.previews")
            M.run_on_port = function(port)
                local overseer = require("overseer")
                local cmd = "npm run dev -- --port " .. port
                
                if vim.fn.filereadable("package.json") == 1 then
                    local content = table.concat(vim.fn.readfile("package.json"), " ")
                    if content:find("next") then
                        cmd = "npm run dev -- -p " .. port
                    elseif content:find("react%-scripts") then
                        cmd = "PORT=" .. port .. " npm start"
                    end
                end

                local task = overseer.new_task({
                    name = "Dev Server (Port " .. port .. ")",
                    cmd = cmd,
                    components = { "default" },
                })
                task:start()
                vim.cmd("OverseerToggle")
                vim.notify("Starting server on port " .. port, vim.log.levels.INFO)
            end

            vim.g.ktec_preview_autosave = vim.g.ktec_preview_autosave ~= false

            local group = vim.api.nvim_create_augroup("KtecWebPreviewAutoSave", { clear = true })

            vim.api.nvim_create_autocmd({ "InsertLeavePre", "TextChanged", "TextChangedI" }, {
                group = group,
                pattern = {
                    "*.html",
                    "*.css",
                    "*.js",
                    "*.jsx",
                    "*.ts",
                    "*.tsx",
                    "*.vue",
                    "*.svelte",
                    "*.svg",
                },
                callback = function()
                    if not vim.g.ktec_preview_autosave then
                        return
                    end

                    if vim.bo.modifiable and vim.bo.modified and vim.fn.expand("%") ~= "" then
                        vim.cmd("silent! write")
                    end
                end,
                desc = "Autosave web files for live preview and HMR",
            })

            local function open_url(url)
                if not url or url == "" then return end
                vim.g.ktec_preview_url = url
                vim.fn.jobstart({ "xdg-open", url }, { detach = true })
                vim.notify("Opening preview: " .. url, vim.log.levels.INFO, { title = "Preview" })
            end

            local function prompt_url(default)
                vim.ui.input({ 
                    prompt = "Preview URL: ", 
                    default = vim.g.ktec_preview_url or default or "http://localhost:5173" 
                }, function(input)
                    if input and input ~= "" then
                        open_url(input)
                    end
                end)
            end

            local function open_terminal_url(default)
                vim.ui.input({ prompt = "Terminal preview URL: ", default = vim.g.ktec_preview_url or default }, function(url)
                    if not url or url == "" then
                        return
                    end

                    if vim.fn.executable("browsh") ~= 1 then
                        vim.notify("browsh is required for terminal browser preview", vim.log.levels.WARN, { title = "Preview" })
                        return
                    end

                    vim.g.ktec_preview_url = url
                    require("snacks").terminal("browsh " .. vim.fn.shellescape(url), {
                        win = {
                            position = "right",
                            border = "rounded",
                            height = 0,
                            width = 0.45,
                            title = "  Browser Preview",
                            title_pos = "center",
                        },
                        auto_close = false,
                    })
                end)
            end

            vim.api.nvim_create_user_command("PreviewUrl", function(opts)
                if opts.args ~= "" then
                    open_url(opts.args)
                else
                    prompt_url()
                end
            end, { nargs = "?" })

            vim.api.nvim_create_user_command("PreviewVite", function()
                open_url("http://localhost:5173")
            end, {})

            vim.api.nvim_create_user_command("PreviewReact", function()
                open_url("http://localhost:5174")
            end, {})

            vim.api.nvim_create_user_command("PreviewBackend", function()
                open_url(vim.g.ktec_preview_url or "http://localhost:8000")
            end, {})

            vim.api.nvim_create_user_command("PreviewTerm", function(opts)
                open_terminal_url(opts.args ~= "" and opts.args or "http://localhost:5173")
            end, { nargs = "?" })
        end,
        config = function()
            require("livepreview.config").set({
                port = 5500,
                browser = "default",
                dynamic_root = false,
                sync_scroll = true,
                picker = "snacks.picker",
                address = "127.0.0.1",
            })
        end,
        keys = {
            { "<leader>vp", "<cmd>LivePreview start<CR>", desc = "Static live preview" },
            { "<leader>vP", "<cmd>LivePreview pick<CR>",  desc = "Pick live preview file" },
            { "<leader>vx", "<cmd>LivePreview close<CR>", desc = "Close live preview" },
            { "<leader>vu", function()
                vim.ui.input({ 
                    prompt = "Preview URL/Port: ", 
                    default = vim.g.ktec_preview_url or "http://localhost:5173" 
                }, function(input)
                    if not input or input == "" then return end
                    
                    local url = input
                    if tonumber(input) then
                        url = "http://localhost:" .. input
                    end
                    
                    vim.g.ktec_preview_url = url
                    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
                    vim.notify("Opening preview: " .. url, vim.log.levels.INFO, { title = "Preview" })
                end)
            end, desc = "Open preview on Port/URL..." },
            { "<leader>vv", "<cmd>PreviewVite<CR>",       desc = "Open Vite (5173)" },
            { "<leader>vr", "<cmd>PreviewReact<CR>",      desc = "Open React (5174)" },
            { "<leader>vb", "<cmd>PreviewBackend<CR>",    desc = "Open Backend (8000)" },
            { "<leader>vt", "<cmd>PreviewTerm<CR>",       desc = "Terminal browser preview" },
        },
    },

    -- ─── Dadbod: Database Visual UI ─────────────────────────────────────────
    -- Visualizes your backend databases (SQL, Postgres, MongoDB, etc.)
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
        end,
        keys = {
            { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Database UI" },
        },
    },
}
