--da, ia ist m1tZw desu!!

local shotFl = gui.add_checkbox("onshotfl0", "lua>tab a")--

local resetShot = false--
local shotTime = 0--
local originFl = 0--
local flSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Mode")
local desyncSetting = gui.get_config_item("Rage>Anti-Aim>Desync>Fake")

function on_create_move()--
    if resetShot and shotTime < global_vars.tickcount then 
        desyncSetting:set_bool(true)
        flSetting:set_int(originFl)--
        resetShot = false--
    elseif resetShot and shotTime > global_vars.tickcount then--anti other fl luas.15ticks such long long a time right?
        desyncSetting:set_bool(false)
        flSetting:set_int(0)--
    end--
end
function on_shot_registered(shot)
    if not shotFl:get_bool() then--
        return--
    end--
    if 1 < 2 then--
        if not resetShot  then
            utils.print_console("red text", render.color("#FF0000"))
            originFl = flSetting:get_int() --fetch origin fl
            desyncSetting:set_bool(false)--set desync 0
            flSetting:set_int(0)
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
end

