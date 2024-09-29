-- Plugin Initialization
local toolbar = plugin:CreateToolbar("ABP Security")
local button = toolbar:CreateButton("Scan for Backdoors", "Manually scan all scripts in the game", "rbxassetid://YourIconID")

local ABP = {
    Webhook = "", -- Insert your webhook URL for notifications.
    BackdoorModules = {"BackdoorModule", "Backdoor", "Virus", "Logs", "Loaded"},
}

-- Function to send webhook notifications (optional)
local function SendWebhook(text)
    -- Implementation for webhook notifications (if applicable)
    print("[Webhook]: " .. text)
end

-- Function to display a warning popup
local function showWarning(scriptName, reason)
    local warningMessage = Instance.new("Message", game.Workspace)
    warningMessage.Text = "[ABP Warning]: Suspicious script detected - " .. scriptName .. " Reason: " .. reason
    wait(5)
    warningMessage:Destroy()
end

-- Function to check if a script contains suspicious code
local function containsSuspiciousKeyword(source)
    local suspiciousKeywords = {"require", "getfenv", "loadstring"}
    for _, keyword in ipairs(suspiciousKeywords) do
        if string.find(source, keyword) then
            return true
        end
    end
    return false
end

-- Function to check for suspicious module names
local function CheckModule(module)
    for _, backdoorModule in ipairs(ABP.BackdoorModules) do
        if string.find(string.lower(module.Name), string.lower(backdoorModule)) then
            return true
        end
    end
    return false
end

-- Function to scan scripts for backdoors and malicious code
local function scanScript(script)
    if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
        local success, source = pcall(function() return script.Source end)
        if success then
            -- Check for suspicious keywords
            if containsSuspiciousKeyword(source) then
                warn("[ABP]: Suspicious script detected: " .. script:GetFullName())
                SendWebhook("[ABP]: Suspicious script detected: " .. script:GetFullName())
                showWarning(script:GetFullName(), "Contains suspicious keywords")
            end
        end
        
        -- Check module name for backdoor-like patterns
        if CheckModule(script) then
            warn("[ABP]: Backdoor module detected: " .. script:GetFullName())
            SendWebhook("[ABP]: Backdoor module detected: " .. script:GetFullName())
            showWarning(script:GetFullName(), "Name resembles known backdoor modules")
        end
    end
end

-- Function to scan all existing scripts in the game
local function scanAllScripts()
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            scanScript(descendant)
        end
    end
end

-- Set up continuous monitoring
local function continuousScanning()
    -- Monitor new scripts added to the game
    game.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            scanScript(descendant)
        end
    end)

    -- Monitor changes to existing scripts
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant.Changed:Connect(function()
                scanScript(descendant)
            end)
        end
    end
end

-- Button click event to manually scan all scripts in the game
button.Click:Connect(function()
    scanAllScripts()
end)

-- Create Settings UI (optional)
local function createSettingsUI()
    local widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        true,
        false,
        200,
        300,
        200,
        300
    )
    local gui = plugin:CreateDockWidgetPluginGui("ABPSettings", widgetInfo)
    gui.Title = "ABP Settings"
    
    -- Add UI elements like TextBoxes for webhook URL or backdoor module names
    local webhookLabel = Instance.new("TextLabel", gui)
    webhookLabel.Text = "Webhook URL:"
    webhookLabel.Position = UDim2.new(0, 10, 0, 10)
    
    local webhookBox = Instance.new("TextBox", gui)
    webhookBox.Text = plugin:GetSetting("WebhookURL") or ""
    webhookBox.Position = UDim2.new(0, 10, 0, 40)
    webhookBox.Size = UDim2.new(0, 180, 0, 30)

    webhookBox.FocusLost:Connect(function()
        ABP.Webhook = webhookBox.Text
        plugin:SetSetting("WebhookURL", webhookBox.Text)
    end)
end

-- Initialize the plugin with continuous scanning
createSettingsUI()
continuousScanning()
