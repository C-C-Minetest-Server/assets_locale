-- assets_locale_example.en.png  assets_locale_example.zh_TW.png

local MP = minetest.get_modpath("assets_locale")

assets_locale.register_asset("assets_locale_example.png",{
    en = MP .. "/textures/assets_locale_example.en.png",
    zh_TW = MP .. "/textures/assets_locale_example.zh_TW.png"
})

minetest.register_node("assets_locale:example", {
    description = "Assets Translation Example",
    tiles = {"assets_locale_example.png"},
    groups = { oddly_breakable_by_hand = 3 },
    drop = "",
})