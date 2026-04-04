local CollectionService = game:GetService("CollectionService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function HasJoinedTeam()
    if LocalPlayer.Team ~= nil then
        local teamName = LocalPlayer.Team.Name
        if teamName == "Pirates" or teamName == "Marines" then
            return true
        end
    end
    return false
end

if HasJoinedTeam() then return end

repeat 
    task.wait(0.1) 
until LocalPlayer:FindFirstChild("PlayerGui")

local IsRunning = true 

local function PreCheckSystem()
    task.spawn(function()
        local errorKey = "Player data still not ready"
        while IsRunning do
            pcall(function()
                if HasJoinedTeam() then
                    IsRunning = false
                    return
                end

                for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("TextButton") then
                        if string.find(v.Text, errorKey) then
                            v:Destroy()
                        end
                        if string.find(string.lower(v.Text), "cài đặt") then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                        end
                    end
                end
            end)
            RunService.Heartbeat:Wait()
        end
    end)
end

local function StartSpamKeyA()
    task.spawn(function()
        while IsRunning do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            task.wait(0.01)
        end
    end)
end

local function ExecutePremiumAction()
    if HasJoinedTeam() then return end

    PreCheckSystem()
    StartSpamKeyA()
    
    task.wait(0.3)

    for i = 1, 3 do
        VirtualInputManager:SendMouseButtonEvent(1, 1, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(1, 1, 0, false, game, 1)
        task.wait(0.05)
    end

    local tx, ty
    if getgenv().Team == "Pirates" then
        tx, ty = 220 + (97 / 2), 102 + (105 / 2)
    elseif getgenv().Team == "Marines" then
        tx, ty = 347 + (97 / 2), 101 + (103 / 2)
    else
        tx, ty = 220 + (97 / 2), 102 + (105 / 2)
    end

    local objects = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(tx, ty)
    
    for _, obj in pairs(objects) do
        CollectionService:AddTag(obj, "BananaCat_Final_Task")
    end

    local tagged = CollectionService:GetTagged("BananaCat_Final_Task")
    
    for _, target in pairs(tagged) do
        task.spawn(function()
            local events = {"MouseButton1Click", "Activated", "TouchTap", "InputBegan"}
            for _, name in pairs(events) do
                local success, connections = pcall(function() return getconnections(target[name]) end)
                if success and connections then
                    for _, con in pairs(connections) do
                        con:Fire()
                    end
                end
            end
        end)
    end

    for _, target in pairs(tagged) do
        CollectionService:RemoveTag(target, "BananaCat_Final_Task")
    end

    task.wait(0.5) 
    IsRunning = false 
end

task.spawn(function()
    ExecutePremiumAction()
end)
if HasJoinedTeam() then
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaScriptRBL/Blox-Fruits/refs/heads/main/NewUi1.lua"))()
if not Library then 
    warn("Banana UI load failed. Your executor may not support the provided URL.")
    return 
end

local function frozenIsland()
    return workspace:FindFirstChild("_WorldOrigin") 
        and workspace._WorldOrigin:FindFirstChild("Locations") 
        and workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
end
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local function DoAutoV4(Value)
    _G.RaceClickAutov4 = Value
    if Value then
        spawn(function()
            while wait(0.5) do
                pcall(function()
                    if _G.RaceClickAutov4 then
                        local plr = game:GetService("Players").LocalPlayer
                        if plr.Character:FindFirstChild("RaceEnergy") then
                            if plr.Character.RaceEnergy.Value >= 1 then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Y", false, game)
                                wait(0.1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, "Y", false, game)
                            end
                        end
                    end
                end)
            end
        end)
    end
    
end
local function StartAutoSkill()
    local Order = {
        {Type = "Melee", Selected = _G.SelectedSkills.Melee},
        {Type = "Blox Fruit", Selected = _G.SelectedSkills.Fruit},
        {Type = "Sword", Selected = _G.SelectedSkills.Sword},
        {Type = "Gun", Selected = _G.SelectedSkills.Gun}
    }

    for _, Cat in ipairs(Order) do
        if not _G.AttackLeviathan then break end
        if not _G.WeaponsToUse[Cat.Type] then continue end
        
        local Tool = LP.Backpack:FindFirstChildOfClass("Tool") or LP.Character:FindFirstChildOfClass("Tool")
        if Tool and Tool:FindFirstChild("ToolTip") and Tool.ToolTip == Cat.Type then
            LP.Character.Humanoid:EquipTool(Tool)
            task.wait(0.1)
            
            local KeyOrder = {"Z", "X", "C", "V", "F"}
            for _, Key in ipairs(KeyOrder) do
                if Cat.Selected[Key] then
                    VIM:SendKeyEvent(true, Key, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Key, false, game)
                    task.wait(0.2) -- Delay 0.2s chuẩn hệ thống
                end
            end
        end
    end
end
local function _tween(TargetCFrame)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local Distance = (LP.Character.HumanoidRootPart.Position - TargetCFrame.Position).Magnitude
    if Distance > 5 then
        local Time = Distance / 350
        TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = TargetCFrame}):Play()
    end
