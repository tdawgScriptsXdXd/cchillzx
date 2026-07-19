local Players = game:GetService("Players")

-- ==========================================
-- 1. Username Whitelist Verification
-- ==========================================
local whitelistedUsers = {
    "CommonToCB",
    "Friend123",
    "AnotherFriend"
}

-- Check if the LocalPlayer's name exists in the whitelist table
if not table.find(whitelistedUsers, Players.LocalPlayer.Name) then
    warn("Unauthorized user. Script aborted.")
    return 
end

-- ==========================================
-- 2. Main Script (Only runs if authorized)
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- The complete list of cases
local cases = {
    "Summer Case", "Haunted Case", "Skeleton Case", "Jolly Case",
    "Festive Case", "Merry Case", "Decorated Case", "Infected Case",
    "Cupid Case", "Lucky Case", "Patriot Case"
}

-- Create the Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CaseOpenerUI"
screenGui.ResetOnSpawn = false

-- Attempt to parent to CoreGui, fallback to PlayerGui
local successAttach, _ = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not successAttach then
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Create the Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 400) 
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Top Bar (Title & Close Button)
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Multi Case Opener"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Amount Input Box 
local amountInput = Instance.new("TextBox")
amountInput.Name = "AmountInput"
amountInput.Size = UDim2.new(1, -20, 0, 35)
amountInput.Position = UDim2.new(0, 10, 1, -45)
amountInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
amountInput.PlaceholderText = "Amount to open (Default: 1)"
amountInput.Text = "1"
amountInput.TextSize = 14
amountInput.Font = Enum.Font.Gotham
amountInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = amountInput

-- Scrolling List for Buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -95) 
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #cases * 40)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Generate Buttons & Loop Logic
for i, caseName in ipairs(cases) do
    local btn = Instance.new("TextButton")
    btn.Name = caseName
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Text = caseName
    btn.LayoutOrder = i
    btn.Parent = scrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    local isOpening = false

    -- Handle Button Clicks
    btn.MouseButton1Click:Connect(function()
        if isOpening then return end 
        
        local openAmount = tonumber(amountInput.Text)
        if not openAmount or openAmount < 1 then
            openAmount = 1
        end

        isOpening = true
        local originalText = caseName
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        task.spawn(function()
            local successCount = 0

            for count = 1, openAmount do
                btn.Text = "Opening (" .. count .. "/" .. openAmount .. ")"
                
                local success, result = pcall(function()
                    return Remotes.RequestCasePurchaseWithSecondaryKeys:InvokeServer(caseName)
                end)

                if success and result then
                    successCount = successCount + 1
                end
                
                task.wait(0.1) 
            end

            if successCount > 0 then
                btn.Text = "Successfully Opened " .. successCount .. "!"
                btn.BackgroundColor3 = Color3.fromRGB(40, 150, 60)
            else
                btn.Text = "Failed/No Keys"
                btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            end

            task.wait(2)
            btn.Text = originalText
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            isOpening = false
        end)
    end)
end
