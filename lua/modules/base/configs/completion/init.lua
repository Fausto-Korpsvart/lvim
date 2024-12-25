local config = {}

config.blink_cmp = function()
    local blink_cmp_status_ok, blink_cmp = pcall(require, "blink.cmp")
    if not blink_cmp_status_ok then
        return
    end
    local icons = require("configs.base.ui.icons")
    local lsp_symbols = icons.cmp
    blink_cmp.setup({
        snippets = {
            expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
            active = function(filter)
                if filter and filter.direction then
                    return require("luasnip").jumpable(filter.direction)
                end
                return require("luasnip").in_snippet()
            end,
            jump = function(direction) require("luasnip").jump(direction) end,
        },
        sources = {
            default = {
                "nvim-px-to-rem",
                "lsp",
                "path",
                "snippets",
                "ripgrep",
                "lazydev",
            },
            cmdline = function()
                local type = vim.fn.getcmdtype()
                if type == "/" or type == "?" then
                    return { "buffer" }
                end
                if type == ":" then
                    return { "cmdline" }
                end
                return {}
            end,
            providers = {
                lsp = {
                    fallbacks = { "lazydev" },
                },
                ["nvim-px-to-rem"] = {
                    module = "nvim-px-to-rem.integrations.blink",
                    name = "nvim-px-to-rem",
                },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                },
                ripgrep = {
                    module = "blink-cmp-rg",
                    name = "Ripgrep",
                    opts = {
                        prefix_min_len = 3,
                        get_command = function(_, prefix)
                            return {
                                "rg",
                                "--no-config",
                                "--json",
                                "--word-regexp",
                                "--ignore-case",
                                "--",
                                prefix .. "[\\w_-]+",
                                vim.fs.root(0, ".git") or vim.fn.getcwd(),
                            }
                        end,
                        get_prefix = function(context)
                            return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                        end,
                    },
                },
            },
        },
        appearance = {
            kind_icons = lsp_symbols,
        },
        completion = {
            accept = { auto_brackets = { enabled = true } },
            trigger = {
                show_on_insert_on_trigger_character = false,
            },
            menu = {
                draw = {
                    padding = 2,
                    gap = 1,
                    treesitter = { "lsp" },
                    columns = {
                        { "kind_icon" },
                        { "label",    "label_description", gap = 1 },
                        { "kind" }
                    },
                },
                cmdline_position = function()
                    if vim.g.ui_cmdline_pos ~= nil then
                        local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                        return { pos[1] - 1, pos[2] }
                    end
                    local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                    return { vim.o.lines - height, 0 }
                end,
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 10,
                treesitter_highlighting = true,
            },
            ghost_text = {
                enabled = true,
            },
        },
        keymap = {
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<Up>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-h>"] = { "scroll_documentation_down", "fallback" },
            ["<C-l>"] = { "scroll_documentation_up", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            cmdline = {
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                ["<C-l>"] = { "scroll_documentation_up", "fallback" },
            }
        },
    })
end

config.lua_snippets = function()
    local config_path = vim.fn.stdpath("config")
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { config_path .. "/vscode" } })
end

config.nvim_autopairs = function()
    local nvim_autopairs_status_ok, nvim_autopairs = pcall(require, "nvim-autopairs")
    if not nvim_autopairs_status_ok then
        return
    end
    nvim_autopairs.setup({
        check_ts = true,
        ts_config = {
            lua = {
                "string",
            },
            javascript = {
                "template_string",
            },
            java = false,
        },
    })
    local rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    local ts_conds = require("nvim-autopairs.ts-conds")
    local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
    nvim_autopairs.add_rules({
        rule(" ", " ", "-markdown")
            :with_pair(function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({
                    brackets[1][1] .. brackets[1][2],
                    brackets[2][1] .. brackets[2][2],
                    brackets[3][1] .. brackets[3][2],
                }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(function(opts)
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local context = opts.line:sub(col - 1, col + 2)
                return vim.tbl_contains({
                    brackets[1][1] .. "  " .. brackets[1][2],
                    brackets[2][1] .. "  " .. brackets[2][2],
                    brackets[3][1] .. "  " .. brackets[3][2],
                }, context)
            end),
    })
    for _, bracket in pairs(brackets) do
        nvim_autopairs.add_rules({
            rule(bracket[1] .. " ", " " .. bracket[2])
                :with_pair(function()
                    return false
                end)
                :with_del(function()
                    return false
                end)
                :with_move(function(opts)
                    return opts.prev_char:match(".%" .. bracket[2]) ~= nil
                end)
                :use_key(bracket[2]),
            rule(bracket[1], bracket[2]):with_pair(cond.after_text("$")),
            rule(bracket[1] .. bracket[2], ""):with_pair(function()
                return false
            end),
        })
    end
    nvim_autopairs.add_rule(rule("$", "$", "markdown")
        :with_move(function(opts)
            return opts.next_char == opts.char
                and ts_conds.is_ts_node({
                    "inline_formula",
                    "displayed_equation",
                    "math_environment",
                })(opts)
        end)
        :with_pair(ts_conds.is_not_ts_node({
            "inline_formula",
            "displayed_equation",
            "math_environment",
        }))
        :with_pair(cond.not_before_text("\\")))
    nvim_autopairs.add_rule(rule("/**", "  */"):with_pair(cond.not_after_regex(".-%*/", -1)):set_end_pair_length(3))
    nvim_autopairs.add_rule(rule("**", "**", "markdown"):with_move(function(opts)
        return cond.after_text("*")(opts) and cond.not_before_text("\\")(opts)
    end))
end

config.nvim_ts_autotag = function()
    local nvim_ts_autotag_status_ok, nvim_ts_autotag = pcall(require, "nvim-ts-autotag")
    if not nvim_ts_autotag_status_ok then
        return
    end
    nvim_ts_autotag.setup()
end

config.nvim_surround = function()
    local nvim_surround_status_ok, nvim_surround = pcall(require, "nvim-surround")
    if not nvim_surround_status_ok then
        return
    end
    nvim_surround.setup()
end

return config
