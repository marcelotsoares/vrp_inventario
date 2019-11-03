description "Inventario Ice Base"

dependency "vrp"

client_script {
    "@vrp/lib/utils.lua",
    "client.lua"
}

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/ui.css",
    "html/ui.js",
    "html/sweetalert2.all.min.js",
    "html/fonts",
    "html/fonts/big_noodle_titling-webfont.woff",
    "html/fonts/big_noodle_titling-webfont.woff2",
    "html/fonts/pricedown.ttf",
    -- Imagens
    "html/images/water.png",
    "html/images/tacos.png",
    "html/images/WEAPON_PISTOL.png",
    "html/images/WEAPON_CARBINERIFLE.png"
}