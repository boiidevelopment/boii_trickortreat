----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Variables
local cooldown_timer = 10 * 60 * 1000 -- convert minutes to milliseconds
local last_used = -cooldown_timer -- Initialize to negative of cooldown timer
--[[
    FUNCTIONS
]]

-- Function to execute actions 
local function execute_action(action_type)
    local chosen_category = nil
    if action_type == 'trick' then
        chosen_category = config.logic.tricks
    else
        chosen_category = config.logic.treats
    end
    local action_weights = {}
    for action_name, action_params in pairs(chosen_category) do
        if action_params.enabled then
            action_weights[#action_weights + 1] = action_name
        end
    end
    local chosen_action = action_weights[math.random(1, #action_weights)]
    local action_params = chosen_category[chosen_action]
    if action_params.action.type == 'function' then
        _G[action_params.action.execute](action_params.params)
    elseif action_params.action.type == 'client_event' then
        TriggerEvent(action_params.action.execute, action_params.params)
    elseif action_params.action.type == 'server_event' then
        TriggerServerEvent(action_params.action.execute, action_params.params)
    end
end

-- Function to display drawtext
local function draw_text(x, y, z, text, duration)
    local end_time = GetGameTimer() + duration
    CreateThread(function()
        while GetGameTimer() < end_time do
            local onScreen, _x, _y = World3dToScreen2d(x, y, z)
            local p = GetGameplayCamCoords()
            local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
            local scale = (1 / distance) * 2
            local fov = (1 / GetGameplayCamFov()) * 100
            local scale = scale * fov
            if onScreen then
                SetTextScale(0.0, 0.35 * scale)
                SetTextFont(0)
                SetTextProportional(1)
                SetTextColour(255, 255, 255, 255)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(2, 0, 0, 0, 150)
                SetTextDropShadow()
                SetTextOutline()
                SetTextCentre(1)
                SetTextEntry('STRING')
                AddTextComponentString(text)
                DrawText(_x,_y)
            end
            Wait(0)
        end
    end)
end

-- Function to handle trick or treat 
local function handle_trick_or_treat(player, closest_ped)         
    ClearPedTasks(closest_ped)
    FreezeEntityPosition(closest_ped, true)
    TaskTurnPedToFaceEntity(closest_ped, player, -1)
    local chance = math.random(1, 100)
    local message = 'Happy Halloween! Here\'s a '
    local action_type = 'treat'
    if chance <= config.logic.chances.trick then
        message = message .. 'trick'
        action_type = 'trick'
    else
        message = message .. 'treat'
    end
    message = message .. ' for you!'
    local closest_ped_coords = GetEntityCoords(closest_ped)
    draw_text(closest_ped_coords.x, closest_ped_coords.y, closest_ped_coords.z + 1.0, message, 3500)
    Wait(3500)
    FreezeEntityPosition(closest_ped, false)
    ClearPedTasks(player)
    ClearPedTasks(closest_ped)
    execute_action(action_type)
    Wait(10 * 60 * 1000)
end

-- Function to get nearest ped
local function get_nearest_ped(x, y, z)
    local near_ped = nil
    local player = PlayerPedId()
    local nearest_dist = 5.0
    for ped in EnumeratePeds() do
        if ped ~= player then
            local distance = #(vector3(x, y, z) - GetEntityCoords(ped))
            if distance < nearest_dist then
                near_ped = ped
                nearest_dist = distance
            end
        end
    end
    return near_ped
end

-- TRICKS:

-- Function to set a player on fire
function set_player_on_fire()
    local player = PlayerPedId()
    StartEntityFire(player)
    CreateThread(function()
        while true do
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Hot damn.. that was a fiery trick..')
            DrawSubtitleTimed(5000, 1)
            Wait(5000)
            break
        end
    end)
end

-- Function to set a player as drunk
function set_as_drunk(params)
    local player = PlayerPedId()
    local duration = params.duration or 60
    RequestAnimSet('move_m@drunk@verydrunk')
    while not HasAnimSetLoaded('move_m@drunk@verydrunk') do
        Wait(0)
    end
    SetPedMovementClipset(player, 'move_m@drunk@verydrunk', true)
    if not params.disable_screen_effects then
        ShakeGameplayCam('DRUNK_SHAKE', 1.0)
        SetTimecycleModifier('spectator5')
        SetPedMotionBlur(player, true)
    end
    SetPedIsDrunk(player, true)
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Who spiked your drink? Walk it off, champ! Only ' .. time_left .. ' seconds of tipsiness left!')
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    SetTimeout(duration * 1000, function()
        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(player, 0)
        SetPedIsDrunk(player, false)
        SetPedMotionBlur(player, false)
        StopGameplayCamShaking(true)
    end)
end

function rain_chickens(params)
    local player = PlayerPedId()
    local duration = params.duration or 60
    local amount = params.amount
    local spawned_chickens = {}
    local function get_random_coord(distance)
        local coords = GetEntityCoords(player)
        local random_x = math.random(-distance, distance)
        local random_y = math.random(-distance, distance)
        return vector3(coords.x + random_x, coords.y + random_y, coords.z + 50)
    end
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            BeginTextCommandPrint('STRING')
            AddTextComponentString('Oh ****! Its raining chickens! '.. time_left .. ' seconds remaining!')
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    for i=1, amount do
        Wait(500)
        local chicken_coords = get_random_coord(10.0)
        RequestModel(GetHashKey('a_c_hen'))
        while not HasModelLoaded(GetHashKey('a_c_hen')) do
            Wait(0)
        end
        local chicken = CreatePed(26, GetHashKey('a_c_hen'), chicken_coords.x, chicken_coords.y, chicken_coords.z, 0.0, true, false)
        TaskFollowToOffsetOfEntity(chicken, player, 0.0, 0.0, 0.0, 1.0, -1, 0.0, true)
        spawned_chickens[#spawned_chickens + 1] = chicken
    end
    SetTimeout(duration * 1000, function()
        for _, chicken in ipairs(spawned_chickens) do
            DeleteEntity(chicken)
        end
    end)
end

-- Function to spawn a random aggressive ped to fight player
function random_angry_ped(params)
    local player = PlayerPedId()
    local peds = params.peds
    local player_coords = GetEntityCoords(player)
    local random_ped_model = peds[math.random(#peds)]
    local selected_ped_model = GetHashKey(random_ped_model)
    RequestModel(selected_ped_model)
    while not HasModelLoaded(selected_ped_model) do
        Wait(500)
    end
    local spawn_coords = vector3(player_coords.x + math.random(-10, 10), player_coords.y + math.random(-10, 10), player_coords.z)
    local spawned_ped = CreatePed(4, selected_ped_model, spawn_coords.x, spawn_coords.y, spawn_coords.z, 0.0, false, false)
    TaskCombatPed(spawned_ped, player, 0, 16)
    SetPedCombatAttributes(spawned_ped, 46, true)
    SetPedFleeAttributes(spawned_ped, 0, 0)
    SetEntityAsMissionEntity(spawned_ped, true, true)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentString("Whoops! Looks like you stepped on someones toes. Defend yourself!")
    EndTextCommandPrint(10000, true)
end

-- Function to teleport player to random location
function random_teleport(params)
    local player = PlayerPedId()
    local original_location = GetEntityCoords(player)
    local original_heading = GetEntityHeading(player)
    local teleport_back = params.teleport_back or false
    local duration = params.duration or 60
    local locations = params.locations
    local random_id = math.random(1, #locations)
    local chosen_location = locations[random_id]
    DoScreenFadeOut(2000)
    Wait(1000)
    SetEntityCoordsNoOffset(player, chosen_location.x, chosen_location.y, chosen_location.z, true, true, true, true)
    SetEntityHeading(player, chosen_location.w)
    DoScreenFadeIn(2000)
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            BeginTextCommandPrint('STRING')
            AddTextComponentString("Bam! You're not in Kansas anymore. Enjoy the view for " .. time_left .. " seconds!")
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    if teleport_back then
        SetTimeout(duration * 1000, function()
            SetEntityCoordsNoOffset(player, original_location.x, original_location.y, original_location.z, true, true, true, true)
            SetEntityHeading(player, original_heading)
        end)
    end
end


-- Function to place jack o lantern on players head
function jack_o_lantern(params)
    local player = PlayerPedId()
    local duration = params.duration or 60
    local lantern_models = params.models
    local random_model = lantern_models[math.random(#lantern_models)]
    local selected_model = GetHashKey(random_model)
    RequestModel(selected_model)
    while not HasModelLoaded(selected_model) do
        Wait(500)
    end
    local lantern = CreateObject(selected_model, 0, 0, 0, true, true, true)
    local bone_index = GetPedBoneIndex(player, 12844)
    AttachEntityToEntity(lantern, player, bone_index, -0.08, 0.0, 0.0, -180.0, 90.0, 10.0, false, false, false, false, 2, true)
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            BeginTextCommandPrint('STRING')
            AddTextComponentString("Well, aren't you the head-lit center of attention? " .. time_left .. " seconds of lantern fame remaining!")
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    
    SetTimeout(duration * 1000, function()
        DeleteEntity(lantern)
    end)
end


-- TREATS:

-- Function to handle super speed
function super_speed(params)
    local player = PlayerId()
    local duration = params.duration or 60
    local speed_multiplier = params.speed_multiplier or 1.49
    SetRunSprintMultiplierForPlayer(player, speed_multiplier)
    SetSwimMultiplierForPlayer(player, speed_multiplier)
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Who needs a car when you\'re this fast? Zoom zoom! ' .. time_left .. ' seconds remaining!')
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    SetTimeout(duration * 1000, function()
        SetRunSprintMultiplierForPlayer(player, 1.0)
        SetSwimMultiplierForPlayer(player, 1.0)
    end)
end

-- Function to handle super jump
function super_jump(params)
    local duration = params.duration or 60
    SetSuperJumpThisFrame(PlayerId())
    local end_time = GetGameTimer() + duration * 1000
    CreateThread(function()
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Who put those springs in your shoes? Jump to the moon for ' .. time_left .. ' seconds!')
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
    end)
    CreateThread(function()
        while GetGameTimer() < end_time do
            SetSuperJumpThisFrame(PlayerId())
            Wait(0)
        end
    end)
end

-- Function to handle super strength
function super_strength(params)
    local player = PlayerId()
    local duration = params.duration
    local strength_multiplier = params.strength_multiplier or 150
    local super_strength_active = true
    CreateThread(function()
        while super_strength_active do
            Wait(0)
            SetWeaponDamageModifier(GetHashKey('WEAPON_UNARMED'), strength_multiplier) 
        end
        SetWeaponDamageModifier(GetHashKey('WEAPON_UNARMED'), 1.0) 
    end)
    CreateThread(function()
        local end_time = GetGameTimer() + duration * 1000
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Hulk who? Show those puny objects who\'s boss for ' .. time_left .. ' seconds!')
            EndTextCommandPrint(1000, true)
            Wait(1000)
        end
        super_strength_active = false 
    end)
end

-- Function to handle invisibility
function invisibility(params)
    local player = PlayerPedId()
    local duration = params.duration
    SetEntityVisible(player, false)
    local end_time = GetGameTimer() + duration * 1000
    CreateThread(function()
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Guess who\'s the invisible man now? Boo! Invisible for ' .. time_left .. ' seconds!')
            DrawSubtitleTimed(1000, 1)
            Wait(1000)
        end
    end)
    SetTimeout(duration * 1000, function()
        SetEntityVisible(player, true)
    end)
end

-- Function to handle invincibility
function invincibility(params)
    local player = PlayerPedId()
    local duration = params.duration
    SetEntityInvincible(player, true)
    local end_time = GetGameTimer() + duration * 1000
    CreateThread(function()
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Superman\'s got nothing on you! You\'re invincible for ' .. time_left .. ' seconds!')
            DrawSubtitleTimed(1000, 1)
            Wait(1000)
        end
    end)
    SetTimeout(duration * 1000, function()
        SetEntityInvincible(player, false)
    end)
end

-- Function to handle a fireworks show
function fireworks_show(params)
    local player = PlayerPedId()
    local duration = params.duration or 60
    local end_time = GetGameTimer() + duration * 1000
    local firework_types = {
        "scr_indep_firework_trailburst",
        "scr_indep_firework_starburst_burst",
        "scr_indep_firework_shotburst",
        "scr_indep_firework_burst_spawn"
    }
    CreateThread(function()
        if not HasNamedPtfxAssetLoaded("scr_indep_fireworks") then
            RequestNamedPtfxAsset("scr_indep_fireworks")
            while not HasNamedPtfxAssetLoaded("scr_indep_fireworks") do
                Wait(10)
            end
        end
        while GetGameTimer() < end_time do
            local coords = GetEntityCoords(PlayerPedId())
            local r = math.random()
            local g = math.random()
            local b = math.random()
            local firework_type = firework_types[math.random(#firework_types)]
            local height_offset = math.random(0, 5)
            UseParticleFxAssetNextCall("scr_indep_fireworks")
            local firework = StartNetworkedParticleFxNonLoopedAtCoord(firework_type, coords.x, coords.y, coords.z + height_offset, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            SetParticleFxNonLoopedColour(r, g, b)
            local delay = math.random(500, 2000) -- Random delay between 0.5 to 2 seconds
            Wait(delay)
        end
    end)
    CreateThread(function()
        while GetGameTimer() < end_time do
            local time_left = math.floor((end_time - GetGameTimer()) / 1000)
            ClearPrints()
            SetTextEntry_2('STRING')
            AddTextComponentString('Who needs a fancy event? You\'ve got your own firework show for ' .. time_left .. ' seconds right at your feet!')
            DrawSubtitleTimed(1000, 1)
            Wait(1000)
        end
    end)
end

-- Function to enumerate peds
function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end
function EnumerateEntities(initFunc, nextFunc, endFunc)
    return coroutine.wrap(function()
        local handle, entity = initFunc()
        if not handle or handle == -1 then
            return
        end
        local success
        repeat
            coroutine.yield(entity)
            success, entity = nextFunc(handle)
        until not success
        endFunc(handle)
    end)
end

--[[
    KEYMAPPING
]]

RegisterKeyMapping('trickortreat', 'Trick or treat!', 'keyboard', 'F10')
RegisterCommand('trickortreat', function()
    local current_time = GetGameTimer()
    if (current_time - last_used) < cooldown_timer then
        local time_remaining = cooldown_timer - (current_time - last_used)
        local minutes_remaining = math.ceil(time_remaining / 60000)
        print('on cooldown')
        return
    end
    last_used = current_time
    CreateThread(function()
        while true do
            Wait(0)
            local player = PlayerPedId()
            local player_coords = GetEntityCoords(player)
            local closest_ped = get_nearest_ped(player_coords.x, player_coords.y, player_coords.z)
            if DoesEntityExist(closest_ped) then
                handle_trick_or_treat(player, closest_ped)
                break
            else
                print('Closest Ped ID:\tfalse')
            end
        end
    end)
end)
