local icons = require("configs.base.ui.icons")

local config = {}

config.mason_nvim = function()
    vim.api.nvim_create_user_command(
        "LvimInstallLangDependencies",
        "lua require('languages.utils.lsp_manager').install_all_packages()",
        {}
    )
    vim.api.nvim_create_user_command("LspHover", "lua vim.lsp.buf.hover()", {})
    vim.api.nvim_create_user_command("LspRename", "lua vim.lsp.buf.rename()", {})
    vim.api.nvim_create_user_command("LspFormat", "lua vim.lsp.buf.format {async = false}", {})
    vim.api.nvim_create_user_command("LspCodeAction", "lua vim.lsp.buf.code_action()", {})
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticCurrent",
        "lua require('languages.base.utils.show_diagnostic').line()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticNext",
        "lua require('languages.base.utils.show_diagnostic').goto_next()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticPrev",
        "lua require('languages.base.utils.show_diagnostic').goto_prev()",
        {}
    )
    vim.api.nvim_create_user_command("LspDefinition", "lua vim.lsp.buf.definition()", {})
    vim.api.nvim_create_user_command("LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
    vim.api.nvim_create_user_command("LspDeclaration", "lua vim.lsp.buf.declaration()", {})
    vim.api.nvim_create_user_command("LspReferences", "lua vim.lsp.buf.references()", {})
    vim.api.nvim_create_user_command("LspImplementation", "lua vim.lsp.buf.implementation()", {})
    vim.api.nvim_create_user_command("LspSignatureHelp", "lua vim.lsp.buf.signature_help()", {})
    vim.api.nvim_create_user_command("LspDocumentSymbol", "lua vim.lsp.buf.document_symbol()", {})
    vim.api.nvim_create_user_command("LspWorkspaceSymbol", "lua vim.lsp.buf.workspace_symbol()", {})
    vim.api.nvim_create_user_command("LspCodeLensRefresh", "lua vim.lsp.codelens.refresh()", {})
    vim.api.nvim_create_user_command("LspCodeLensRun", "lua vim.lsp.codelens.run()", {})
    vim.api.nvim_create_user_command("LspAddToWorkspaceFolder", "lua vim.lsp.buf.add_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspRemoveWorkspaceFolder", "lua vim.lsp.buf.remove_workspace_folder()", {})
    vim.api.nvim_create_user_command("LspListWorkspaceFolders", "lua vim.lsp.buf.list_workspace_folders()", {})
    vim.api.nvim_create_user_command("LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
    vim.api.nvim_create_user_command("LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
    vim.api.nvim_create_user_command("LspClearReferences", "lua vim.lsp.buf.clear_references()", {})
    vim.api.nvim_create_user_command("LspDocumentHighlight", "lua vim.lsp.buf.document_highlight()", {})
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticCurrent",
        "lua require('languages.utils.show_diagnostics').line()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticNext",
        "lua require('languages.utils.show_diagnostics').goto_next()",
        {}
    )
    vim.api.nvim_create_user_command(
        "LspShowDiagnosticPrev",
        "lua require('languages.utils.show_diagnostics').goto_prev()",
        {}
    )
    vim.api.nvim_create_user_command("DAPLocal", "lua require('languages.utils.lsp_manager').dap_local()", {})
    vim.keymap.set("n", "<C-c><C-l>", function()
        vim.cmd("DAPLocal")
    end, { noremap = true, silent = true, desc = "DAPLocal" })
    vim.keymap.set("n", "dc", function()
        vim.cmd("LspShowDiagnosticCurrent")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticCurrent" })
    vim.keymap.set("n", "dn", function()
        vim.cmd("LspShowDiagnosticNext")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticNext" })
    vim.keymap.set("n", "dp", function()
        vim.cmd("LspShowDiagnosticPrev")
    end, { noremap = true, silent = true, desc = "LspShowDiagnosticPrev" })
    local mason_status_ok, mason = pcall(require, "mason")
    if not mason_status_ok then
        return
    end
    mason.setup({
        log_level = vim.log.levels.DEBUG,
        ui = {
            icons = icons.mason,
        },
    })
    require("languages.utils.setup_diagnostics").init_diagnostics()
    local efm_manager = require("languages.utils.efm_manager")
    efm_manager.setup_efm()
end

config.neotest = function()
    local neotest_status_ok, neotest = pcall(require, "neotest")
    if not neotest_status_ok then
        return
    end
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
        virtual_text = {
            format = function(diagnostic)
                local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                return message
            end,
        },
    }, neotest_ns)
    neotest.setup({
        adapters = {
            require("neotest-phpunit"),
            require("neotest-rust"),
            require("neotest-go"),
            require("neotest-python")({
                dap = { justMyCode = false },
                args = { "--log-level", "DEBUG" },
                runner = "pytest",
            }),
            require("neotest-elixir"),
            require("neotest-dart")({
                command = "flutter",
                use_lsp = true,
            }),
        },
    })
    vim.api.nvim_create_user_command("NeotestRun", function()
        require("neotest").run.run()
    end, {})
    vim.api.nvim_create_user_command("NeotestRunCurrent", function()
        require("neotest").run.run(vim.fn.expand("%"))
    end, {})
    vim.api.nvim_create_user_command("NeotestRunDap", function()
        require("neotest").run.run({ strategy = "dap" })
    end, {})
    vim.api.nvim_create_user_command("NeotestStop", function()
        require("neotest").run.stop()
    end, {})
    vim.api.nvim_create_user_command("NeotestAttach", function()
        require("neotest").run.attach()
    end, {})
    vim.api.nvim_create_user_command("NeotestOutput", function()
        require("neotest").output.open()
    end, {})
    vim.api.nvim_create_user_command("NeotestSummary", function()
        require("neotest").summary.toggle()
    end, {})
end

config.nvim_rip_substitute = function()
    local nvim_rip_substitute_status_ok, nvim_rip_substitute = pcall(require, "rip-substitute")
    if not nvim_rip_substitute_status_ok then
        return
    end
    nvim_rip_substitute.setup({
        popupWin = {
            title = "Replace",
            border = "single",
            matchCountHlGroup = "Keyword",
            noMatchHlGroup = "ErrorMsg",
            hideSearchReplaceLabels = false,
            position = "bottom",
        },
        keymaps = {
            confirm = "<CR>",
            abort = "q",
            prevSubstitutionInHistory = "<Up>",
            nextSubstitutionInHistory = "<Down>",
            insertModeConfirm = "<C-CR>",
        },
        incrementalPreview = {
            matchHlGroup = "IncSearch",
            rangeBackdrop = {
                enabled = true,
                blend = 40,
            },
        },
    })
end

config.glance_nvim = function()
    local glance_status_ok, glance = pcall(require, "glance")
    if not glance_status_ok then
        return
    end
    local actions = glance.actions
    glance.setup({
        zindex = 20,
        border = {
            enable = true,
            top_char = " ",
            bottom_char = " ",
        },
        list = {
            width = 0.4,
        },
        theme = {
            enable = false,
        },
        indent_lines = {
            enable = true,
            icon = "▏",
        },
        mappings = {
            list = {
                ["j"] = actions.next,
                ["k"] = actions.previous,
                ["<Tab>"] = actions.next_location,
                ["<S-Tab>"] = actions.previous_location,
                ["<C-u>"] = actions.preview_scroll_win(5),
                ["<C-d>"] = actions.preview_scroll_win(-5),
                ["v"] = actions.jump_vsplit,
                ["s"] = actions.jump_split,
                ["t"] = actions.jump_tab,
                ["<CR>"] = actions.jump,
                ["o"] = actions.jump,
                ["<C-h>"] = actions.enter_win("preview"),
                ["<Esc>"] = actions.close,
                ["q"] = actions.close,
            },
            preview = {
                ["q"] = actions.close,
                ["<Tab>"] = actions.next_location,
                ["<S-Tab>"] = actions.previous_location,
                ["<C-l>"] = actions.enter_win("list"),
            },
        },
        hooks = {
            before_open = function(results, open, jump, _)
                local uri = vim.uri_from_bufnr(0)
                if #results == 1 then
                    local target_uri = results[1].uri or results[1].targetUri
                    if target_uri == uri then
                        jump(results[1])
                    else
                        open(results)
                    end
                else
                    open(results)
                end
            end,
        },
    })
    vim.keymap.set("n", "gpd", "<Cmd>Glance definitions<CR>", { desc = "Glance definitions" })
    vim.keymap.set("n", "gpr", "<Cmd>Glance references<CR>", { desc = "Glance references" })
    vim.keymap.set("n", "gpt", "<Cmd>Glance type_definitions<CR>", { desc = "Glance type definitions" })
    vim.keymap.set("n", "gpi", "<Cmd>Glance implementations<CR>", { desc = "Glance implementations" })
end

config.trouble_nvim = function()
    local trouble_status_ok, trouble = pcall(require, "trouble")
    if not trouble_status_ok then
        return
    end
    trouble.setup({
        signs = {
            error = icons.diagnostics.error,
            warning = icons.diagnostics.warn,
            hint = icons.diagnostics.hint,
            information = icons.diagnostics.info,
            other = icons.diagnostics.other,
        },
    })
end

config.lazydev_nvim = function()
    local lazydev_status_ok, lazydev = pcall(require, "lazydev")
    if not lazydev_status_ok then
        return
    end
    lazydev.setup({
        library = {
            { path = "/usr/share/nvim/runtime/lua" },
            { path = "/usr/local/share/nvim/runtime/lua" },
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    })
end

config.flutter_tools_nvim = function()
    local setup_diagnostics = require("languages.utils.setup_diagnostics")
    local navic = require("nvim-navic")
    local flutter_tools_status_ok, flutter_tools = pcall(require, "flutter-tools")
    if not flutter_tools_status_ok then
        return
    end
    flutter_tools.setup({
        ui = {
            notification_style = "plugin",
        },
        closing_tags = {
            prefix = icons.common.separator .. " ",
            highlight = "FlutterInlineHint",
        },
        lsp = {
            auto_attach = true,
            on_attach = function(client, bufnr)
                setup_diagnostics.keymaps(client, bufnr)
                setup_diagnostics.document_highlight(client, bufnr)
                setup_diagnostics.document_auto_format(client, bufnr)
                setup_diagnostics.inlay_hint(client, bufnr)
                navic.attach(client, bufnr)
            end,
            autostart = true,
            capabilities = {
                textDocument = {
                    formatting = {
                        dynamicRegistration = false,
                    },
                    codeAction = {
                        dynamicRegistration = false,
                    },
                    hover = {
                        dynamicRegistration = false,
                    },
                    rename = {
                        dynamicRegistration = false,
                    },
                },
            },
            settings = {
                renameFilesWithClasses = "prompt",
            },
        },
    })
end

config.tailwind_tools_nvim = function()
    local tailwind_tools_status_ok, tailwind_tools = pcall(require, "tailwind-tools")
    if not tailwind_tools_status_ok then
        return
    end
    tailwind_tools.setup({
        document_color = {
            enabled = false,
            kind = "inline",
            inline_symbol = " ● ",
            debounce = 200,
        },
    })
end

config.nvim_px_to_rem = function()
    local nvim_px_to_rem_status_ok, nvim_px_to_rem = pcall(require, "nvim-px-to-rem")
    if not nvim_px_to_rem_status_ok then
        return
    end
    nvim_px_to_rem.setup({
        root_font_size = 16,
        decimal_count = 4,
        show_virtual_text = true,
        add_cmp_source = true,
        filetypes = {
            "css",
            "scss",
            "less",
            "astro",
        },
    })
end

config.nvim_lightbulb = function()
    local nvim_lightbulb_status_ok, nvim_lightbulb = pcall(require, "nvim-lightbulb")
    if not nvim_lightbulb_status_ok then
        return
    end
    nvim_lightbulb.setup({
        sign = {
            enabled = false,
        },
        virtual_text = {
            text = " " .. icons.common.light_bulb .. " ",
            enabled = true,
        },
        autocmd = {
            enabled = true,
            updatetime = 1,
        },
        ignore = {
            ft = { "dart" },
        },
    })
end

config.nvim_treesitter = function()
    local nvim_treesitter_configs_status_ok, nvim_treesitter_configs = pcall(require, "nvim-treesitter.configs")
    if not nvim_treesitter_configs_status_ok then
        return
    end
    nvim_treesitter_configs.setup({
        ensure_installed = "all",
        ignore_install = { "hoon", "systemverilog" },
        playground = {
            enable = true,
            disable = {},
            updatetime = 25,
            persist_queries = false,
            keybindings = {
                toggle_query_editor = "o",
                toggle_hl_groups = "i",
                toggle_injected_languages = "t",
                toggle_anonymous_nodes = "a",
                toggle_language_display = "I",
                focus_language = "f",
                unfocus_language = "F",
                update = "R",
                goto_node = "<CR>",
                show_help = "?",
            },
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "org" },
        },
        indent = {
            enable = true,
            disable = {
                "dart",
            },
        },
        autopairs = {
            enable = true,
        },
        rainbow = {
            enable = true,
        },
        context_commentstring = {
            enable = true,
            config = {
                javascriptreact = {
                    style_element = "{/*%s*/}",
                },
            },
        },
        matchup = {
            enable = true,
            disable_virtual_text = true,
        },
    })
end

config.nvim_navic = function()
    local nvim_navic_status_ok, nvim_navic = pcall(require, "nvim-navic")
    if not nvim_navic_status_ok then
        return
    end
    nvim_navic.setup({
        icons = icons.lsp,
        highlight = true,
        separator = " " .. icons.common.separator,
    })
    vim.g.navic_silence = true
end

config.nvim_navbuddy = function()
    local nvim_navbuddy_status_ok, nvim_navbuddy = pcall(require, "nvim-navbuddy")
    if not nvim_navbuddy_status_ok then
        return
    end
    nvim_navbuddy.setup({
        window = {
            border = "single",
            size = "80%",
            position = "50%",
            sections = {
                left = {
                    size = "33%",
                    border = nil,
                },
                mid = {
                    size = "34%",
                    border = nil,
                },
                right = {
                    size = "33%",
                    border = nil,
                },
            },
        },
        icons = icons.navbuddy,
        lsp = { auto_attach = true },
    })
    vim.keymap.set("n", "<C-c>v", function()
        nvim_navbuddy.open()
    end, { noremap = true, silent = true, desc = "Navbuddy" })
end

config.namu_nvim = function()
    local namu_status_ok, namu = pcall(require, "namu")
    if not namu_status_ok then
        return
    end
    namu.setup()
end

config.outline_nvim = function()
    local outline_status_ok, outline = pcall(require, "outline")
    if not outline_status_ok then
        return
    end
    outline.setup({
        outline_window = {
            winhl = "Normal:SideBar,NormalNC:SideBarNC",
        },
        preview_window = {
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
            winhl = "Normal:SideBar,NormalNC:SideBarNC",
        },
        symbols = {
            icons = icons.outline,
        },
    })
    vim.keymap.set("n", "<A-v>", function()
        vim.cmd("Outline")
    end, { noremap = true, silent = true, desc = "Outline" })
end

config.nvim_dap = function()
    local dap_status_ok, dap = pcall(require, "dap")
    if not dap_status_ok then
        return
    end
    local dap_view_status_ok, dap_view = pcall(require, "dap-view")
    if not dap_view_status_ok then
        return
    end
    vim.fn.sign_define("DapBreakpoint", {
        text = icons.dap_ui.sign.breakpoint,
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapBreakpointRejected", {
        text = icons.dap_ui.sign.reject,
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapBreakpointCondition", {
        text = icons.dap_ui.sign.condition,
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapStopped", {
        text = icons.dap_ui.sign.stopped,
        texthl = "DapStopped",
        linehl = "",
        numhl = "",
    })
    vim.fn.sign_define("DapLogPoint", {
        text = icons.dap_ui.sign.log_point,
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
    })
    vim.api.nvim_create_user_command("LuaDapLaunch", 'lua require"osv".run_this()', {})
    vim.api.nvim_create_user_command("DapToggleBreakpoint", 'lua require("dap").toggle_breakpoint()', {})
    vim.api.nvim_create_user_command("DapClearBreakpoints", 'lua require("dap").clear_breakpoints()', {})
    vim.api.nvim_create_user_command("DapRunToCursor", 'lua require("dap").run_to_cursor()', {})
    vim.api.nvim_create_user_command("DapContinue", 'lua require"dap".continue()', {})
    vim.api.nvim_create_user_command("DapStepInto", 'lua require"dap".step_into()', {})
    vim.api.nvim_create_user_command("DapStepOver", 'lua require"dap".step_over()', {})
    vim.api.nvim_create_user_command("DapStepOut", 'lua require"dap".step_out()', {})
    vim.api.nvim_create_user_command("DapUp", 'lua require"dap".up()', {})
    vim.api.nvim_create_user_command("DapDown", 'lua require"dap".down()', {})
    vim.api.nvim_create_user_command("DapPause", 'lua require"dap".pause()', {})
    vim.api.nvim_create_user_command("DapClose", 'lua require"dap".close()', {})
    vim.api.nvim_create_user_command("DapDisconnect", 'lua require"dap".disconnect()', {})
    vim.api.nvim_create_user_command("DapRestart", 'lua require"dap".restart()', {})
    vim.api.nvim_create_user_command("DapToggleRepl", 'lua require"dap".repl.toggle()', {})
    vim.api.nvim_create_user_command("DapGetSession", 'lua require"dap".session()', {})
    vim.api.nvim_create_user_command(
        "DapUIClose",
        'lua require"dap".close(); require"dap".disconnect(); require"dapui".close()',
        {}
    )
    vim.keymap.set("n", "<A-1>", function()
        dap.toggle_breakpoint()
    end, { noremap = true, silent = true, desc = "DapToggleBreakpoint" })
    vim.keymap.set("n", "<A-2>", function()
        dap.continue()
    end, { noremap = true, silent = true, desc = "DapContinue" })
    vim.keymap.set("n", "<A-3>", function()
        dap.step_into()
    end, { noremap = true, silent = true, desc = "DapStepInto" })
    vim.keymap.set("n", "<A-4>", function()
        dap.step_over()
    end, { noremap = true, silent = true, desc = "DapStepOver" })
    vim.keymap.set("n", "<A-5>", function()
        dap.step_out()
    end, { noremap = true, silent = true, desc = "DapStepOut" })
    vim.keymap.set("n", "<A-6>", function()
        dap.up()
    end, { noremap = true, silent = true, desc = "DapUp" })
    vim.keymap.set("n", "<A-7>", function()
        dap.down()
    end, { noremap = true, silent = true, desc = "DapDown" })
    vim.keymap.set("n", "<A-8>", function()
        dap.close()
        dap.disconnect()
        dap_view.close()
    end, { noremap = true, silent = true, desc = "DapUIClose" })
    vim.keymap.set("n", "<A-9>", function()
        dap.restart()
    end, { noremap = true, silent = true, desc = "DapRestart" })
    vim.keymap.set("n", "<A-0>", function()
        dap.repl.toggle()
    end, { noremap = true, silent = true, desc = "DapToggleRepl" })
    dap.listeners.after.event_initialized["dapui_config"] = function()
        vim.defer_fn(function()
            dap_view.open()
        end, 200)
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dap_view.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dap_view.close()
    end
end

config.nvim_dbee = function()
    local nvim_dbee_status_ok, nvim_dbee = pcall(require, "dbee")
    if not nvim_dbee_status_ok then
        return
    end
    nvim_dbee.setup()
end

config.package_info_nvim = function()
    local package_info_status_ok, package_info = pcall(require, "package-info")
    if not package_info_status_ok then
        return
    end
    package_info.setup()
    vim.api.nvim_create_user_command("PackageInfoToggle", "lua require('package-info').toggle()", {})
    vim.api.nvim_create_user_command("PackageInfoDelete", "lua require('package-info').delete()", {})
    vim.api.nvim_create_user_command("PackageInfoChangeVersion", "lua require('package-info').change_version()", {})
    vim.api.nvim_create_user_command("PackageInfoInstall", "lua require('package-info').install()", {})
end

config.crates_nvim = function()
    local crates_status_ok, crates = pcall(require, "crates")
    if not crates_status_ok then
        return
    end
    crates.setup({})
    vim.api.nvim_create_user_command("CratesUpdate", "lua require('crates').update()", {})
    vim.api.nvim_create_user_command("CratesReload", "lua require('crates').reload()", {})
    vim.api.nvim_create_user_command("CratesHide", "lua require('crates').hide()", {})
    vim.api.nvim_create_user_command("CratesToggle", "lua require('crates').toggle()", {})
    vim.api.nvim_create_user_command("CratesUpdateCrate", "lua require('crates').update_crate()", {})
    vim.api.nvim_create_user_command("CratesUpdateCrates", "lua require('crates').update_crates()", {})
    vim.api.nvim_create_user_command("CratesUpdateAllCrates", "lua require('crates').update_all_crates()", {})
    vim.api.nvim_create_user_command("CratesUpgradeCrate", "lua require('crates').upgrade_crate()", {})
    vim.api.nvim_create_user_command("CratesUpgradeCrates", "lua require('crates').upgrade_crates()", {})
    vim.api.nvim_create_user_command("CratesUpgradeAllCrates", "lua require('crates').upgrade_all_crates()", {})
    vim.api.nvim_create_user_command(
        "CratesShowPopup",
        "lua require('crates').show_popup() require('crates').focus_popup()",
        {}
    )
    vim.api.nvim_create_user_command(
        "CratesShowVersionsPopup",
        "lua require('crates').show_versions_popup() require('crates').focus_popup()",
        {}
    )
    vim.api.nvim_create_user_command(
        "CratesShowFeaturesPopup",
        "lua require('crates').show_features_popup() require('crates').focus_popup()",
        {}
    )
    vim.api.nvim_create_user_command("CratesFocusPopup", "lua require('crates').focus_popup()", {})
    vim.api.nvim_create_user_command("CratesHidePopup", "lua require('crates').hide_popup()", {})
end

config.pubspec_assist_nvim = function()
    local pubspec_assist_status_ok, pubspec_assist = pcall(require, "pubspec-assist")
    if not pubspec_assist_status_ok then
        return
    end
    pubspec_assist.setup({
        highlights = {
            up_to_date = "PubspecDependencyUpToDate",
            outdated = "PubspecDependencyOutdated",
            unknown = "PubspecDependencyUnknown",
        },
    })
end

config.markdown_preview_nvim = function()
    vim.keymap.set("n", "<S-m>", function()
        vim.cmd("MarkdownPreview")
    end, { noremap = true, silent = true, desc = "MarkdownPreview" })
end

config.markview_nvim = function()
    local markview_status_ok, markview = pcall(require, "markview")
    if not markview_status_ok then
        return
    end
    markview.setup({
        block_quotes = require("modules.base.configs.languages.markview.block_quotes"),
        code_blocks = require("modules.base.configs.languages.markview.code_blocks"),
        checkboxes = require("modules.base.configs.languages.markview.checkboxes"),
        markdown = {
            headings = require("modules.base.configs.languages.markview.headings"),
            tables = require("modules.base.configs.languages.markview.tables"),
            list_items = require("modules.base.configs.languages.markview.list_items"),
        },
    })
    require("markview.extras.editor").setup({
        width = { 10, 0.75 },
        height = { 3, 0.75 },
        debounce = 50,
    })
end

config.helpview_nvim = function()
    local helpview_status_ok, helpview = pcall(require, "helpview")
    if not helpview_status_ok then
        return
    end
    helpview.setup()
end

config.mkdnflow_nvim = function()
    local mkdnflow_nvim_status_ok, mkdnflow_nvim = pcall(require, "mkdnflow")
    if not mkdnflow_nvim_status_ok then
        return
    end
    mkdnflow_nvim.setup({
        to_do = {
            symbols = { "", "󱑁", "" },
            update_parents = true,
            not_started = "",
            in_progress = "󱑁",
            complete = "",
        },
    })
end

config.vimtex = function()
    vim.g.vimtex_mappings_prefix = "'"
    vim.g.vimtex_view_method = "zathura"
    vim.g.latex_view_general_viewer = "zathura"
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_compiler_callback_compiling = "nvr"
    vim.g.vimtex_quickfix_open_on_warning = 0
end

config.orgmode = function()
    local orgmode_status_ok, orgmode = pcall(require, "orgmode")
    if not orgmode_status_ok then
        return
    end
    orgmode.setup({
        emacs_config = {
            config_path = "~/.emacs.d/early-init.el",
        },
        org_agenda_files = { "~/Org/**/*" },
        org_default_notes_file = "~/Org/refile.org",
    })
end

config.lvim_org_utils = function()
    local lvim_org_utils_status_ok, lvim_org_utils = pcall(require, "lvim-org-utils")
    if not lvim_org_utils_status_ok then
        return
    end
    lvim_org_utils.setup()
end

return config
