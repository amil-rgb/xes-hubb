--// Xes Hub | God Tier (Keyless)

if getgenv().XesLoaded then return end
getgenv().XesLoaded = true

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local Settings = {
    AutoFarm = false,
    AutoBoss = false,
    KillAura = false,
    UltraM1 = false,
    Hitbox = false,
    HitboxSize = 20,
    ChestFarm = false,
    Brain = false
}

--// ScreenGui
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "XesHub"

--// Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

--// Top Bar
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,36)
top.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", top).CornerRadius = UDim.new(0,8)

--// Title
local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "Xes Hub | Kaizen"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

--// Minimize Button
local mini = Instance.new("TextButton", top)
mini.Size = UDim2.new(0,30,0,24)
mini.Position = UDim2.new(1,-35,0.5,-12)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(40,40,40)
mini.TextColor3 = Color3.new(1,1,1)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(main:GetChildren()) do
        if v ~= top then
            v.Visible = not minimized
        end
    end
end)

--// Tabs Holder
local tabsHolder = Instance.new("Frame", main)
tabsHolder.Size = UDim2.new(0,120,1,-36)
tabsHolder.Position = UDim2.new(0,0,0,36)
tabsHolder.BackgroundColor3 = Color3.fromRGB(22,22,22)

--// Pages Holder
local pages = Instance.new("Frame", main)
pages.Size = UDim2.new(1,-120,1,-36)
pages.Position = UDim2.new(0,120,0,36)
pages.BackgroundTransparency = 1

--// Tab System
local function createTab(name, order)
    local btn = Instance.new("TextButton", tabsHolder)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,(order-1)*40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", pages)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = order == 1
    page.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(pages:GetChildren()) do
            v.Visible = false
        end
        page.Visible = true
    end)

    return page
end

--// Create Tabs
local FarmTab = createTab("Farming",1)
local CombatTab = createTab("Combat",2)
local MoneyTab = createTab("Money",3)
local BrainTab = createTab("AI Brain",4)
local MiscTab = createTab("Misc",5)

--// Toggle Creator
local function createToggle(parent,text,callback,order)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,200,0,32)
    btn.Position = UDim2.new(0,20,0,20+(order*40))
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." : "..(state and "ON" or "OFF")
        callback(state)
    end)
end

--// FARM TAB
createToggle(FarmTab,"Auto Farm",function(v) Settings.AutoFarm=v end,0)
createToggle(FarmTab,"Auto Boss",function(v) Settings.AutoBoss=v end,1)

--// COMBAT TAB
createToggle(CombatTab,"Ultra M1",function(v) Settings.UltraM1=v end,0)
createToggle(CombatTab,"Kill Aura",function(v) Settings.KillAura=v end,1)
createToggle(CombatTab,"Hitbox Extender",function(v) Settings.Hitbox=v end,2)

--// MONEY TAB
createToggle(MoneyTab,"Chest Farm",function(v) Settings.ChestFarm=v end,0)

--// BRAIN TAB
createToggle(BrainTab,"AI Farm Brain",function(v) Settings.Brain=v end,0)

--// ===== CORE LOOPS =====

-- Ultra M1 (FIXED)
RunService.RenderStepped:Connect(function()
    if Settings.UltraM1 then
        pcall(function()
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0)
        end)
    end
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if Settings.KillAura and LocalPlayer.Character then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local ehrp = v:FindFirstChild("HumanoidRootPart")
                if hrp and ehrp then
                    if (hrp.Position - ehrp.Position).Magnitude < 20 then
                        v.Humanoid.Health = 0
                    end
                end
            end
        end
    end
end)

-- Hitbox Extender (MAX 20)
RunService.Heartbeat:Connect(function()
    if Settings.Hitbox then
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name == "HumanoidRootPart" and v.Parent ~= LocalPlayer.Character then
                v.Size = Vector3.new(Settings.HitboxSize,Settings.HitboxSize,Settings.HitboxSize)
                v.Transparency = 0.7
                v.CanCollide = false
            end
        end
    end
end)
