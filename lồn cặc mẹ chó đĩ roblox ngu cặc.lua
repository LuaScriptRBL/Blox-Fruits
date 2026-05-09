local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 1. Thực hiện Collection 1 lần vào nút Topbar
local serverButton = PlayerGui:WaitForChild("Topbar"):WaitForChild("Frame"):WaitForChild("ServerBrowserButton")
if not CollectionService:HasTag(serverButton, "OpenServerBrowser") then
    CollectionService:AddTag(serverButton, "OpenServerBrowser")
end

-- Đường dẫn UI bên trong Browser
local browserUI = PlayerGui:WaitForChild("ServerBrowser").Frame
local statusLabel = browserUI:WaitForChild("TextLabel")
local scrollFrame = browserUI:WaitForChild("ScrollingFrame")
local fakeScroll = browserUI:WaitForChild("FakeScroll").Inside

local function startProcess()
    -- Mở Browser bằng cách nhấn vào nút đã tag
    local openBtn = CollectionService:GetTagged("OpenServerBrowser")[1]
    if openBtn and firesignal then
        firesignal(openBtn.MouseButton1Click)
    end

    print("Đang vận hành hệ thống Server Browser...")

    -- Vòng lặp kiểm tra và xử lý liên tục
    while task.wait(0.1) do
        -- Kiểm tra nếu TextLabel hiện (đang trong trạng thái hiển thị danh sách)
        if statusLabel.Visible then
            -- Scrolling liên tục
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y + 100)
            
            -- Reset nếu cuộn hết danh sách
            if scrollFrame.CanvasPosition.Y > scrollFrame.CanvasSize.Y.Offset then
                scrollFrame.CanvasPosition = Vector2.new(0, 0)
            end
        end

        -- Tự động ấn Join tại Slot thứ 4 trong FakeScroll
        local children = fakeScroll:GetChildren()
        if children[4] and children[4]:FindFirstChild("Join") then
            local joinBtn = children[4].Join
            if firesignal then
                firesignal(joinBtn.MouseButton1Click)
                firesignal(joinBtn.Activated)
            end
        end
    end
end

-- Kích hoạt script
task.spawn(startProcess)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 1. Thực hiện Collection 1 lần vào nút Topbar
local serverButton = PlayerGui:WaitForChild("Topbar"):WaitForChild("Frame"):WaitForChild("ServerBrowserButton")
if not CollectionService:HasTag(serverButton, "OpenServerBrowser") then
    CollectionService:AddTag(serverButton, "OpenServerBrowser")
end

-- Đường dẫn UI bên trong Browser
local browserUI = PlayerGui:WaitForChild("ServerBrowser").Frame
local statusLabel = browserUI:WaitForChild("TextLabel")
local scrollFrame = browserUI:WaitForChild("ScrollingFrame")
local fakeScroll = browserUI:WaitForChild("FakeScroll").Inside

local function startProcess()
    -- Mở Browser bằng cách nhấn vào nút đã tag
    local openBtn = CollectionService:GetTagged("OpenServerBrowser")[1]
    if openBtn and firesignal then
        firesignal(openBtn.MouseButton1Click)
    end

    print("Đang vận hành hệ thống Server Browser...")

    -- Vòng lặp kiểm tra và xử lý liên tục
    while task.wait(0.1) do
        -- Kiểm tra nếu TextLabel hiện (đang trong trạng thái hiển thị danh sách)
        if statusLabel.Visible then
            -- Scrolling liên tục
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y + 100)
            
            -- Reset nếu cuộn hết danh sách
            if scrollFrame.CanvasPosition.Y > scrollFrame.CanvasSize.Y.Offset then
                scrollFrame.CanvasPosition = Vector2.new(0, 0)
            end
        end

        -- Tự động ấn Join tại Slot thứ 4 trong FakeScroll
        local children = fakeScroll:GetChildren()
        if children[4] and children[4]:FindFirstChild("Join") then
            local joinBtn = children[4].Join
            if firesignal then
                firesignal(joinBtn.MouseButton1Click)
                firesignal(joinBtn.Activated)
            end
        end
    end
end

-- Kích hoạt script
task.spawn(startProcess)
 loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaScriptRBL/Blox-Fruits/refs/heads/main/ui_final-2.lua"))() -- Banana Cat Hub - Leviathan [ Premium ]
-- by tài

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local replicated = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

getgenv().Team = (getgenv().Team == "Marines") and "Marines" or "Pirates"
getgenv().BlackList = getgenv().BlackList or {}

-- Load Fast Attack
loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaScriptRBL/Blox-Fruits/refs/heads/main/fastattack.lua"))()

-- Cấu hình CollectionService cho Button Server Browser
local OPEN_TAG = "AutoOpenBrowser"
local BUTTON_PATH = lp:WaitForChild("PlayerGui"):WaitForChild("Topbar"):WaitForChild("Frame"):WaitForChild("ServerBrowserButton")

