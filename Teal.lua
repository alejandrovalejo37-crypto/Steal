local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- OCULTAR NOMBRE DEL JUGADOR
humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

-- CAMBIAR "SKIN" (Color y eliminar accesorios)
local newColor = Color3.fromRGB(0, 150, 255) -- Color azul, cámbialo si quieres

for _, part in pairs(character:GetChildren()) do
    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
        part.BrickColor = BrickColor.new(newColor)
        for _, decal in pairs(part:GetChildren()) do
            if decal:IsA("Decal") then
                decal.Transparency = 1
            end
        end
    elseif part:IsA("Accessory") then
        part:Destroy()
    end
end

-- VARIABLES DE CONTROL
local targetHeight = humanoidRootPart.Position.Y + 50
local lockHeight = true
local speedStep = 5

-- CREAR GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HeightControlGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- FUNCION PARA HACER BOTONES MOVIBLES
local function makeDraggable(button)
    local dragging = false
    local dragInput, mousePos, framePos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            button.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- FUNCION PARA CREAR BOTONES
local function createButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.Parent = screenGui

    makeDraggable(button)

    return button
end

-- CREAR BOTONES
local upHeightBtn = createButton("UpHeightButton", "Subir +1", UDim2.new(0, 10, 0, 10))
local downHeightBtn = createButton("DownHeightButton", "Bajar -1", UDim2.new(0, 10, 0, 70))
local toggleLockBtn = createButton("ToggleLockButton", "Bloquear: ON", UDim2.new(0, 10, 0, 130))
local speedUpBtn = createButton("SpeedUpButton", "Velocidad +5", UDim2.new(0, 10, 0, 190))
local speedDownBtn = createButton("SpeedDownButton", "Velocidad -5", UDim2.new(0, 10, 0, 250))
local showHideBtn = createButton("ShowHideButton", "Mostrar/Ocultar", UDim2.new(0, 10, 0, 310))

local otherButtons = {
    upHeightBtn,
    downHeightBtn,
    toggleLockBtn,
    speedUpBtn,
    speedDownBtn,
}

-- FUNCIONES BOTONES
upHeightBtn.MouseButton1Click:Connect(function()
    targetHeight = targetHeight + 1
end)

downHeightBtn.MouseButton1Click:Connect(function()
    targetHeight = targetHeight - 1
end)

toggleLockBtn.MouseButton1Click:Connect(function()
    lockHeight = not lockHeight
    toggleLockBtn.Text = "Bloquear: " .. (lockHeight and "ON" or "OFF")
end)

speedUpBtn.MouseButton1Click:Connect(function()
    humanoid.WalkSpeed = humanoid.WalkSpeed + speedStep
end)

speedDownBtn.MouseButton1Click:Connect(function()
    humanoid.WalkSpeed = math.max(0, humanoid.WalkSpeed - speedStep)
end)

showHideBtn.MouseButton1Click:Connect(function()
    local anyVisible = false
    for _, btn in pairs(otherButtons) do
        if btn.Visible then
            anyVisible = true
            break
        end
    end

    for _, btn in pairs(otherButtons) do
        btn.Visible = not anyVisible
    end
end)

-- MANTENER ALTURA FIJA
RunService.Heartbeat:Connect(function()
    if lockHeight then
        local pos = humanoidRootPart.Position
        humanoidRootPart.CFrame = CFrame.new(pos.X, targetHeight, pos.Z)
    end
end)

-- ANTI AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

while true do
    wait(60)
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end
