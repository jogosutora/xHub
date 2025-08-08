-- // Services 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- // Variables
local lPlayer = Players.LocalPlayer
local PlayerGui = lPlayer:WaitForChild("PlayerGui")

-- Function to find roof or walls above player
local function findTargetAbovePlayer()
    local character = lPlayer.Character
    if not character then
        warn("Character not found!")
        return nil
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart not found!")
        return nil
    end
    
    local playerPosition = humanoidRootPart.Position
    local foundTargets = {}
    
    print("(Debug) Player position: " .. tostring(playerPosition))
    print("(Debug) Searching for roofs and walls...")
    
    -- Comprehensive search function that looks at ALL descendants
    local function searchForTargets(parent)
        -- Check if current object is named "Roof" or "Walls2"
        if parent.Name == "Roof" or parent.Name == "Walls2" then
            print("(Debug) Found object named '" .. parent.Name .. "': " .. parent.ClassName)
            
            -- If it's a BasePart, check if it's above player
            if parent:IsA("BasePart") then
                print("(Debug) " .. parent.Name .. " part position: " .. tostring(parent.Position))
                if parent.Position.Y > playerPosition.Y then
                    local distance = (parent.Position - playerPosition).Magnitude
                    print("(Debug) " .. parent.Name .. " is above player, distance: " .. distance)
                    table.insert(foundTargets, {
                        part = parent,
                        distance = distance,
                        name = parent.Name,
                        position = parent.Position
                    })
                end
            -- If it's a Model, find the highest part in it
            elseif parent:IsA("Model") then
                print("(Debug) " .. parent.Name .. " is a model, searching for parts inside...")
                local highestPart = nil
                local highestY = playerPosition.Y
                
                -- Search all descendants of the model for parts
                for _, descendant in ipairs(parent:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        if descendant.Position.Y > highestY then
                            highestY = descendant.Position.Y
                            highestPart = descendant
                        end
                    end
                end
                
                if highestPart then
                    local distance = (highestPart.Position - playerPosition).Magnitude
                    print("(Debug) Found highest part in " .. parent.Name .. " model: " .. tostring(highestPart.Position))
                    table.insert(foundTargets, {
                        part = highestPart,
                        distance = distance,
                        name = parent.Name,
                        position = highestPart.Position
                    })
                end
            end
        end
        
        -- Continue searching children
        for _, child in ipairs(parent:GetChildren()) do
            searchForTargets(child)
        end
    end
    
    -- Search workspace and all its descendants
    searchForTargets(Workspace)
    
    -- Sort targets by distance (closest first)
    table.sort(foundTargets, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Prioritize based on name: Walls2 > Roof
    local selectedTarget = nil
    local hasWalls2 = false
    local hasRoof = false
    
    -- Check what we found
    for _, target in ipairs(foundTargets) do
        if target.name == "Walls2" then
            hasWalls2 = true
        elseif target.name == "Roof" then
            hasRoof = true
        end
    end
    
    -- Priority selection: Walls2 first, then Roof
    if hasWalls2 then
        for _, target in ipairs(foundTargets) do
            if target.name == "Walls2" then
                selectedTarget = target
                print("(Debug) Selected Walls2 as priority target")
                break
            end
        end
    elseif hasRoof then
        for _, target in ipairs(foundTargets) do
            if target.name == "Roof" then
                selectedTarget = target
                print("(Debug) Selected Roof as target")
                break
            end
        end
    end
    
    if selectedTarget then
        print("(Debug) Final target selected: " .. selectedTarget.name .. " at " .. tostring(selectedTarget.position))
        return selectedTarget.part
    else
        print("(Debug) No roof or walls found above player")
        return nil
    end
end

-- Teleport function
local function tpToTarget()
    local target = findTargetAbovePlayer()
    local lCharacter = lPlayer.Character
    
    if not lCharacter then
        warn("Character not found!")
        return
    end
    
    if not target then
        warn("No roof or walls found above player!")
        return
    end
    
    local humanoidRootPart = lCharacter:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Teleport to target with slight offset above it
        humanoidRootPart.CFrame = target.CFrame * CFrame.new(0, target.Size.Y/2 + 3, 0)
        print("Teleported to: " .. target.Name)
    end
end

-- // GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoofTeleportGui"
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
TitleLabel.Text = "Roof/Walls TP"
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
TeleportButton.Text = "TP to Roof/Walls"
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
    print("Teleport button clicked")
    tpToTarget()
end)

CloseButton.MouseButton1Click:Connect(function()
    print("Close button clicked")
    ScreenGui:Destroy()
end)

-- Hover effects
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

print("(Debug) Roof Teleport GUI loaded for: " .. lPlayer.Name)
