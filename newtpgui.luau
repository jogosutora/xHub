-- // Services 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Variables
local lPlayer = Players.LocalPlayer
local PlayerGui = lPlayer:WaitForChild("PlayerGui")

-- Wait for workspace and map to load
local WSpace = game:GetService("Workspace")
local GameMap = WSpace:WaitForChild("Map")
local TycoonsFolder = GameMap:WaitForChild("Tycoons")
local RFiltered = WSpace.RayFiltered
local FishesFolder = RFiltered.Objects

-- Get local player's tycoon
local function getLocalPlayerBase()
    for _, tycoon in ipairs(TycoonsFolder:GetChildren()) do
        if tycoon:GetAttribute("Owner") == lPlayer.Name then
            return tycoon
        end
    end
    return nil
end

local function tpToBase()
    local LocalPlayerBase = getLocalPlayerBase()
    local lCharacter = lPlayer.Character
    
    if not lCharacter then
        warn("Character not found!")
        return
    end
    
    if not LocalPlayerBase then
        warn("Player base not found!")
        return
    end
    
    if LocalPlayerBase:FindFirstChild("Tycoon") then
        local collectZone = LocalPlayerBase.Tycoon:FindFirstChild("CollectZone")
        if collectZone and collectZone:FindFirstChild("CollectPart2") then
            local humanoidRootPart = lCharacter:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local startTime = tick()
                local duration = 3 -- 3 seconds total
                local interval = 0.5 -- 0.5 seconds between teleports
                
                while tick() - startTime < duration do
                    -- Teleport above the forcefield
                    humanoidRootPart.CFrame = workspace.Map.Forcefield.CFrame * CFrame.new(0, 1, 0)
                    print("Teleported above forcefield")
                    
                    wait(interval)
                end
                
                -- Final teleport to the collect part
                humanoidRootPart.CFrame = collectZone.CollectPart2.CFrame * CFrame.new(0, 3, 0)
                print("TPed to base collect zone")
            end
        else
            warn("CollectZone or CollectPart2 not found!")
        end
    else
        warn("Tycoon folder not found in base!")
    end
end

-- // GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Rounded corners for main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame

-- Rounded corners for title bar
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Fix title bar corners (only top corners rounded)
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

-- Title Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Instant Steal"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.Arcade
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -28, 0, 2.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Active = true
CloseButton.Parent = TitleBar

-- Rounded corners for close button
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Teleport Button
local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportButton"
TeleportButton.Size = UDim2.new(0, 200, 0, 50)
TeleportButton.Position = UDim2.new(0.5, -100, 0, 50)
TeleportButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
TeleportButton.BorderSizePixel = 0
TeleportButton.Text = "TP To Base"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextScaled = true
TeleportButton.Font = Enum.Font.Arcade
TeleportButton.Active = true
TeleportButton.Parent = MainFrame

-- Rounded corners for teleport button
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = TeleportButton

-- // Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

-- Make the main frame draggable, not the title bar
MainFrame.Active = true
MainFrame.Draggable = true

-- Manual dragging method as backup
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end

local function updateDrag(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

-- Connect dragging events to title bar only (but move the main frame)
TitleBar.InputBegan:Connect(startDrag)
UserInputService.InputChanged:Connect(updateDrag)

-- // Button functionality
TeleportButton.MouseButton1Click:Connect(function()
    print("Teleport button clicked (rcv)")
    tpToBase()
end)

CloseButton.MouseButton1Click:Connect(function()
    print("Close button clicked")
    ScreenGui:Destroy()
end)

-- hover
TeleportButton.MouseEnter:Connect(function()
    TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
end)

TeleportButton.MouseLeave:Connect(function()
    TeleportButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
end)

print("(Debug) Looking for tycoon owned by: " .. lPlayer.Name)
