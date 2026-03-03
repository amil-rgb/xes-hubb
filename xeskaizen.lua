--// Xes Hub PRIVATE | FINAL PRO

getgenv().XesHub = {
    AutoFarm = false,
    AutoSkill = false,
    MobBring = false,
    AutoQuest = false,
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

-------------------------------------------------
-- Character helpers
-------------------------------------------------

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot(char)
    return char:WaitForChild("HumanoidRootPart")
end

-------------------------------------------------
-- Quest detection (SMART)
-------------------------------------------------

local function hasQuest()
    local gui = player.PlayerGui:FindFirstChild("QuestGUI", true)
    return gui ~= nil
end

local function findQuestNPC()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("quest") then
            if v:FindFirstChild("HumanoidRootPart") then
                return v
            end
        end
    end
end

local function doQuest()
    if hasQuest() then return end

    local npc = findQuestNPC()
    if npc then
        local root = getRoot(getChar())
        root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,0,3)

        -- interact
        VIM:SendKeyEvent(true,"E",false,game)
        task.wait(0.1)
        VIM:SendKeyEvent(false,"E",false,game)
    end
end

-------------------------------------------------
-- Boss priority
-------------------------------------------------

local function isBoss(name)
    name = name:lower()
    return name:find("boss") or name:find("grade")
end

local function getClosestMob()
    local char = getChar()
    local root = getRoot(char)

    local closest, dist = nil, math.huge
    local bossTarget = nil

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v ~= char
        and v:FindFirstChild("Humanoid")
        and v:FindFirstChild("HumanoidRootPart")
        and v.Humanoid.Health > 0
        and not Players:GetPlayerFromCharacter(v) then

            local mag = (v.HumanoidRootPart.Position - root.Position).Magnitude

            if isBoss(v.Name) and mag < 500 then
                bossTarget = v
            end

            if mag < dist and mag < 350 then
                dist = mag
                closest = v
            end
        end
    end

    return bossTarget or closest
end

-------------------------------------------------
-- Combat
-------------------------------------------------

local function clickAttack()
    VIM:SendMouseButtonEvent(0,0,0,true,game,0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
end

local function useSkills()
    local keys = {"Z","X","C","V"}
    for _, key in ipairs(keys) do
        VIM:SendKeyEvent(true,key,false,game)
        task.wait(0.04)
        VIM:SendKeyEvent(false,key,false,game)
    end
end

-------------------------------------------------
-- Mob bring (optimized)
-------------------------------------------------

local function bringMobs(targetPos)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChild("HumanoidRootPart")
        and v:FindFirstChild("Humanoid")
        and v.Humanoid.Health > 0
        and not Players:GetPlayerFromCharacter(v) then

            if (v.HumanoidRootPart.Position - targetPos).Magnitude < 140 then
                v.HumanoidRootPart.CFrame =
                    CFrame.new(targetPos + Vector3.new(0,0,-5))
            end
        end
    end
end

-------------------------------------------------
-- GUI
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "XesHubFinal"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,220)
frame.Position = UDim2.new(0,40,0.5,-110)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0

-- drag
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🚀 Xes Hub FINAL"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- toggle maker
local function makeToggle(text, order, flag)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9,0,0,32)
    btn.Position = UDim2.new(0.05,0,0,35 + (order * 36))
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = text .. ": OFF"

    btn.MouseButton1Click:Connect(function()
        XesHub[flag] = not XesHub[flag]
        btn.Text = text .. ": " .. (XesHub[flag] and "ON" or "OFF")
    end)
end

makeToggle("Auto Farm",0,"AutoFarm")
makeToggle("Auto Skill",1,"AutoSkill")
makeToggle("Mob Bring",2,"MobBring")
makeToggle("Auto Quest",3,"AutoQuest")

-- status
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,1,-22)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(170,170,170)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.Text = "Status: Idle"

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------

task.spawn(function()
    while true do
        task.wait(0.12)

        if XesHub.AutoQuest then
            pcall(doQuest)
        end

        if XesHub.AutoFarm then
            pcall(function()
                local char = getChar()
                local root = getRoot(char)
                local mob = getClosestMob()

                if mob then
                    status.Text = "Status: Farming"

                    if XesHub.MobBring then
                        bringMobs(root.Position)
                    end

                    root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                    clickAttack()

                    if XesHub.AutoSkill then
                        useSkills()
                    end
                else
                    status.Text = "Status: No mobs"
                end
            end)
        else
            status.Text = "Status: Idle"
        end
    end
end)
