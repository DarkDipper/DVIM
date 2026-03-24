return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },

    config = function()
        local jdtls = require("jdtls")

        -- lombok_path
        local function get_lombok_jar()
            local base = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok")

            local paths = vim.fn.globpath(base, "*/lombok-*.jar", false, true)

            if not paths or #paths == 0 then
                return nil
            end

            table.sort(paths)
            return paths[#paths]
        end

        local lombok_path = get_lombok_jar()
        vim.notify("LOMBOK_PATH: " .. (lombok_path or "nil"))

        -- Use JAVA_HOME from mise
        local java_home = vim.fn.getenv("JAVA_HOME")
        if java_home == nil or java_home == "" then
            java_home = vim.fn.system("mise where java"):gsub("\n", "")
        end

        -- Project name & workspace
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/" .. project_name

        -- Root detection
        local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local root_dir = require("jdtls.setup").find_root(root_markers)

        if root_dir == nil then
            return
        end

        -- Mason paths
        local mason_path = vim.fn.stdpath("data") .. "/mason/"
        local jdtls_path = mason_path .. "packages/jdtls/"
        local launcher = vim.fn.glob(jdtls_path .. "plugins/org.eclipse.equinox.launcher_*.jar")

        -- OS config (adjust if not Linux)
        local config_os = "config_linux"

        -- Debug/Test bundles
        local bundles = {}

        local java_debug_path = mason_path .. "packages/java-debug-adapter/"
        local java_test_path = mason_path .. "packages/java-test/"

        vim.list_extend(
            bundles,
            vim.split(vim.fn.glob(java_debug_path .. "extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
        )
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "extension/server/*.jar"), "\n"))

        -- Capabilities (safe fallback)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp = pcall(require, "cmp_nvim_lsp")
        if ok then
            capabilities = cmp.default_capabilities(capabilities)
        end

        local cmd = {
            java_home .. "/bin/java",
        }

        -- inject lombok ONLY if found
        if lombok_path then
            table.insert(cmd, "-javaagent:" .. lombok_path)
            table.insert(cmd, "-Xbootclasspath/a:" .. lombok_path)
        end

        -- rest of args
        vim.list_extend(cmd, {
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",

            "-jar",
            launcher,
            "-configuration",
            jdtls_path .. config_os,
            "-data",
            workspace_dir,
        }) -- JDTLS config
        local config = {
            cmd = cmd,

            root_dir = root_dir,
            capabilities = capabilities,

            settings = {
                java = {
                    configuration = {
                        runtimes = {
                            {
                                name = "JavaSE-21",
                                path = java_home,
                            },
                        },
                    },
                },
            },

            init_options = {
                bundles = bundles,
            },
        }

        -- Start or attach
        jdtls.start_or_attach(config)

        -- Enable DAP + tests
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
    end,
}
