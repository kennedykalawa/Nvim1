return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        -- Use opts= instead of config= so lazy passes the table directly
        -- to the new nvim-treesitter setup API (no more require("nvim-treesitter.configs"))
        opts = {
            highlight = { enable = true },
            indent    = { enable = true },
            ensure_installed = {
                "json", "javascript", "typescript", "tsx",
                "go", "yaml", "html", "css", "python",
                "http", "prisma", "markdown", "markdown_inline",
                "svelte", "graphql", "bash", "lua", "vim",
                "dockerfile", "gitignore", "query", "vimdoc",
                "c", "java", "rust", "ron",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection    = "<C-space>",
                    node_incremental  = "<C-space>",
                    scope_incremental = false,
                },
            },
        },
        config = function(_, opts)
            -- The new treesitter API: just call require("nvim-treesitter").setup()
            -- Falls back gracefully if the old configs module is present too
            local ok, ts = pcall(require, "nvim-treesitter")
            if ok and ts.setup then
                ts.setup(opts)
            else
                -- Older versions still have configs module
                require("nvim-treesitter.configs").setup(opts)
            end
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        enabled = true,
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
        opts = {
            opts = {
                enable_close          = true,
                enable_rename         = true,
                enable_close_on_slash = false,
            },
            per_filetype = {
                ["html"]            = { enable_close = true },
                ["typescriptreact"] = { enable_close = true },
            },
        },
    },
}