end
local function NoFog()
    local lighting = game:GetService("Lighting")
    if lighting:FindFirstChild("BaseAtmosphere") then
        lighting.BaseAtmosphere:Destroy()
    end
    if lighting:FindFirstChild("SeaTerrorCC") then
        lighting.SeaTerrorCC:Destroy()
    end
    if lighting:FindFirstChild("LightingLayers") then
        if lighting.LightingLayers:FindFirstChild("Atmosphere") then
            lighting.LightingLayers.Atmosphere:Destroy()
        end
        wait()
        if lighting.LightingLayers:FindFirstChild("DarkFog") then
            lighting.LightingLayers.DarkFog:Destroy()
        end
    end
    lighting.FogEnd=100000
end
local function DoAutoBuyChip(Value)
    _G.AutoBuyChipLevi = Value
    if Value then
        task.spawn(function()
            while _G.AutoBuyChipLevi do
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("InfoLeviathan", "2")
                end)
                task.wait(2)
            end
        end)
    end
end

local function DoAutoBuso(Value)
    _G.AutoBuso = Value
    if Value then
        task.spawn(function()
            while _G.AutoBuso do
                pcall(function()
                    local Character = game:GetService("Players").LocalPlayer.Character
                    if Character and not Character:FindFirstChild("HasBuso") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                    end
                end)
                task.wait(1)
            end
        end)
    end
end
local function DoAutoKen(Value)
    _G.AutoKen = Value
    if Value then
        task.spawn(function()
            while _G.AutoKen do
                game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("Ken", true)
                task.wait(0.5)
            end
        end)
    else
        game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("Ken", false)
    end
end

local function DoAutoV3(Value)
    _G.AutoT = Value
    if Value then
        task.spawn(function()
            while _G.AutoT do
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
                end)
                task.wait(0.5)
            end
        end)
    end
end


-- ===== Banana UI =====
local Window = Library:CreateWindow({
    Title = "Visibility Hub",
    Subtitle = "- Blox Fruits",
    Image = "rbxassetid://5009915812"
})

Library:Notify({
    Title = "Ui Library",
    Description = "The UI automatically hides once executed.\nPress the button at the bottom-left of the screen to show the GUI.",
    Duration = 3
})

-- Tabs
local HuntLeviathan = Window:AddTab("Main")
local setting = Window:AddTab("Setting for Farm")
local concac = setting:AddLeftGroupbox("Setup")
-- ===== Aimbot Tab =====
local dangmocanh = HuntLeviathan:AddLeftGroupbox("Leviathan")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer

local z_Limit = 13451
local flySpeed = 350
local activeTween = nil
local currentY = 0
local lastNotify = 0

-- HÀM DỪNG TOÀN BỘ
local function StopAll()
    if activeTween then activeTween:Cancel() activeTween = nil end
    currentY = 0
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local seat = hum and hum.SeatPart
        if seat then
            local boat = seat:FindFirstAncestorOfClass("Model")
            local root = (boat and boat.PrimaryPart) or seat
            root.Anchored = false
            root.Velocity = Vector3.zero
            root.CFrame = CFrame.new(root.Position.X, 23, root.Position.Z) * root.CFrame.Rotation
        end
    end)
end
-- --- CẤU HÌNH BIẾN ---

-- --- UI SELECT SKILL ---


-- TẠO TOGGLE
dangmocanh:AddButton({
    Title = "Buy Chip Leviathan ( Description like auto buy chip )",
    Callback=function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("InfoLeviathan", "2")
    end
})

