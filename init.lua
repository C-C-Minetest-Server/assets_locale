-- Check for Minetest version
assert(minetest.features.dynamic_add_media_table,"This mod can only run on MT version >= 5.5.0!")

--- Translate textures and audios into different locale.
-- @module assets_locale
-- @author 1F616EMO
assets_locale = {}

assets_locale.registered_assets = {}

assets_locale.player_status = {}

--- Registration functions
-- @section reg

local TMP = minetest.get_worldpath() .. "/assets_locale_tmp/"
minetest.register_on_shutdown(function()
    minetest.rmdir(TMP, true)
end)

local function copy_file(src,dst)
    local f_src = assert(io.open(src,"rb"),"Attept to copy unexist file " .. src)
    local f_dst = assert(io.open(dst,"wb"),"Failed to create file " .. dst)

    local c_src = f_src:read("a")
    f_src:close()

    f_dst:write(c_src)
    f_dst:close()
end

--- Register a translated asset
-- @tparam string name The file name to be used in codes like node definition
-- @tparam {[string]=string,...} def Locale name as key, on-disk filename as value.
-- @usage local MP = minetest.get_modpath("assets_locale")
-- assets_locale.register_asset("example_test.png",{
--     en = MP .. "/textures/assets_locale_example.en.png",
--     zh_TW = MP .. "/textures/assets_locale_example.zh_TW.png"
-- })
function assets_locale.register_asset(name,def)
    assert(name, "[assets_locale] Attempt to register translated asset without a core filename")
    assert(def.en, "[assets_locale] Attempt to register translated asset without a English (en) filename")
    ---@diagnostic disable-next-line: undefined-field
    local def = table.copy(def)
    -- @todo: Directly specify filename in dynamic_add_media, wait for engine support
    minetest.log("action","Copying asset files of " .. name)
    for k,v in pairs(def) do
        minetest.mkdir(TMP .. k)
        local dst = TMP .. k .. "/" .. name
        copy_file(v,dst)
        def[k] = dst
    end
    assets_locale.registered_assets[name] = def
end

--- Unregister a translated asset
-- @tparam string name The file name to be used in codes like node definition
-- @usage assets_locale.unregister_asset("example_test.png")
function assets_locale.unregister_asset(name)
    assert(name, "[assets_locale] Attempt to unregister translated asset without a core filename")
    assets_locale.registered_assets[name] = nil
end

minetest.register_on_mods_loaded(function()
    -- Invalidate the two register functions
    assets_locale.register_asset = function()
        error("[assets_locale] Attempt to call ssets_locale.register_asset after mods loaded")
    end
    assets_locale.unregister_asset = function()
        error("[assets_locale] Attempt to call ssets_locale.unregister_asset after mods loaded")
    end
end)

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local pl_info = minetest.get_player_information(name)
    local lang_code = pl_info.lang_code or "en"
    if not assets_locale.player_status[name] then
        assets_locale.player_status[name] = {}
    end
    for k,v in pairs(assets_locale.registered_assets) do
        if not v[lang_code] then
            lang_code = "en"
        end
        -- @fixme: This is too late if the texture is used on node definitions.
        minetest.dynamic_add_media({
            filepath = v[lang_code],
            to_player = name,
            ephemeral = true, -- The user may change their locale, so do not cache it
        }, function(name)
            minetest.log("action","[assets_locale] Asset " .. k .. " successfully sent to player " .. name)
            if not assets_locale.player_status[name] then return end
            assets_locale.player_status[name][k]= true
        end)
    end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    assets_locale.player_status[name] = nil
end)

dofile(minetest.get_modpath("assets_locale") .. "/examples.lua")


