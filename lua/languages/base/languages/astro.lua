-- npm --save-dev install @angular/language-server @angular/language-service typescript
local lsp_manager = require("languages.utils.lsp_manager")
local ft = {
    "astro",
}
local astro_config = require("languages.base.languages._configs").astro_config(ft, "astro")

local language_configs = {}

language_configs["dependencies"] = { "astro-language-server" }

language_configs["lsp"] = function()
    lsp_manager.setup_languages({
        ["language"] = "astro",
        ["ft"] = ft,
        ["astro-language-server"] = { "astro", astro_config },
    })
end

return language_configs
