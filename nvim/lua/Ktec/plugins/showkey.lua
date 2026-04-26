return {
    {
        "nvzone/showkeys",
        lazy = true,
        cmd = "ShowkeysToggle",
        opts = {
            position = "bottom-center",
            maxkeys = 3,
            show_count = true,
            winopts = {
                focusable = false,
                relative = "editor",
                style = "minimal",
                border = "single",
                height = 1,
                row = 1,
                col = 0,
            },
        },
        -- OFF by default — toggle manually with :ShowkeysToggle
        -- Good for screen recording / demos only
        keys = {
            { "<leader>sk", "<cmd>ShowkeysToggle<CR>", desc = "Toggle showkeys" },
        },
    },
}
