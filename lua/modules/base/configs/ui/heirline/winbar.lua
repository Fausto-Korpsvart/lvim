local icons = require("configs.base.ui.icons")
local hl = require("configs.base.ui.highlight")

local M = {}

M.get_winbar = function()
    local heirline_conditions = require("heirline.conditions")
    local tabby_filename = require("tabby.filename")
    local space = { provider = " " }

    local file_types = {
        provider = function()
            local file_type = vim.bo.filetype
            if file_type ~= "" then
                return "  " .. string.upper(file_type)
            end
        end,
        hl = { fg = _G.LVIM_COLORS.blue, bold = true },
    }

    local file_icon_name = {
        provider = function()
            local function isempty(s)
                return s == nil or s == ""
            end
            local hl_group_1 = "FileTextColor"
            vim.api.nvim_set_hl(0, hl_group_1, {
                fg = _G.LVIM_COLORS.red,
                bg = _G.LVIM_COLORS.bg_dark,
                bold = true,
            })
            local win_id = vim.api.nvim_get_current_win()
            local filename = tabby_filename.unique(win_id)
            local extension = vim.fn.expand("%:e")
            if not isempty(filename) then
                local f_icon, f_icon_color =
                    require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
                local hl_group_2 = "FileIconColor" .. extension
                vim.api.nvim_set_hl(0, hl_group_2, { fg = f_icon_color, bg = _G.LVIM_COLORS.bg_dark })
                if isempty(f_icon) then
                    f_icon = ""
                end
                return "%#"
                    .. hl_group_2
                    .. "# "
                    .. f_icon
                    .. "%*"
                    .. " "
                    .. "%#"
                    .. hl_group_1
                    .. "#"
                    .. filename
                    .. "%*"
                    .. "  "
            end
        end,
        hl = { fg = _G.LVIM_COLORS.red },
    }

    local navic = {
        condition = function()
            return require("nvim-navic").is_available()
        end,
        static = {
            type_hl = hl.winbar,
            enc = function(line, col, winnr)
                return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
            end,
            dec = function(c)
                local line = bit.rshift(c, 16)
                local col = bit.band(bit.rshift(c, 6), 1023)
                local winnr = bit.band(c, 63)
                return line, col, winnr
            end,
        },
        init = function(self)
            local data = require("nvim-navic").get_data() or {}
            local children = {}
            for i, d in ipairs(data) do
                local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    {
                        provider = d.icon,
                        hl = self.type_hl[d.type],
                    },
                    {
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                        on_click = {
                            minwid = pos,
                            callback = function(_, minwid)
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                if #data > 1 and i < #data then
                    table.insert(child, {
                        provider = " " .. icons.common.separator .. " ",
                        hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.green },
                    })
                end
                table.insert(children, child)
            end
            self.child = self:new(children, 1)
        end,
        provider = function(self)
            return self.child:eval()
        end,
        hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.blue, bold = true },
        update = "CursorMoved",
    }

    local terminal_name = {
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return icons.common.terminal .. tname
        end,
        hl = { fg = _G.LVIM_COLORS.red, bold = true },
    }

    local winbar = {
        fallthrough = false,
        {
            condition = function()
                return heirline_conditions.buffer_matches({ buftype = { "terminal" } })
            end,
            {
                file_types,
                space,
                terminal_name,
            },
        },
        {
            condition = function()
                return not heirline_conditions.is_active()
            end,
            {
                file_icon_name,
            },
        },
        {
            file_icon_name,
            navic,
        },
    }

    return winbar
end

return M
