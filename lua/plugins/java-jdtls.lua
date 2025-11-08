return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {
      setup = {
        jdtls = function(_, _)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
              local jdtls = require("jdtls")
              local mason_jdtls = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
              local launcher = vim.fn.glob(mason_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")

              local root_dir = require("jdtls.setup").find_root({ "mvnw", "pom.xml", "gradlew", "build.gradle" })
              if not root_dir or launcher == "" then return end

              _G.jdtls_active = _G.jdtls_active or {}
              if _G.jdtls_active[root_dir] then return end
              _G.jdtls_active[root_dir] = true

              local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
              local workspace_dir = vim.fn.expand("~/.workspace/") .. project_name

              local function on_attach(_, bufnr)
                local function map(mode, lhs, rhs, desc)
                  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
                end
                map("n", "<leader>di", function() jdtls.organize_imports() end, "Organize Imports")
                map("n", "<leader>dt", function() jdtls.test_class() end, "Test Class")
                map("n", "<leader>dn", function() jdtls.test_nearest_method() end, "Test Nearest Method")
                map("v", "<leader>de", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable")
                map("v", "<leader>dm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method")
                map("n", "<leader>de", function() jdtls.extract_variable() end, "Extract Variable")
                map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
              end

              local cmd = {
                "/usr/bin/java",
                "-javaagent:" .. mason_jdtls .. "/lombok.jar",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens", "java.base/java.util=ALL-UNNAMED",
                "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                "-jar", launcher,
                "-configuration", mason_jdtls .. "/config_mac_arm",
                "-data", workspace_dir,
              }

              local config = {
                cmd = cmd,
                root_dir = root_dir,
                on_attach = on_attach,
                single_file_support = false,
                settings = { java = {} },
                handlers = {
                  ["language/status"] = function() end,
                  ["$/progress"] = function() end,
                },
                capabilities = (pcall(require, "cmp_nvim_lsp") and require("cmp_nvim_lsp").default_capabilities()) or nil,
              }

              jdtls.start_or_attach(config)
            end,
          })
          return true
        end,
      },
    },
  },
}

