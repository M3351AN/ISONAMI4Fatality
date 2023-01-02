--da, ia ist m1tZw desu!!

local shotFl = gui.add_checkbox("on shot fl0", "lua>tab a")--
local shotDuck = gui.add_checkbox("on shot duck", "lua>tab a")--

local resetShot = false--
local shotTime = 0--
local originFl = 0--
local flSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Mode")
local desyncSetting = gui.get_config_item("Rage>Anti-Aim>Desync>Fake")
local fdSetting = gui.get_config_item("Misc>Movement>Fake duck")

function on_create_move()--
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
function on_shot_registered(shot)
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

