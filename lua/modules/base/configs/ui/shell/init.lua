local lvim_shell = require("lvim-shell")
local config = {
    ui = {
        float = {
            height = 1,
            width = 1,
        },
    },
}

local M = {}

M.Neomutt = function(dir)
    dir = dir or "."
    lvim_shell.float("TERM=kitty-direct neomutt", "<CR>", nil)
end

M.Yazi = function(dir)
    dir = dir or "."
    lvim_shell.float("yazi --chooser-file=/tmp/lvim-shell " .. dir, "<CR>", config)
end

M.LazyGit = function(dir)
    dir = dir or "."
    os.execute("printf '\\e]4;241;%s\\a' \"$(xrdb -query | awk '/\\*color3:/ {print $2}')\"")
    lvim_shell.float("lazygit -w " .. dir, "<CR>", nil)
end

M.LazyDocker = function()
    lvim_shell.float("lazydocker", "<CR>", nil)
end

return M
