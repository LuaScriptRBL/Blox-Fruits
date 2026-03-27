-- Merged: Simple Arsenal Helper + follow me Luigi4k85 Mobile Final (Banana UI) + Weapon Enhancements --
-- Features: Banana GUI, Highlights ESP, Box/Name/Distance ESP (Drawing fallback),
-- Aimbot, Silent Aim, NoRecoil (best-effort), WalkSpeed lock (Movement tab),
-- Rapid Fire (FireRate mod), Fixed Infinite Ammo (auto-refill), Spread Control
-- Discord: https://discord.gg/rr8jV4e5
-- NOTE: Use private servers / alt accounts. Risk of ban exists.

-- Try load Banana UI
local Library = loadstring(game:HttpGet("https://pastefy.app/Oiw0q6ZL/raw"))()

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
local z_Limit = 13451
local flySpeed = 325
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


-- ===== Banana UI =====
local Window = Library:CreateWindow({
    Title = "Banana Cat Hub",
    Subtitle = "- Blox Fruits",
    Image = "rbxassetid://5009915812"
})

Library:Notify({
    Title = "Ui Library",
    Description = "The UI automatically hides once executed.\nPress the button at the bottom-left of the screen to show the GUI.",
    Duration = 3
})

-- Tabs
local HuntLeviathan = Window:AddTab("Đăng Địt Ánh")

-- ===== Aimbot Tab =====
local dangmocanh = HuntLeviathan:AddLeftGroupbox("Leviathan")
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
                if currentY ~= 0 or activeTween then
                    StopAll()
                end
                
                if tick() - lastNotify >= 3 then
                    Library:Notify({
                        Title = "đăng yêu ánh",
                        Description = "Frozen Dimension Spawned",
                        Duration = 4
                    })
                    lastNotify = tick()
                end
            end
        end
    end
end)

-- LUỒNG ĐIỀU KHIỂN CHÍNH
task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoTravel then
            if not frozenIsland() then
                pcall(function()
                    local char = LP.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if hum and hum.Sit and hum.SeatPart then
                        local seat = hum.SeatPart
                        local boat = seat:FindFirstAncestorOfClass("Model")
                        local root = (boat and boat.PrimaryPart) or seat
                        
                        local targetY = (root.Position.Z < z_Limit) and 1000 or 150
                        
                        -- Cập nhật độ cao Y
                        if currentY ~= targetY then
                            if activeTween then activeTween:Cancel() activeTween = nil end
                            currentY = targetY
                            root.CFrame = CFrame.new(root.Position.X, currentY, root.Position.Z) * root.CFrame.Rotation
                        end
                        
                        -- Duy trì Tween
                        if not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
                            local targetZ = 300000 
                            local dist = math.abs(targetZ - root.Position.Z)
                            local targetCF = CFrame.new(root.Position.X, currentY, targetZ) * root.CFrame.Rotation
                            
                            activeTween = TS:Create(root, TweenInfo.new(dist/flySpeed, Enum.EasingStyle.Linear), {CFrame = targetCF})
                            activeTween:Play()
                        end
                    else
                        if currentY ~= 0 then StopAll() end
                    end
                end)
            end
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
        
-- Final startup
updateHighlightsState()
print("Banana Hub Loaded Succesfully")
