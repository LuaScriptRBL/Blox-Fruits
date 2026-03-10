local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")

local Window = Fluent:CreateWindow({
    Title = "Ccc Hub",
    SubTitle = "by meo",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 340),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Btn = Instance.new("ImageButton", ScreenGui)
Btn.Size, Btn.Position, Btn.BackgroundTransparency = UDim2.new(0,60,0,60), UDim2.new(0,15,0.02,0), 1
Btn.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=127470963031421&width=420&height=420&format=png"
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
Btn.MouseButton1Click:Connect(function() Window:Minimize() end)

local Tabs = {
    HuntLeviathan = Window:AddTab({ Title = "Hunt Leviathan", Icon = "" }),
    SettingHunt = Window:AddTab({ Title = "Select And Hold Skill", Icon = "" }),
    Fruit = Window:AddTab({ Title = "Fruit", Icon = "" })
}


local function GetFrozenDimension()
    return workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations") and workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
end

local function SetVelocity(part, enable)
    if not part then return end
    if part:FindFirstChild("CatV") then part.CatV:Destroy() end
    if part:FindFirstChild("CatA") then part.CatA:Destroy() end
    if enable then
        local att = Instance.new("Attachment", part); att.Name = "CatA"
        local lv = Instance.new("LinearVelocity", part)
        lv.Name = "CatV"
        lv.MaxForce = math.huge
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = Vector3.zero
        lv.Attachment0 = att
    end
end
_G.AutoLeviathan = false
local Speed = 350

local function StartLeviathanFix()
    task.spawn(function()
        local Character = game.Players.LocalPlayer.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        if not HRP then return end

        -- Khởi tạo lực di chuyển bền bỉ
        local BV = HRP:FindFirstChild("LeviVelocity") or Instance.new("BodyVelocity")
        BV.Name = "LeviVelocity"
        BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.Parent = HRP
        
        local BG = HRP:FindFirstChild("LeviGyro") or Instance.new("BodyGyro")
        BG.Name = "LeviGyro"
        BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        BG.P = 10000
        BG.Parent = HRP

        while _G.AutoLeviathan do
            local Target = nil
            local SeaBeasts = workspace.SeaBeasts:GetChildren()
            
            -- Ưu tiên 1: Leviathan Segment
            for _, v in pairs(SeaBeasts) do
                if v.Name == "Leviathan Segment" then
                    Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                    if Target then break end
                end
            end
            
            -- Ưu tiên 2: Leviathan (Nếu không có Segment)
            if not Target then
                for _, v in pairs(SeaBeasts) do
                    if v.Name == "Leviathan" then
                        Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                        if Target then break end
                    end
                end
            end

            if Target then
                -- NoClip liên tục để không bị kẹt khi đang bay
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local TargetPos = (Target.CFrame * CFrame.new(0, 45, 0)).Position 
                local Distance = (HRP.Position - TargetPos).Magnitude
                
                if Distance > 5 then
                    -- Bay liên tục với vận tốc Speed
                    BV.Velocity = (TargetPos - HRP.Position).Unit * Speed
                    BG.CFrame = CFrame.lookAt(HRP.Position, TargetPos)
                else
                    -- Dán chặt khi đã đến đích
                    BV.Velocity = Vector3.new(0, 0, 0)
                    HRP.CFrame = CFrame.new(TargetPos, Target.Position)
                end
            else
                -- Nếu mất dấu, giảm tốc từ từ để chờ quét lại (tránh dừng đột ngột)
                BV.Velocity = BV.Velocity * 0.8
                task.wait(0.1)
            end
            task.wait() 
        end
        
        -- Dọn dẹp sạch sẽ khi tắt
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
        if Character then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end)
end
do
    Tabs.HuntLeviathan:AddButton({
        Title = "Teleport To Your Boat",
        Description = "",
        Callback = function()
            local targetSeat = nil
            for _, b in pairs(workspace.Boats:GetChildren()) do
                if b:FindFirstChild("Owner") and (tostring(b.Owner.Value) == LP.Name or b.Owner.Value == LP.UserId) then
                    targetSeat = b:FindFirstChildWhichIsA("VehicleSeat", true)
                    break
                end
            end
            if targetSeat and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LP.Character.HumanoidRootPart
                local dist = (targetSeat.Position - hrp.Position).Magnitude
                local noclip = RS.Stepped:Connect(function()
                    for _, v in pairs(LP.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end)
                local tw = TS:Create(hrp, TweenInfo.new(dist / 350, Enum.EasingStyle.Linear), {CFrame = targetSeat.CFrame + Vector3.new(0, 5, 0)})
                tw:Play()
                tw.Completed:Connect(function() noclip:Disconnect() end)
            end
        end
    })

--- HÀM KIỂM TRA
local function check_frozen()
    if game.Workspace:FindFirstChild("Frozen Dimension", true) then
        return true
    else
        return false
    end
end

-- Khởi tạo Paragraph
local StatusParagraph = Tabs.HuntLeviathan:AddParagraph({
    Title = "Frozen Dimension.",
    Content = ""
})

--- VÒNG LẶP TỰ ĐỘNG CẬP NHẬT (Mỗi 3 giây)
task.spawn(function()
    while task.wait(0.01) do
        if check_frozen() then
            StatusParagraph:SetTitle("Frozen Dimension : ✅")
        else
            StatusParagraph:SetTitle("Frozen Dimension : ❌")
        end
    end
end)

local activeTween
local freezeY = nil

-- // Logic Find Leviathan
local ToggleFind = Tabs.HuntLeviathan:AddToggle("Find", { Title = "Find Leviathan", Default = false })

ToggleFind:OnChanged(function(Value)
    _G.Auto = Value
    
    if Value then
        -- // 1. Hệ thống giám sát Frozen Dimension (Chỉ chạy khi bật Toggle)
        task.spawn(function()
            local lastNotifyTime = 0
            while _G.Auto do
                if GetFrozenDimension() then
                    if (tick() - lastNotifyTime) >= 3 then
                        Fluent:Notify({
                            Title = "Banana Cat Hub",
                            Content = "⚠️ Frozen Dimension Spawned!",
                            Duration = 2.5
                        })
                        lastNotifyTime = tick()
                    end
                end
                task.wait(0.5)
            end
        end)

        -- // 2. Logic chính
        task.spawn(function()
            while _G.Auto do
                local hum = LP.Character:FindFirstChild("Humanoid")
                local seat = hum and hum.SeatPart
                
                if seat and seat:IsA("VehicleSeat") then
                    local boat = seat.Parent.PrimaryPart
                    
                    if GetFrozenDimension() then
                        if activeTween then activeTween:Cancel() end
                        repeat task.wait(1) until not GetFrozenDimension() or not _G.Auto
                    else
                        if boat.Position.Y < 500 then
                            SetVelocity(boat, true)
                            freezeY = 1000
                            boat.CFrame = CFrame.new(boat.Position.X, 1000, boat.Position.Z)
                            task.wait(1)
                        end
                        
                        if _G.Auto and boat.Position.Z < 14238 then
                            local dist = (Vector3.new(-13608, 1000, 14238) - boat.Position).Magnitude
                            activeTween = TS:Create(boat, TweenInfo.new(dist/350, Enum.EasingStyle.Linear), {CFrame = CFrame.new(-13608, 1000, 14238)})
                            activeTween:Play()
                            
                            while _G.Auto and activeTween.PlaybackState == Enum.PlaybackState.Playing do
                                if GetFrozenDimension() then break end
                                task.wait(0.1)
                            end
                        end
                        
                        if _G.Auto and not GetFrozenDimension() and boat.Position.Z >= 14238 then
                            if activeTween then activeTween:Cancel() end
                            freezeY = 175
                            boat.CFrame = CFrame.new(boat.Position.X, 175, boat.Position.Z)
                            
                            local targetCF = CFrame.new(boat.Position.X, 175, 1000000)
                            activeTween = TS:Create(boat, TweenInfo.new(4000, Enum.EasingStyle.Linear), {CFrame = targetCF})
                            activeTween:Play()
                            
                            while _G.Auto and activeTween.PlaybackState == Enum.PlaybackState.Playing do
                                if GetFrozenDimension() then break end
                                pcall(function() boat.CatV.VectorVelocity = boat.CFrame.LookVector * 250 end)
                                task.wait(0.1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
            
            -- Dọn dẹp
            if activeTween then activeTween:Cancel() end
            freezeY = nil
            pcall(function()
                local hum = LP.Character:FindFirstChild("Humanoid")
                if hum and hum.SeatPart then
                    local boat = hum.SeatPart.Parent.PrimaryPart
                    SetVelocity(boat, false)
                    boat.CFrame = CFrame.new(boat.Position.X, 28, boat.Position.Z)
                end
            end)
        end)
    else
        -- Khi tắt nút
        if activeTween then activeTween:Cancel() end
        freezeY = nil
        pcall(function()
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum and hum.SeatPart then
                local boat = hum.SeatPart.Parent.PrimaryPart
                SetVelocity(boat, false)
                boat.CFrame = CFrame.new(boat.Position.X, 28, boat.Position.Z)
            end
        end)
    end
end)

-- // 3. RS Stepped giữ độ cao
RS.Stepped:Connect(function()
    if _G.Auto and freezeY and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        pcall(function()
            local boat = LP.Character.Humanoid.SeatPart.Parent.PrimaryPart
            boat.Velocity = Vector3.new(boat.Velocity.X, 0, boat.Velocity.Z)
            if math.abs(boat.Position.Y - freezeY) > 5 then
                boat.CFrame = CFrame.new(boat.Position.X, freezeY, boat.Position.Z)
            end
        end)
    end
end)

--// UI Toggle
Tabs.HuntLeviathan:AddToggle("LeviathanToggle", {
    Title = "Attack Leviathan",
    Default = false,
    Callback = function(Value)
        _G.AutoLeviathan = Value
        if Value then
            StartLeviathanFix()
        end
    end
})
Window:SelectTab(1)