dangmocanh:AddToggle("ToggleBuyChip", {
    Title = "Auto Buy Chip Leviathan",
    Description = "It does not check spy , still buy chip when you bought full",
    Default = false,
    Callback = function(Value)
        DoAutoBuyChip(Value)
    end
})

dangmocanh:AddToggle("AutoTravel", {
    Title = "Auto Find Leviathan",
    Default = false,
    Callback = function(Value)
        AutoTravel = Value
        if not Value then 
            StopAll()
            lastNotify = 0
        end
    end
})

-- LUỒNG QUÉT ĐẢO VÀ THÔNG BÁO
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoTravel then
            if frozenIsland() then
                if currentY ~= 0 or activeTween then StopAll() end
                if tick() - lastNotify >= 3 then
                    Library:Notify({
                        Title = "Visibility Hub",
                        Description = "Frozen Dimension Spawned",
                        Duration = 4
                    })
                    lastNotify = tick()
                end
            end
        end
    end
end)

-- LUỒNG ĐIỀU KHIỂN CHÍNH (BAY MÃI MÃI HƯỚNG Z DƯƠNG)
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoTravel and not frozenIsland() then
            pcall(function()
                local char = LP.Character
                local hum = char and char:FindFirstChild("Humanoid")
                
                if hum and hum.Sit and hum.SeatPart then
                    local seat = hum.SeatPart
                    local boat = seat:FindFirstAncestorOfClass("Model")
                    local root = (boat and boat.PrimaryPart) or seat
                    
                    local targetY = (root.Position.Z < z_Limit) and 1000 or 150
                    
                    -- 1. Cập nhật Y tức thì nếu đổi vùng Z
                    if currentY ~= targetY then
                        if activeTween then activeTween:Cancel() activeTween = nil end
                        currentY = targetY
                        root.CFrame = CFrame.new(root.Position.X, currentY, root.Position.Z) * root.CFrame.Rotation
                    end
                    
                    -- 2. Tạo Tween bay mãi về hướng Z dương (1,000,000)
                    if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
                        local targetZ = 1000000 -- Đích đến cực xa về hướng dương
                        local distance = math.abs(targetZ - root.Position.Z)
                        local duration = distance / flySpeed
                        
                        local targetCF = CFrame.new(root.Position.X, currentY, targetZ) * root.CFrame.Rotation
                        
                        activeTween = TS:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
                        activeTween:Play()
                    end
                else
                    if currentY ~= 0 then StopAll() end
                end
            end)
        end
    end
end)

-- LUỒNG ÉP CAO ĐỘ (HEARTBEAT)
RS.Heartbeat:Connect(function()
    if not AutoTravel or currentY == 0 or frozenIsland() then return end
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.Sit and hum.SeatPart then
            local seat = hum.SeatPart
            local root = (seat:FindFirstAncestorOfClass("Model") and seat:FindFirstAncestorOfClass("Model").PrimaryPart) or seat
            
            -- Khóa Y và triệt tiêu vật lý để Tween mượt hơn
            root.CFrame = CFrame.new(root.Position.X, currentY, root.Position.Z) * root.CFrame.Rotation
            root.Velocity = Vector3.zero
            
            local boat = seat:FindFirstAncestorOfClass("Model")
            if boat then
                for _, p in pairs(boat:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
    end)
end)
local function _tween(TargetCFrame)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local Distance = (LP.Character.HumanoidRootPart.Position - TargetCFrame.Position).Magnitude
    if Distance > 5 then
        local Time = Distance / 350
        TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = TargetCFrame}):Play()
    end
end

-- --- ATTACK LEVIATHAN LOGIC ---
dangmocanh:AddToggle("AttackLevi", {
    Text = "Attack Leviathan(Beta)",
    Default = false,
    Callback = function(Value)
        _G.AttackLeviathan = Value
        if Value then
            task.spawn(function()
                while _G.AttackLeviathan do
                    task.wait()
                    pcall(function()
                        for _, e in pairs(workspace.SeaBeasts:GetChildren()) do
                            if e.Name == "Leviathan" and e:FindFirstChild("HumanoidRootPart") and e.Health.Value > 0 then
                                repeat
                                    task.wait()
                                    _tween(e.HumanoidRootPart.CFrame) -- Bám sát Y liên tục

                                    if LP:DistanceFromCharacter(e.HumanoidRootPart.Position) <= 500 then
                                        StartAutoSkill()
                                    end
                                until not _G.AttackLeviathan or not e.Parent or e.Health.Value <= 0
                            end
                        end
                    end)
                end
            end)
        end
    end
})



