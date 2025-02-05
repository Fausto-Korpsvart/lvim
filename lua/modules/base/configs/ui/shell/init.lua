local lvim_shell = require("lvim-shell")
local config = {}

local M = {}

M.Neomutt = function(dir)
    dir = dir or "."
    lvim_shell.float("TERM=kitty-direct neomutt", "<CR>", config)
end

M.Ranger = function(dir)
    dir = dir or "."
    lvim_shell.float("ranger --choosefiles=/tmp/lvim-shell " .. dir, "l", config)
end

M.Vifm = function(dir)
    dir = dir or "."
    lvim_shell.float("vifm --choose-files /tmp/lvim-shell " .. dir, "l", config)
end

M.LazyGit = function(dir)
    dir = dir or "."
    os.execute("printf '\\e]4;241;%s\\a' \"$(xrdb -query | awk '/\\*color3:/ {print $2}')\"")
    lvim_shell.float("lazygit -w " .. dir, "<CR>", nil)
end

M.LazyDocker = function()
    lvim_shell.float("lazydocker", "<CR>", config)
end

return M
