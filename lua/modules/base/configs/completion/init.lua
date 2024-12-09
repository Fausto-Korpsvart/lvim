local config = {}

config.nvim_cmp = function()
    local icons = require("configs.base.ui.icons")
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then
        return
    end
    local snip_status_ok, luasnip = pcall(require, "luasnip")
    if not snip_status_ok then
        return
    end
    require("luasnip.loaders.from_lua").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets/vscode" })
    require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets/lua" })
    local check_backspace = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local lsp_symbols = icons.cmp

    local extract_color = function(s)
        local base, _, _, r, g, b = 10, s:find("rgba?%((%d+).%s*(%d+).%s*(%d+)")
        if not r then
            base, _, _, r, g, b = 16, s:find("#(%x%x)(%x%x)(%x%x)")
        end
        if r then return tonumber(r, base), tonumber(g, base), tonumber(b, base) end
    end

    local set_hl_from = function(red, green, blue, style)
        local suffix = style == "background" and "Bg" or "Fg"
        local color = string.format("%02x%02x%02x", red, green, blue)
        local hl_name = "TailwindColor" .. suffix .. color
        local opts
        if style == "background" then
            local luminance = red * 0.299 + green * 0.587 + blue * 0.114
            local fg = luminance > 186 and "#000000" or "#FFFFFF"
            opts = { fg = fg, bg = "#" .. color }
        else
            opts = { fg = "#" .. color }
        end
        if not vim.api.nvim_get_hl(0, { name = hl_name })[1] then
            vim.api.nvim_set_hl(0, hl_name, opts)
        end
        return hl_name
    end

    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = {
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-Leader>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.close(),
            ["<CR>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expandable() then
                    luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif require("neogen").jumpable() then
                    require("neogen").jump_next()
                elseif check_backspace() then
                    fallback()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                elseif require("neogen").jumpable() then
                    require("neogen").jump_prev()
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        window = {
            completion = {
                winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                col_offset = -3,
                side_padding = 0,
            },
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, item)
                -- item.kind = lsp_symbols[item.kind]
                -- item.menu = ({
                --     nvim_lsp = "[LSP]",
                --     luasnip = "[Snippet]",
                --     buffer = "[Buffer]",
                --     path = "[Path]",
                --     crates = "[Crates]",
                --     latex_symbols = "[LaTex]",
                --     orgmode = "[ORG]",
                --     mkdnflow = "[Markdown]",
                -- })[entry.source.name]
                -- return item
                --
                local doc = entry.completion_item.documentation
                local lspkind = require("lspkind")
                local kind = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, item)
                local strings = vim.split(kind.kind, "%s", { trimempty = true })
                item.kind = " " .. (strings[1] or "") .. " "
                item.menu = "    (" .. (strings[2] or "") .. ")"
                if strings[2] == "Color" and doc then
                    local content = type(doc) == "string" and doc or doc.value
                    local r, g, b = extract_color(content)
                    if r and g and b then
                        local style = "background"
                        local hl_group = set_hl_from(r, g, b, style)
                        item.kind_hl_group = hl_group
                    end
                end
                return item
            end,
        },
        sources = {
            {
                name = "nvim_lsp",
            },
            {
                name = "luasnip",
            },
            {
                name = "buffer",
            },
            {
                name = "path",
            },
            {
                name = "crates",
            },
            {
                name = "latex_symbols",
            },
            {
                name = "orgmode",
            },
            {
                name = "mkdnflow",
            },
            {
                name = "lazydev",
                group_index = 0,
            }
        },
        view = {
            entries = {
                follow_cursor = true,
            },
        },
    })
    cmp.setup.cmdline({ ":", "/", "?", "Path to:" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            {
                name = "cmdline",
            },
            {
                name = "buffer",
            },
            {
                name = "path",
            },
        },
    })
    cmp.setup.cmdline({ "@", "Path to" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            {
                name = "path",
            },
        },
    })

    -- vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
    -- vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
    -- vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
    -- vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#EED8DA", bg = "#B5585F" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#C3E88D", bg = "#9FBD73" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = "#FFE082", bg = "#D4BB6C" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#EADFF0", bg = "#A377BF" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#EADFF0", bg = "#A377BF" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#EADFF0", bg = "#A377BF" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#C5CDD9", bg = "#7E8294" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })
    --
    -- vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
    -- -- vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
    -- vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })
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
