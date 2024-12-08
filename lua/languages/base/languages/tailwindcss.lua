local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "html", "astro", "css", "sass", "less", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "svelte"
}
local tailwindcssls_config = require("languages.base.languages._configs").without_formatting(ft, "tailwindcss")

local language_configs = {}

language_configs["dependencies"] = { "tailwindcss-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "tailwindcss",
        ["ft"] = ft,
        ["tailwindcss-language-server"] = { "tailwindcss", tailwindcssls_config },
    })
end

return language_configs
