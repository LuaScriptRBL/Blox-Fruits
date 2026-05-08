-- 🔥 ULTRA FAST ATTACK VIP - PASSIVE MODE (TỰ ĐỘNG LIÊN TỤC)
-- Chạy liên tục mà không ảnh hưởng gameplay

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")

-- TÌM HIDDEN REMOTE (Anti-Cheat)
local HiddenRemote = nil
local HiddenRemoteId = nil

local function FindHiddenRemote()
    local folders = {
        ReplicatedStorage:FindFirstChild("Util"),
        ReplicatedStorage:FindFirstChild("Common"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage:FindFirstChild("FX"),
    }
    
    for _, folder in ipairs(folders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                    HiddenRemote = child
                    HiddenRemoteId = child:GetAttribute("Id")
                    return
                end
            end
        end
    end
end

FindHiddenRemote()

-- ⚙️ CẤU HÌNH
local Config = {
    -- Ranges
    MeleeRange = 65,
    BloxFruitRange = 70,
    GunRange = 120,
    
    -- Combat
    MaxTargets = 150,
    MaxCombo = 4,
    ComboResetTime = 0.3,
    
    -- Passive Attack
    PassiveEnabled = true,
    AttackInterval = 0,  -- 0 = mỗi frame, càng thấp càng nhanh
    
    -- Features
    PredictMovement = true,
    AntiCheatMode = true,
    BloxFruitMode = true,
    
    -- Only Attack When
    OnlyAttackWhenMoving = false,  -- Có thể tắt/bật
    OnlyAttackWithMouseDown = false, -- Có thể tắt/bật
    
    DEBUG = false
}

-- 📊 STATE
local State = {
    LastAttackTime = 0,
    CurrentCombo = 0,
    LastComboTime = 0,
    FrameCounter = 0,
    IsMouseDown = false,
    IsMoving = false,
    LastPosition = nil,
}

-- 🎯 CHECK ALIVE
local function IsAlive(entity)
    if not entity or not entity.Parent then return false end
    local hum = entity:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- 🎯 GET DISTANCE
local function GetDistance(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- 🎯 PREDICT POSITION
local PrevPositions = {}
local function PredictPosition(targetRoot, strength)
    strength = strength or 0.15
    
    if not PrevPositions[targetRoot] then
        PrevPositions[targetRoot] = {pos = targetRoot.Position, t = tick()}
        return targetRoot.Position
    end
    
    local prev = PrevPositions[targetRoot]
    local now = tick()
    local dt = now - prev.t
    
    if dt > 0 and dt < 0.5 then
        local velocity = (targetRoot.Position - prev.pos) / dt
        PrevPositions[targetRoot] = {pos = targetRoot.Position, t = now}
        return targetRoot.Position + velocity * strength
    end
    
    PrevPositions[targetRoot] = {pos = targetRoot.Position, t = now}
    return targetRoot.Position
end

-- 🎯 GET ALL TARGETS
local function GetTargets(maxRange)
    maxRange = maxRange or Config.MeleeRange
    local targets = {}
    
    local playerChar = Player.Character
    if not playerChar or not IsAlive(playerChar) then return targets end
    
    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return targets end
    
    local playerPos = playerRoot.Position
    
    -- Quét Enemies
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy ~= playerChar and IsAlive(enemy) then
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = GetDistance(root.Position, playerPos)
                    if dist <= maxRange then
                        table.insert(targets, {
                            model = enemy,
                            root = root,
                            head = enemy:FindFirstChild("Head") or root,
                            distance = dist,
                            type = "mob"
                        })
                    end
                end
            end
        end
    end
    
    -- Quét Characters (PvP)
    local charsFolder = Workspace:FindFirstChild("Characters")
    if charsFolder then
        for _, char in ipairs(charsFolder:GetChildren()) do
            if char ~= playerChar and IsAlive(char) then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = GetDistance(root.Position, playerPos)
                    if dist <= maxRange then
                        table.insert(targets, {
                            model = char,
                            root = root,
                            head = char:FindFirstChild("Head") or root,
                            distance = dist,
                            type = "player"
                        })
                    end
                end
            end
        end
    end
    
    -- SORT theo khoảng cách
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    return targets
end

-- 🎯 MELEE ATTACK
local function HandleMeleeAttack(tool)
    local char = Player.Character
    if not char then return end
    
    local targets = GetTargets(Config.MeleeRange)
    if #targets == 0 then return end
    
    local primary = targets[1]
    local hitList = {}
    
    for i = 1, math.min(#targets, Config.MaxTargets) do
        if IsAlive(targets[i].model) then
            table.insert(hitList, {targets[i].model, targets[i].head})
        end
    end
    
    if #hitList == 0 then return end
    
    pcall(function()
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(primary.head, hitList, {})
        
        -- Anti-cheat
        if Config.AntiCheatMode and HiddenRemote and HiddenRemoteId then
            local seed = pcall(function() return Net.seed:InvokeServer() end) and Net.seed:InvokeServer() or 1
            local encoded = string.gsub("RE/RegisterHit", ".", function(c)
                return string.char(bit32.bxor(string.byte(c), math.floor(Workspace:GetServerTimeNow()/10%10)+1))
            end)
            local finalId = bit32.bxor(HiddenRemoteId + 909090, seed * 2)
            cloneref(HiddenRemote):FireServer(encoded, finalId, primary.head, hitList)
        end
    end)
end

-- 🎯 GUN ATTACK
local function HandleGunAttack(tool)
    local char = Player.Character
    if not char then return end
    
    local targets = GetTargets(Config.GunRange)
    if #targets == 0 then return end
    
    local target = targets[1]
    
    pcall(function()
        if ShootGunEvent then
            local aimPos = Config.PredictMovement and PredictPosition(target.root) or target.root.Position
            ShootGunEvent:FireServer(aimPos, {target.head})
        end
    end)
end

-- 🍎 BLOX FRUIT ATTACK
local function HandleFruitAttack(tool)
    local char = Player.Character
    if not char then return end
    
    local targets = GetTargets(Config.BloxFruitRange)
    if #targets == 0 then return end
    
    local target = targets[1]
    local leftClickRemote = tool:FindFirstChild("LeftClickRemote", true)
    
    if leftClickRemote then
        local direction = (target.root.Position - char:GetPivot().Position).Unit
        
        -- Combo system
        local now = tick()
        if now - State.LastComboTime > Config.ComboResetTime then
            State.CurrentCombo = 0
        end
        State.CurrentCombo = State.CurrentCombo + 1
        if State.CurrentCombo > Config.MaxCombo then
            State.CurrentCombo = 1
        end
        State.LastComboTime = now
        
        pcall(function()
            leftClickRemote:FireServer(direction, State.CurrentCombo)
        end)
    else
        -- Fallback to melee
        HandleMeleeAttack(tool)
    end
end

-- 🎯 HÀM CHÍNH - PASSIVE ATTACK
local function PassiveAttack()
    if not Config.PassiveEnabled then return end
    
    local char = Player.Character
    if not char or not IsAlive(char) then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- CHECK ĐIỀU KIỆN ATTACK
    if Config.OnlyAttackWithMouseDown and not State.IsMouseDown then return end
    if Config.OnlyAttackWhenMoving and not State.IsMoving then return end
    
    local toolTip = tool.ToolTip or tool.Name
    
    -- ROUTE ĐẾN HANDLER THÍCH HỢP
    if toolTip == "Gun" then
        HandleGunAttack(tool)
    elseif Config.BloxFruitMode and (toolTip == "Blox Fruit" or tool:FindFirstChild("LeftClickRemote", true)) then
        HandleFruitAttack(tool)
    else
        -- Melee / Sword
        HandleMeleeAttack(tool)
    end
end

-- 📍 TRACK MOVEMENT
local function CheckMoving()
    local char = Player.Character
    if not char then 
        State.IsMoving = false
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then 
        State.IsMoving = false
        return 
    end
    
    if not State.LastPosition then
        State.LastPosition = root.Position
        State.IsMoving = false
        return
    end
    
    local dist = GetDistance(root.Position, State.LastPosition)
    State.IsMoving = dist > 0.5
    State.LastPosition = root.Position
end

-- 🖱️ MOUSE INPUT TRACKING (tuỳ chọn)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.IsMouseDown = true
        State.CurrentCombo = 0  -- Reset combo khi nhấn
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.IsMouseDown = false
        State.CurrentCombo = 0  -- Reset combo khi thả
    end
end)

-- ⚡ VÒNG LẶP CHÍNH (PASSIVE - LUÔN CHẠY)
RunService.Heartbeat:Connect(function()
    pcall(function()
        CheckMoving()
        PassiveAttack()
    end)
end)

-- 📋 API PUBLIC
_G.FastAttackVIPPassive = {
    Config = Config,
    
    SetConfig = function(newCfg)
        for k, v in pairs(newCfg) do
            Config[k] = v
        end
        if Config.DEBUG then print("[FastAttack] Config updated") end
    end,
    
    -- BẬT/TẮT PASSIVE
    SetPassive = function(enabled)
        Config.PassiveEnabled = enabled
        print("[FastAttack] Passive: " .. (enabled and "ON" or "OFF"))
    end,
    
    -- CHỉ ATTACK KHI NHẤN CHUỘT
    SetMouseDownOnly = function(enabled)
        Config.OnlyAttackWithMouseDown = enabled
        print("[FastAttack] Mouse Down Only: " .. (enabled and "ON" or "OFF"))
    end,
    
    -- CHỈ ATTACK KHI MOVING
    SetMovingOnly = function(enabled)
        Config.OnlyAttackWhenMoving = enabled
        print("[FastAttack] Moving Only: " .. (enabled and "ON" or "OFF"))
    end,
    
    GetTargets = function()
        return GetTargets(Config.MeleeRange)
    end,
    
    GetStatus = function()
        local char = Player.Character
        print("=== FastAttack Passive Status ===")
        print("Character: " .. tostring(char ~= nil))
        print("Tool: " .. tostring(char and char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name or "None"))
        print("Passive: " .. tostring(Config.PassiveEnabled))
        print("Mouse Down: " .. tostring(State.IsMouseDown))
        print("Moving: " .. tostring(State.IsMoving))
        print("Targets: " .. #GetTargets(Config.MeleeRange))
        print("Combo: " .. State.CurrentCombo .. "/" .. Config.MaxCombo)
    end,
    
    SetDebug = function(enabled)
        Config.DEBUG = enabled
    end
}

print("✅ FastAttack VIP Passive Mode loaded!")
print("📌 Script tự động chạy liên tục")
print("📌 Không ảnh hưởng đến khả năng auto attack thường")
print("📌 Dùng _G.FastAttackVIPPassive.GetStatus() để check")