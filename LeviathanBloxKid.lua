
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager") -- Dùng để nhấn Space

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
-- 1. Khởi tạo Window
local Window = Fluent:CreateWindow({
    Title = "Lồn Cặc",
    SubTitle = "Cái Lồn",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 340),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- 2. Tạo Nút Ẩn/Hiện UI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "ToggleUI_Gui"

local Btn = Instance.new("ImageButton", ScreenGui)
Btn.Size = UDim2.new(0, 50, 0, 50) -- VÙNG NHẤN CỐ ĐỊNH 50x50
Btn.Position = UDim2.new(0, 15, 0.05, 0)
Btn.BackgroundColor3 = Color3.fromRGB(230, 230, 230) -- Nền xám trắng
Btn.BackgroundTransparency = 1 -- Mặc định Open là trong suốt
Btn.Active = true
Btn.Draggable = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

-- Tạo ImageLabel con chứa ảnh
local Img = Instance.new("ImageLabel", Btn)
Img.BackgroundTransparency = 1
Instance.new("UICorner", Img).CornerRadius = UDim.new(1, 0)

-- Cấu hình URL Thumbnail
local URL_OPEN = "https://www.roblox.com/asset-thumbnail/image?assetId=5009916777&width=420&height=420&format=png"
local URL_CLOSED = "https://www.roblox.com/asset-thumbnail/image?assetId=5009915812&width=420&height=420&format=png"

-- Thiết lập ban đầu (Trạng thái Open)
local isVisible = true
Img.Size = UDim2.new(1, 0, 1, 0) -- Khi Open ảnh to bằng nút (50x50)
Img.Position = UDim2.new(0, 0, 0, 0)
Img.Image = URL_OPEN

Btn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    Window:Minimize()
    
    if isVisible then
        -- KHI MỞ: Nền trong suốt, ảnh to (100% của 50x50)
        Btn.BackgroundTransparency = 1
        Img.Size = UDim2.new(1, 0, 1, 0)
        Img.Position = UDim2.new(0, 0, 0, 0)
        Img.Image = URL_OPEN
    else
        -- KHI ĐÓNG: Hiện nền xám trắng, ẢNH THU NHỎ LẠI (chỉ còn 65% của 50x50)
        Btn.BackgroundTransparency = 0
        Img.Size = UDim2.new(0.65, 0, 0.65, 0) -- Thu nhỏ ảnh bên trong
        Img.Position = UDim2.new(0.175, 0, 0.175, 0) -- Căn giữa ảnh nhỏ
        Img.Image = URL_CLOSED
    end
end)

local Tabs = {
    HuntLeviathan = Window:AddTab({ Title = "Tab Hunt Leviathan", Icon = "" }),
    SettingHunt = Window:AddTab({ Title = "Tab Select Skill", Icon = "" })
}


_G.SelectedWeapons = {}
_G.MeleeSkills = {["Z"] = true, ["X"] = true, ["C"] = true}
_G.FruitSkills = {["Z"] = true, ["X"] = true, ["C"] = true, ["V"] = true, ["F"] = true}
_G.SwordSkills = {["Z"] = true, ["X"] = true}
_G.GunSkills = {["Z"] = true, ["X"] = true}

local VirtualInputManager = game:GetService("VirtualInputManager")

local function EquipWeapon(WeaponType)
    local Character = game.Players.LocalPlayer.Character
    local Backpack = game.Players.LocalPlayer.Backpack
    if Character and Backpack then
        local currentTool = Character:FindFirstChildOfClass("Tool")
        if not currentTool or (currentTool and currentTool.ToolTip ~= WeaponType) then
            for _, tool in pairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == WeaponType then
                    Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
end

local function ExecuteSkills(SkillTable, WeaponType)
    if _G.AutoLeviathan then
        EquipWeapon(WeaponType)
        task.wait(0.1)
        for skill, enabled in pairs(SkillTable) do
            if enabled == true then
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, skill, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, skill, false, game)
                end)
            end
        end
    end