----------------------------------------------------------------
-- TOGGLES (Using Callback)
----------------------------------------------------------------

concac:AddToggle("No Fog", {
    Title = "No Fog",
    Default = false,
    Callback = function()
        NoFog()
    end
})
concac:AddToggle("Boost Fps", {
    Title = "Boost Fps",
    Default = false,
    Callback = function()
        local a = false
        local b = game
        local c = b.Workspace
        local d = b.Lighting
        local e = c.Terrain
        e.WaterWaveSize = 0
        e.WaterWaveSpeed = 0
        e.WaterReflectance = 0
        e.WaterTransparency = 0
        d.GlobalShadows = false
        d.FogEnd = 9e9
        d.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"
        for _, f in pairs(b:GetDescendants()) do
            if f:IsA("Part") or f:IsA("Union") or f:IsA("CornerWedgePart") or f:IsA("TrussPart") then
                f.Material = "Plastic"
                f.Reflectance = 0
            elseif f:IsA("Decal") or f:IsA("Texture") and a then
                f.Transparency = 1
            elseif f:IsA("ParticleEmitter") or f:IsA("Trail") then
                f.Lifetime = NumberRange.new(0)
            elseif f:IsA("Explosion") then
                f.BlastPressure = 1
                f.BlastRadius = 1
            elseif f:IsA("Fire") or f:IsA("SpotLight") or f:IsA("Smoke") or f:IsA("Sparkles") then
                f.Enabled = false
            elseif f:IsA("MeshPart") then
                f.Material = "Plastic"
                f.Reflectance = 0
                f.TextureID = 10385902758728957
            end
        end
        for _, g in pairs(d:GetChildren()) do
            if g:IsA("BlurEffect") or g:IsA("SunRaysEffect") or g:IsA("ColorCorrectionEffect") or g:IsA("BloomEffect") or g:IsA("DepthOfFieldEffect") then
                g.Enabled = false
            end
        end
    end
})



concac:AddToggle("ToggleAutoBuso", {
    Title = "Auto Turn On Buso",
    Default = true,
    Callback = function(Value)
        DoAutoBuso(Value)
    end
})
concac:AddToggle("ToggleAutoT", {
    Title = "Auto Turn On V3",
    Default = false,
    Callback = function(Value)
        DoAutoV3(Value)
    end
})
concac:AddToggle("ToggleAutoY", {
    Title = "Auto Turn On V4",
    Default = false,
    Callback = function(Value)
        DoAutoV4(Value)
    end
})


concac:AddToggle("ToggleAutoKen", {
    Title = "Auto Turn On Observation", 
    Default = false,
    Callback = function(Value)
        DoAutoKen(Value)
    end
})


local AntiAFKEnabled = false

-- Logic Anti-AFK
LP.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        
    end
end)

-- Thêm Toggle vào Tab Main
concac:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(Value)
        AntiAFKEnabled = Value
    end
})


local WeaponSection = setting:AddLeftGroupbox("Weapon and Skill Settings")

WeaponSection:AddDropdown("WeaponSelect", {
    Title = "Select Weapons",
    Multi = true,
    Values = {"Melee", "Blox Fruit", "Sword", "Gun"},
    Default = {"Melee", "Blox Fruit", "Sword", "Gun"},
    Callback = function(Value) _G.WeaponsToUse = Value end
})


local weaponConfigs = {
    {Name = "Melee", Keys = {"Z", "X", "C", "V"}},
    {Name = "Fruit", Keys = {"Z", "X", "C", "V", "F"}},
    {Name = "Sword", Keys = {"Z", "X"}},
    {Name = "Gun", Keys = {"Z", "X"}}
}

for _, v in ipairs(weaponConfigs) do
    WeaponSection:AddDropdown(v.Name .. "Skills", {
        Title = v.Name .. " Keys",
        Multi = true,
        Values = v.Keys,
        Default = v.Keys,
        Callback = function(Value) 
            _G.SelectedSkills[v.Name == "Fruit" and "Fruit" or v.Name] = Value 
        end
    })
end

updateHighlightsState()
print("con cặc")