if not CollectionService:HasTag(BUTTON_PATH, OPEN_TAG) then
    CollectionService:AddTag(BUTTON_PATH, OPEN_TAG)
end

-- Hàm Click Server
local function ClickServerViaCollection()
    local btn = CollectionService:GetTagged(OPEN_TAG)[1]
    if btn then
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        else
            for _, v in ipairs(getconnections(btn.MouseButton1Click)) do
                v:Fire()
            end
        end
    end
end

-- Check PvP và SafeZone
local function isPvPEnabled(p)
    local ok, val = pcall(function() return p:GetAttribute("PvpDisabled") end)
    return ok and val ~= true
end

local function CheckSafeZone(hrp)
    local zones = workspace:FindFirstChild("_WorldOrigin") and workspace["_WorldOrigin"]:FindFirstChild("SafeZones")
    if zones then
        for _, v in pairs(zones:GetChildren()) do
            if v:IsA("BasePart") and (v.Position - hrp.Position).Magnitude <= 400 then return true end
        end
    end
    return false
end

-----------------------------------------------------------
-- [ LOGIC XỬ LÝ TARGET ]
-----------------------------------------------------------
local activeTarget = nil
local lastDamageTime = tick()
local lastNoTargetTime = tick()

-- Lấy danh sách mục tiêu hợp lệ (chạy ngầm)
local function GetValidTargets()
    local valid = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if isPvPEnabled(p) and not CheckSafeZone(p.Character.HumanoidRootPart) and not getgenv().BlackList[p.Name] then
                table.insert(valid, p)
            end
        end
    end
    return valid
end

-- Tự sát để dính
task.spawn(function()
    while task.wait() do
        pcall(function()
            if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
                local hrp = lp.Character.HumanoidRootPart
                if hrp.Position.Y < 4000 then 
                    hrp.CFrame = CFrame.new(hrp.Position.X, 5000, hrp.Position.Z)
                else 
                    task.wait(0.3) 
                    if hrp.Position.Y > 4000 then lp.Character.Humanoid.Health = 0 end 
                end
            end
        end)
    end
end)

-- Cơ chế ép dính cứng
local function HardStick()
    if activeTarget and activeTarget.hrp and lp.Character then
        local char = lp.Character
        char:BreakJoints() 
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CFrame = activeTarget.hrp.CFrame
                part.AssemblyLinearVelocity = activeTarget.hrp.AssemblyLinearVelocity
            end
        end
    end
end

-- Heartbeat: Xử lý dính và đổi server
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = lp.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
            local currentValid = GetValidTargets()

            -- 1. Xử lý khi hết target trong server
            if #currentValid == 0 then
                activeTarget = nil
                if tick() - lastNoTargetTime > 3 then
                    ClickServerViaCollection()
                    lastNoTargetTime = tick()
                end
                return
            else
                lastNoTargetTime = tick()
            end

            -- 2. Quản lý Target hiện tại
            if activeTarget then
                local p = activeTarget.plr
                
                -- RESET TIME KHI CÓ DAMAGE
                if activeTarget.hum.Health < activeTarget.lastHP then
                    activeTarget.lastHP = activeTarget.hum.Health
                    lastDamageTime = tick() -- Reset đồng hồ về 0 khi có damage
                end

                -- ĐỔI TARGET NẾU: Thoát, Chết, SafeZone, hoặc 30 GIÂY KHÔNG DAMAGE
                if not p.Parent or activeTarget.hum.Health <= 0 or CheckSafeZone(activeTarget.hrp) or (tick() - lastDamageTime > 30) then
                    if tick() - lastDamageTime > 30 then 
                        getgenv().BlackList[p.Name] = true 
                        task.delay(10, function() getgenv().BlackList[p.Name] = nil end)
                        ClickServerViaCollection() -- Click đổi server sau 30s ko dame
                    end
                    activeTarget = nil
                    lastDamageTime = tick()
                    return
                end

                HardStick()
            else
                -- Chọn người mới ngẫu nhiên
                local p = currentValid[math.random(1, #currentValid)]
                activeTarget = {
                    plr = p,
                    hrp = p.Character.HumanoidRootPart,
                    hum = p.Character.Humanoid,
                    lastHP = p.Character.Humanoid.Health
                }
                lastDamageTime = tick()
            end
        end
    end)
end)

-- RenderStepped để dính mượt nhất
RunService.RenderStepped:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health <= 0 then
        HardStick()
    end
end)

-- Auto Haki & Equip Fruit
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not lp.Team or lp.Team.Name == "" then 
                replicated.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team) 
            end
            if lp.Character then
                if not lp.Character:FindFirstChild("HasBuso") then 
                    replicated.Remotes.CommF_:InvokeServer("Buso") 
                end
                if lp.Character.Humanoid.Health <= 0 then
                    for _, v in pairs(lp.Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.Name:find("Fruit") or v.ToolTip == "Blox Fruit") then
                            lp.Character.Humanoid:EquipTool(v) 
                            break
                        end
                    end
                end
            end
        end)
    end
end)