end

_G.RunAllSkills = function()
    if _G.SelectedWeapons["Melee"] then ExecuteSkills(_G.MeleeSkills, "Melee") end
    if _G.SelectedWeapons["Blox Fruit"] then ExecuteSkills(_G.FruitSkills, "Blox Fruit") end
    if _G.SelectedWeapons["Sword"] then ExecuteSkills(_G.SwordSkills, "Sword") end
    if _G.SelectedWeapons["Gun"] then ExecuteSkills(_G.GunSkills, "Gun") end
end
_G.AutoLeviathan = false
local Speed = 350

local function StartLeviathanFix()
    task.spawn(function()
        while _G.AutoLeviathan do
            local Target = nil
            
            -- Kiểm tra mục tiêu trong SeaBeasts
            local SeaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
            if SeaBeastsFolder then
                local Children = SeaBeastsFolder:GetChildren()
                
                -- Ưu tiên 1: Leviathan Segment
                for _, v in pairs(Children) do
                    if v.Name == "Leviathan Segment" then
                        Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                        if Target then break end
                    end
                end
                
                -- Ưu tiên 2: Leviathan (Nếu không thấy Segment)
                if not Target then
                    for _, v in pairs(Children) do
                        if v.Name == "Leviathan" then
                            Target = v:IsA("BasePart") and v or v:FindFirstChild("HumanoidRootPart")
                            if Target then break end
                        end
                    end
                end
            end

            -- CHỈ HOẠT ĐỘNG KHI CÓ TARGET (Leviathan hoặc Segment)
            if Target then
                local Character = game.Players.LocalPlayer.Character
                local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
                local Hum = Character and Character:FindFirstChildOfClass("Humanoid")

                if HRP and Hum then
                    -- Tự động nhảy khỏi ghế nếu đang ngồi
                    if Hum.Sit then
                        Hum.Sit = false
                        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.1)
                    end

                    -- Khởi tạo lực di chuyển (BV/BG)
                    local BV = HRP:FindFirstChild("LeviVelocity") or Instance.new("BodyVelocity")
                    BV.Name = "LeviVelocity"
                    BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    BV.Parent = HRP
                    
                    local BG = HRP:FindFirstChild("LeviGyro") or Instance.new("BodyGyro")
                    BG.Name = "LeviGyro"
                    BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                    BG.P = 10000
                    BG.Parent = HRP

                    -- NoClip
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end

                    -- Logic di chuyển
                    local TargetPos = (Target.CFrame * CFrame.new(0, 45, 0)).Position 
                    local Distance = (HRP.Position - TargetPos).Magnitude
                    
                    if Distance > 5 then
                        BV.Velocity = (TargetPos - HRP.Position).Unit * Speed
                        BG.CFrame = CFrame.lookAt(HRP.Position, TargetPos)
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                        HRP.CFrame = CFrame.new(TargetPos, Target.Position)
                    end

                    -- Đánh khi cách 20m
                    if (HRP.Position - Target.Position).Magnitude / 3.57 <= 20 and _G.RunAllSkills then
                        _G.RunAllSkills()
                    end
                end
            else
                -- Nếu không thấy mục tiêu, chờ quét lại sau 1s (giúp tự động bay khi vừa ra đảo)
                task.wait(0.1)
            end
            task.wait() 
        end
        
        -- Dọn dẹp khi tắt
        local Character = game.Players.LocalPlayer.Character
        if Character then
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if HRP then
                if HRP:FindFirstChild("LeviVelocity") then HRP.LeviVelocity:Destroy() end
                if HRP:FindFirstChild("LeviGyro") then HRP.LeviGyro:Destroy() end
            end
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end) 
end
do
 Tabs.HuntLeviathan:AddButton({
        Title = "Teleport To Your Boat",
        Description = "Bad Working For Now ( lỏ cặk )",
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
            StatusParagraph:SetTitle("Frozen Dimension : ✅ spawned ")
        else
            StatusParagraph:SetTitle("Frozen Dimension : ❌ not spawn yet")
        end
    end
end)

    Tabs.HuntLeviathan:AddToggle("AutoTravel", {Title = "Auto Find Leviathan", Default = false })

local z_Limit = 13451
local flySpeed = 325
local activeTween = nil
local currentY = 0
local lastNotify = 0

-- HÀM KIỂM TRA ĐẢO
local function frozenIsland()
    return workspace:FindFirstChild("_WorldOrigin") 
        and workspace._WorldOrigin:FindFirstChild("Locations") 
        and workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
end

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

-- LUỒNG QUÉT ĐẢO VÀ THÔNG BÁO (CHỈ CẦN BẬT TOGGLE)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggle.Value then
            if frozenIsland() then
                if currentY ~= 0 or activeTween then
                    StopAll()
                end
                
                if tick() - lastNotify >= 3 then
                    Fluent:Notify({
                        Title = "Banana Cat Hub",
                        Content = "Frozen Dimension Spawned\n-----",
                        Duration = 2.5
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
        if Toggle.Value then
            if not frozenIsland() then
                pcall(function()
                    local char = LP.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if hum and hum.Sit and hum.SeatPart then
                        local seat = hum.SeatPart
                        local boat = seat:FindFirstAncestorOfClass("Model")
                        local root = (boat and boat.PrimaryPart) or seat
                        
                        local targetY = (root.Position.Z < z_Limit) and 1000 or 150
                        
                        if currentY ~= targetY then
                            if activeTween then activeTween:Cancel() activeTween = nil end
                            currentY = targetY
                            root.CFrame = CFrame.new(root.Position.X, currentY, root.Position.Z) * root.CFrame.Rotation
                        end
                        
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
    if not Toggle.Value or currentY == 0 or frozenIsland() then return end
    
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

Toggle:OnChanged(function()
    if not Toggle.Value then 
        StopAll()
        lastNotify = 0 
    end
end)


--// UI Toggle
Tabs.HuntLeviathan:AddToggle("AutoLeviathan", {
    Title = "Auto Attack Leviathan",
    Default = false,
    Callback = function(Value)
        _G.AutoLeviathan = Value
        if Value then StartLeviathanFix() 
        end
    end
})

Tabs.SettingHunt:AddDropdown("WeaponSelect", {
    Title = "Select Weapons",
    Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Multi = true,
    Callback = function(Value) _G.SelectedWeapons = Value 
    end
})

Tabs.SettingHunt:AddDropdown("MeleeSkills", {
    Title = "Melee Skills",
    Values = {"Z", "X", "C"},
    Default = {"Z", "X", "C"},
    Multi = true,
    Callback = function(Value)
        for _, key in pairs({"Z", "X", "C", "V"}) do _G.MeleeSkills[key] = Value[key] or false 
        end
    end
}) 

Tabs.SettingHunt:AddDropdown("FruitSkills", {
    Title = "Blox Fruit Skills",
    Values = {"Z", "X", "C", "V", "F"},
    Default = {"Z", "X", "C", "V", "F"},
    Multi = true,
    Callback = function(Value)
        for _, key in pairs({"Z", "X", "C", "V", "F"}) do _G.FruitSkills[key] = Value[key] or false 
        end
    end
})

Tabs.SettingHunt:AddDropdown("SwordSkills", {
    Title = "Sword Skills",
    Values = {"Z", "X"},
    Default = {"Z", "X"},
    Multi = true,
    Callback = function(Value)
        for _, key in pairs({"Z", "X"}) do _G.SwordSkills[key] = Value[key] or false 
        end
    end
})

Tabs.SettingHunt:AddDropdown("GunSkills", {
    Title = "Gun Skills",
    Values = {"Z", "X"},
    Default = {"Z", "X"},
    Multi = true,
    Callback = function(Value)
        for _, key in pairs({"Z", "X"}) do _G.GunSkills[key] = Value[key] or false 
        end
    end
})

Window:SelectTab(1)
