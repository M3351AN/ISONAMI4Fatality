--.name ISONAMI4Fatality
--.description isonami.lua for fatality.win
--.author m1tZw
--da, ia ist m1tZw desu!!

--requirement
--local hook=require("hooks")
--ffi
local function vtable_bind(module, interface, index, type)
    local addr = ffi.cast("void***", utils.find_interface(module, interface)) or error(interface .. " is nil.")
    return ffi.cast(ffi.typeof(type), addr[0][index]), addr
end

local function __thiscall(func, this)
    return function(...)
        return func(this, ...)
    end
end

local function vtable_thunk(index, typestring)
    local t = ffi.typeof(typestring)
    return function(instance, ...)
        assert(instance ~= nil)
        if instance then
            local addr=ffi.cast("void***", instance)
            return __thiscall(ffi.cast(t, (addr[0])[index]),addr)
        end
    end
end

ffi.cdef[[
    typedef struct
    {
        char   pad0[0x14];             //0x0000
        bool        bProcessingMessages;    //0x0014
        bool        bShouldDelete;          //0x0015
        char   pad1[0x2];              //0x0016
        int         iOutSequenceNr;         //0x0018 last send outgoing sequence number
        int         iInSequenceNr;          //0x001C last received incoming sequence number
        int         iOutSequenceNrAck;      //0x0020 last received acknowledge outgoing sequence number
        int         iOutReliableState;      //0x0024 state of outgoing reliable data (0/1) flip flop used for loss detection
        int         iInReliableState;       //0x0028 state of incoming reliable data
        int         iChokedPackets;         //0x002C number of choked packets
        char   pad2[0x414];            //0x0030
    } INetChannel; // Size: 0x0444
]]

local nullptr = ffi.new('void*')

local nativeGetNetChannel = __thiscall(vtable_bind("engine.dll", "VEngineClient014", 78, "INetChannel*(__thiscall*)(void*)"))

local INetChannelPtr=nullptr

local nativeINetMessageGetType=vtable_thunk(7,"int(__thiscall*)(void*)")
local nativeINetChannelGetLatency=vtable_thunk(9,"float(__thiscall*)(void*,int)")
--lua menu
local menu_elements = {
    shotFl = gui.add_checkbox("on shot fl0", "Lua>Tab A"),
    shotDuck = gui.add_checkbox("on shot duck", "Lua>Tab A"),
    jumpScoutOvr = gui.add_checkbox("jump scout hitchance ovr", "Lua>Tab A"),
    jumpScoutHc = gui.add_slider("jump scout hitchance", "Lua>Tab A", 0, 100, 1),
    fakeLatency = gui.add_checkbox("fake latency", "Lua>Tab A"),
    bindLatency = gui.add_keybind("Lua>Tab A>fake latency"),
    fakeLantencyAmo = gui.add_slider("latency amount", "Lua>Tab A", 15, 180, 1) -- increase at own risk, anything above this value causes inaccuracy issues.
}
--cheat self setting
local cheat_refs = {
    flSetting = gui.get_config_item("Rage>Anti-Aim>Fakelag>Mode"),
    desyncSetting = gui.get_config_item("Rage>Anti-Aim>Desync>Fake"),
    fdSetting = gui.get_config_item("Misc>Movement>Fake duck"),
    scoutHcSetting = gui.get_config_item("Rage>Aimbot>Ssg08>Scout>Hitchance"),
    dtSetting = gui.get_config_item("rage>aimbot>aimbot>double tap"),
    antiExplSetting = gui.get_config_item("rage>aimbot>aimbot>anti-exploit")
}
--init
local resetShot = false--
local resetJump = false--
local shotTime = 0--
local originFl = 0--
local originHc = 0--
local vecSequences={}
local nLastIncomingSequence=0
local INetChannel
local initialize=false
local screen_width, screen_height = render.get_screen_size()
local y = screen_height / 2
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
        if menu_elements.shotDuck:get_bool() then
        cheat_refs.fdSetting:set_bool(true)--anti keybind
        end
    end--
