return {
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- 在这里可以进行自定义配置
            signs = true, -- 在左侧侧边栏显示图标
            keywords = {
                FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG" } },
                TODO = { icon = " ", color = "info" },
                todo = { icon = " ", color = "info" },
            }
        }
    }
}
