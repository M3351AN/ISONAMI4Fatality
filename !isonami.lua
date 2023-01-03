--da, ia ist m1tZw desu!!

local shotFl = gui.add_checkbox("on shot fl0", "lua>tab a")--
local shotDuck = gui.add_checkbox("on shot duck", "lua>tab a")--
local jumpScoutOvr = gui.add_checkbox("jump scout hitchance ovr", "lua>tab a")--
local jumpScoutHc = gui.add_slider("jump scout hitchance", "lua>tab a", 0, 100, 1)

local resetShot = false--
local resetJump = false--
local shotTime = 0--
local originFl = 0--
local originHc = 0--
local flSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Mode")
local desyncSetting = gui.get_config_item("Rage>Anti-Aim>Desync>Fake")
local fdSetting = gui.get_config_item("Misc>Movement>Fake duck")
local scoutHcSetting = gui.get_config_item("Rage>Aimbot>Ssg08>Scout>Hitchance")

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

local function jump_scout()
    local lPEntity = entities.get_entity(engine.get_local_player())
    if lPEntity == nil or not jumpScoutOvr:get_bool()then
        return
    end
    if lPEntity:get_prop("m_hGroundEntity") == -1 and not resetJump then
        originHc = scoutHcSetting:get_int()
        scoutHcSetting:set_int(jumpScoutHc:get_int())
        resetJump = true
    elseif lPEntity:get_prop("m_hGroundEntity")  ~= -1 and resetJump then
        scoutHcSetting:set_int(originHc)
        resetJump = false
    else
        return
    end
end
local function shot_timer()
    if resetShot and shotTime < global_vars.tickcount then 
        desyncSetting:set_bool(true)
        flSetting:set_int(originFl)--
        if shotDuck:get_bool() then
            fdSetting:set_bool(false)--engine.exec("-duck")
        end
        resetShot = false--
    elseif resetShot and shotTime > global_vars.tickcount then--anti other fl luas.15ticks such long long a time right?
        desyncSetting:set_bool(false)
        flSetting:set_int(0)--
        fdSetting:set_bool(true)--anti keybind
    end--
end
local function on_shot(shot)
    if not (shotFl:get_bool() or shotDuck:get_bool()) then--
        return--
    end--
        
    if not resetShot then
        if shotFl:get_bool() then
            originFl = flSetting:get_int() --fetch origin fl
            desyncSetting:set_bool(false)--set desync 0
            flSetting:set_int(0)
        end
        if shotDuck:get_bool() then
            fdSetting:set_bool(true)--engine.exec("+duck")
        end
        shotTime = global_vars.tickcount + 15
        resetShot = true
        return
    else
        desyncSetting:set_bool(false)--set desync 0
        flSetting:set_int(0)
        shotTime = global_vars.tickcount + 14
        return
    end
end

function on_shot_registered(shot)
    on_shot(shot)
end

function on_create_move()--
    jump_scout()
    shot_timer()
end

