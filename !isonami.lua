--.name ISONAMI4Fatality
--.description isonami.lua for fatality.win
--.author m1tZw
--da, ia ist m1tZw desu!!
--lua menu
local menu_elements = {
    shotFl = gui.add_checkbox("on shot fl0", "Lua>Tab A"),
    shotDuck = gui.add_checkbox("on shot duck", "Lua>Tab A"),
    jumpScoutOvr = gui.add_checkbox("jump scout hitchance ovr", "Lua>Tab A"),
    jumpScoutHc = gui.add_slider("jump scout hitchance", "Lua>Tab A", 0, 100, 1),
    breakLagcomp = gui.add_checkbox("break lag comp", "Lua>Tab A")
}
--cheat self setting
local cheat_refs = {
    flSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Mode"),
    flLimitSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Limit"),
    desyncSetting = gui.get_config_item("Rage>Anti-Aim>Desync>Fake"),
    fdSetting = gui.get_config_item("Misc>Movement>Fake duck"),
    scoutHcSetting = gui.get_config_item("Rage>Aimbot>Ssg08>Scout>Hitchance"),
    dtSetting = gui.get_config_item("rage>aimbot>aimbot>double tap"),
    antiExplSetting = gui.get_config_item("rage>aimbot>aimbot>anti-exploit"),
    peekSetting = gui.get_config_item("Misc>Movement>Peek Assist")
}
--init
local resetShot = false--
local resetJump = false--
local resetFl = false--
local shotTime = 0--
local originFl = 0--
local originHc = 0--
--function
local fpsBoost = gui.add_button("fps boost", "lua>tab a", function() 
    cvar.r_shadows:set_int(0)
    cvar.r_3dsky:set_int(0)
    cvar.r_shadows:set_int(0)
    cvar.cl_csm_static_prop_shadows:set_int(0)
    --cvar.cl_csm_shadows:set_int(0)
    cvar.cl_csm_world_shadows:set_int(0)
    cvar.cl_foot_contact_shadows:set_int(0)
    cvar.cl_csm_viewmodel_shadows:set_int(0)
    cvar.cl_csm_rope_shadows:set_int(0)
    cvar.cl_csm_sprite_shadows:set_int(0)
    cvar.cl_disablefreezecam:set_int(1)
    cvar.cl_freezecampanel_position_dynamic:set_int(0)
    cvar.cl_freezecameffects_showholiday:set_int(0)
    cvar.cl_showhelp:set_int(0)
    cvar.cl_autohelp:set_int(0)
    cvar.cl_disablehtmlmotd:set_int(1)
    cvar.mat_postprocess_enable:set_int(0)
    cvar.fog_enable_water_fog:set_int(0)
    cvar.gameinstructor_enable:set_int(0)
    cvar.cl_csm_world_shadows_in_viewmodelcascade:set_int(0)
    cvar.cl_disable_ragdolls:set_int(1)
    print("fps boosted!")
end)
local function break_lag()
    if menu_elements.breakLagcomp:get_bool() then 
       cheat_refs.flLimitSetting:set_int(utils.random_int(1, 2))
    end
end
local function jump_scout()
    local lPEntity = entities.get_entity(engine.get_local_player())
    if not lPEntity:is_valid() or not menu_elements.jumpScoutOvr:get_bool()then
        return
    end
    if lPEntity:get_prop("m_hGroundEntity") == -1 and not resetJump then
        originHc = cheat_refs.scoutHcSetting:get_int()
        cheat_refs.scoutHcSetting:set_int(menu_elements.jumpScoutHc:get_int())
        resetJump = true
    elseif lPEntity:get_prop("m_hGroundEntity")  ~= -1 and resetJump then
        cheat_refs.scoutHcSetting:set_int(originHc)
        resetJump = false
    else
        return
    end
end
local function shot_timer()
    if resetShot and shotTime < global_vars.tickcount then 
        cheat_refs.desyncSetting:set_bool(true)
        cheat_refs.flSetting:set_int(originFl)--
        if menu_elements.shotDuck:get_bool() then
            cheat_refs.fdSetting:set_bool(false)--engine.exec("-duck")
        end
        resetShot = false--
    elseif resetShot and shotTime > global_vars.tickcount then--anti other fl luas.15ticks such long long a time right?
        if menu_elements.shotFl:get_bool() then
        cheat_refs.desyncSetting:set_bool(false)
        cheat_refs.flSetting:set_int(0)--
        end
        if menu_elements.shotDuck:get_bool() and not cheat_refs.peekSetting:get_bool() then
        cheat_refs.fdSetting:set_bool(true)--anti keybind
        end
    end--
end
local function on_shot(shot)
    if not resetShot then
        if menu_elements.shotDuck:get_bool() then
            cheat_refs.fdSetting:set_bool(true)--engine.exec("+duck")
        end
        if not (menu_elements.shotFl:get_bool()) then--
            return--
        end--
        originFl = cheat_refs.flSetting:get_int() --fetch origin fl
        cheat_refs.desyncSetting:set_bool(false)--set desync 0
        cheat_refs.flSetting:set_int(0)
        shotTime = global_vars.tickcount + 15
        resetShot = true
        return
    else
        cheat_refs.desyncSetting:set_bool(false)--set desync 0
        cheat_refs.flSetting:set_int(0)
        shotTime = global_vars.tickcount + 14
        return
    end
end
--callback
function on_shot_registered(shot)
    on_shot(shot)
end
function on_create_move()--
    break_lag()
    jump_scout()
    shot_timer()
end
