return {
    "mfussenegger/nvim-jdtls",
    ft = "java", -- 仅在打开 Java 文件时加载
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        -- 这里创建一个启动函数
        local function setup_jdtls()
            local jdtls = require("jdtls")
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
            local workspace_dir = vim.fn.stdpath("data") .. "/site/java-workspace/" .. project_name

            -- Mason 安装路径
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
            local launcher_jar = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
            -- WezTerm/macOS 环境下使用 config_mac
            local config_dir = mason_path .. "/config_mac"

            -- 复用你在 lsp.lua 里定义的 capabilities
            -- 注意：如果 capabilities 在 lsp.lua 是局部的，你可能需要将其导出或在这里重新定义
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local config = {
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-Xms1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens", "java.base/java.util=ALL-UNNAMED",
                    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                    "-jar", launcher_jar,
                    "-configuration", config_dir,
                    "-data", workspace_dir,
                },
                root_dir = jdtls.setup.find_root({ ".git", "pom.xml", "build.gradle" }),
                capabilities = capabilities,
                settings = {
                    java = {
                        signatureHelp = { enabled = true },
                        contentProvider = { preferred = 'fernflower' },
                        completion = {
                            favoriteStaticMembers = {
                                "org.junit.jupiter.api.Assertions.*",
                                "org.mockito.Mockito.*",
                            },
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    -- 复用你 lsp.lua 里的快捷键
                    -- 例如：gd, K, <leader>rn 等
                end,
            }
            jdtls.start_or_attach(config)
        end

        -- 绑定 FileType 事件
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = setup_jdtls,
        })
    end,
}