end
local function on_shot(shot)
    if not (menu_elements.shotFl:get_bool() or menu_elements.shotDuck:get_bool()) then--
        return--
    end--
        
    if not resetShot then
        if menu_elements.shotFl:get_bool() then
            originFl = cheat_refs.flSetting:get_int() --fetch origin fl
            cheat_refs.desyncSetting:set_bool(false)--set desync 0
            cheat_refs.flSetting:set_int(0)
        end
        if menu_elements.shotDuck:get_bool() then
            cheat_refs.fdSetting:set_bool(true)--engine.exec("+duck")
        end
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


local function UpdateIncomingSequences(pNetChannel)
    if nLastIncomingSequence==0 then nLastIncomingSequence=pNetChannel.iInSequenceNr end
    if pNetChannel.iInSequenceNr > nLastIncomingSequence then
        nLastIncomingSequence=pNetChannel.iInSequenceNr
        table.insert(vecSequences,1,{pNetChannel.iInReliableState,pNetChannel.iChokedPackets,pNetChannel.iInSequenceNr,global_vars.realtime})
    end
    if #vecSequences > 128 then
        table.remove(vecSequences)
    end
end

local function ClearIncomingSequences()
nLastIncomingSequence=0
if #vecSequences~=0 then
    vecSequences={}
end
end

function SendDatagramHook(originalFunction)
local originalFunction=originalFunction
local sv_maxunlag = cvar["sv_maxunlag"]

    function clamp(min, max, value)
        return math.min(math.max(min, value), max)
    end

    function AddLatencyToNetChannel(pNetChannel,flMaxLatency)
        for i,sequence in ipairs(vecSequences) do
            if global_vars.realtime-sequence[4]>=flMaxLatency then
                pNetChannel.iInReliableState=sequence[1]
                pNetChannel.iInSequenceNr=sequence[3]
                break
            end
        end
    end

    function SendDatagram(this,pDatagram)
        local local_player = entities.get_entity(engine.get_local_player())
        if not engine.is_in_game() or not local_player:is_valid() or not menu_elements.enable_ping:get_bool() or cheat_refs.anti_exploit:get_bool() or pDatagram~=nullptr then
            return originalFunction(this,pDatagram)
        end

        local iOldInReliableState=this.iInReliableState
        local iOldInSequenceNr=this.iInSequenceNr

        local flMaxLatency=math.max(0,clamp(0,sv_maxunlag:get_float(),menu_elements.fakeLantencyAmo:get_int()/1000)-nativeINetChannelGetLatency(this)(0))
        AddLatencyToNetChannel(this,flMaxLatency)

        local res=originalFunction(this,pDatagram)

        this.iInReliableState=iOldInReliableState
        this.iInSequenceNr=iOldInSequenceNr

        return res
    end
    return SendDatagram
end
local function fake_latency(cmd)
    INetChannelPtr=nativeGetNetChannel()
    if menu_elements.fakeLatency:get_bool() then
        UpdateIncomingSequences(INetChannelPtr)
    else
        ClearIncomingSequences()
    end
    if initialize then return end
    initialize=true
    --INetChannel=hook.jmp.new("int(__thiscall*)(INetChannel*,void*)",SendDatagramHook,ffi.cast("intptr_t**",INetChannelPtr)[0][46],6,true)
end
local function fake_latency_indicator()
    render.text(render.font_indicator, 10, y + 200 , "PING", render.color(5,150,195,255), render.align_left, render.align_center)
end
--callback
function on_shot_registered(shot)
    on_shot(shot)
end
function on_setup_move(cmd)
    fake_latency(cmd)
end
function on_create_move()--
    jump_scout()
    shot_timer()
end
function on_frame_stage_notify(stage, pre_original)
    if engine.is_in_game() then return end
    ClearIncomingSequences()
end
function on_shutdown()
    if INetChannel~=nil then INetChannel.stop() end
end
function on_paint()
    if not engine.is_in_game() then
        return
    end
    fake_latency_indicator()
end