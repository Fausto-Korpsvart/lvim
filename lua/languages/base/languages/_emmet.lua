local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "html",
    "css",
    "typescriptreact",
    "javascriptreact",
    "astro",
}
local emmet_ls_config = require("languages.base.languages._configs").without_winbar_config(ft)

local language_configs = {}

language_configs["dependencies"] = { "emmet-ls" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "emmet",
        ["ft"] = ft,
        ["emmet-ls"] = { "emmet_ls", emmet_ls_config },
    })
end

return language_configs
