--// Xes Hub FINAL BOSS (Keyless)

getgenv().XesHub = {
    AutoFarm = false,
    AutoSkill = false,
    MobBring = false,
    AutoQuest = false,
    AutoM1 = false,

    -- AI
    AIBrain = false,
    SmartCombat = false,
    Humanizer = false,
    LevelAware = true,

    -- kill
    AutoKillNPC = false,
    AutoKillBoss = false,

    -- world
    AutoChestFarm = false,
    AutoBossHunt = false,
    ServerHopBoss = false,

    -- player
    AutoStats = false,
    OvernightMode = false,

    -- hitbox
    HitboxSize = 10,
}

-------------------------------------------------
-- SERVICES
-------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-------------------------------------------------
-- CHARACTER
-------------------------------------------------

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot(char)
    return char:WaitForChild("HumanoidRootPart")
end

-------------------------------------------------
-- HELPERS
-------------------------------------------------

local function isBoss(name)
    name = name:lower()
    return name:find("boss") or name:find("grade")
end

local function getClosestMob()
    local char = getChar()
    local root = getRoot(char)

    local closest, dist = nil, math.huge

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v ~= char
        and v:FindFirstChild("Humanoid")
        and v:FindFirstChild("HumanoidRootPart")
        and v.Humanoid.Health > 0
        and not Players:GetPlayerFromCharacter(v) then

            local mag = (v.HumanoidRootPart.Position - root.Position).Magnitude
            if mag < dist and mag < 400 then
                dist = mag
                closest = v
            end
        end
    end

    return closest
end

-------------------------------------------------
-- HITBOX EXTENDER
-------------------------------------------------

local function extendHitbox()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("HumanoidRootPart")
        and v:FindFirstChild("Humanoid")
        and not Players:GetPlayerFromCharacter(v) then

            v.HumanoidRootPart.Size = Vector3.new(
                getgenv().XesHub.HitboxSize,
                getgenv().XesHub.HitboxSize,
                getgenv().XesHub.HitboxSize
            )
            v.HumanoidRootPart.Transparency = 0.7
            v.HumanoidRootPart.CanCollide = false
        end
    end
end

-------------------------------------------------
-- ULTRA M1
-------------------------------------------------

RunService.Heartbeat:Connect(function()
    if getgenv().XesHub.AutoM1 then
        local char = player.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    tool:Activate()
                end)
            end
        end
    end
end)

-------------------------------------------------
-- HUMANIZER
-------------------------------------------------

local function humanizer()
    if not getgenv().XesHub.Humanizer then return end

    local root = getRoot(getChar())
    root.CFrame = root.CFrame * CFrame.new(math.random(-1,1)/10,0,math.random(-1,1)/10)
end

-------------------------------------------------
-- CHEST FARM
-------------------------------------------------

local function chestFarm()
    if not getgenv().XesHub.AutoChestFarm then return end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") then
            getRoot(getChar()).CFrame = v.CFrame * CFrame.new(0,0,2)
            break
        end
    end
end

-------------------------------------------------
-- BOSS HUNT
-------------------------------------------------

local function bossHunt()
    if not getgenv().XesHub.AutoBossHunt then return end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("HumanoidRootPart")
        and isBoss(v.Name) then

            getRoot(getChar()).CFrame =
                v.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
            break
        end
    end
end

-------------------------------------------------
-- ANTI AFK
-------------------------------------------------

player.Idled:Connect(function()
    if getgenv().XesHub.OvernightMode then
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end
end)

-------------------------------------------------
-- SERVER HOP
-------------------------------------------------

local lastHop = 0

local function serverHop()
    if not getgenv().XesHub.ServerHopBoss then return end
    if tick() - lastHop < 120 then return end

    lastHop = tick()
    TeleportService:Teleport(game.PlaceId, player)
end

-------------------------------------------------
-- AUTO FARM LOOP
-------------------------------------------------

task.spawn(function()
    while task.wait(0.15) do
        pcall(function()

            if getgenv().XesHub.AutoFarm then
                local mob = getClosestMob()
                if mob then
                    getRoot(getChar()).CFrame =
                        mob.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                end
            end

            extendHitbox()
            humanizer()
            chestFarm()
            bossHunt()
            serverHop()

        end)
    end
end)

-------------------------------------------------
-- MINIMAL PREMIUM GUI (clean)
-------------------------------------------------

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "XesHubFinal"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,300)
frame.Position = UDim2.new(0,40,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Xes Hub — Final Boss"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local function makeToggle(text, pos, flag)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9,0,0,30)
    btn.Position = UDim2.new(0.05,0,0,pos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = text .. ": OFF"

    btn.MouseButton1Click:Connect(function()
        getgenv().XesHub[flag] = not getgenv().XesHub[flag]
        btn.Text = text .. ": " .. (getgenv().XesHub[flag] and "ON" or "OFF")
    end)
end

makeToggle("Auto Farm",40,"AutoFarm")
makeToggle("Ultra M1",75,"AutoM1")
makeToggle("AI Brain",110,"AIBrain")
makeToggle("Boss Hunt",145,"AutoBossHunt")
makeToggle("Chest Farm",180,"AutoChestFarm")
makeToggle("Overnight",215,"OvernightMode")
