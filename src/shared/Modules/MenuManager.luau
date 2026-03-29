local MenuManager = {}

local TweenService = game:GetService("TweenService")

local debounce = false
local menuTweenDuration = 0.3
local fadeTweenDuration = 0.3
local menuCloseWait = 0.35

local function tween(obj, goal, duration, delay)
    local tweenInfo = TweenInfo.new(duration or menuTweenDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, delay or 0)
    local newTween = TweenService:Create(obj, tweenInfo, goal)
    newTween:Play()
    return newTween
end

local function fadeDescendants(parentMenu, target, duration)
    for _, child in pairs(parentMenu:GetDescendants()) do
        local goals = {}

        if child:IsA("Frame") then
            if child:GetAttribute("UpgradeFrame") then
                goals.BackgroundTransparency = 1
            end
        end
        
        if child:IsA("Frame") then
            if child.Name == "SettingFrame" or "Holder" then
                goals.BackgroundTransparency = 1
            end
        end

        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child:IsA("TextButton") then
                goals.BackgroundTransparency = target
            end
			goals.TextTransparency = target
		end

        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
			goals.ImageTransparency = target
		end

        if child:IsA("ScrollingFrame") then
			goals.ScrollBarImageTransparency = target
		end

		if next(goals) then
			tween(child, goals, duration)
		end
    end
end

function MenuManager:AnimateMenuOpen(menuFrame)
    menuFrame.BackgroundTransparency = 1
    fadeDescendants(menuFrame, 1, 0)
    menuFrame.Visible = true
    tween(menuFrame, {BackgroundTransparency = 0}, menuTweenDuration)
    fadeDescendants(menuFrame, 0, fadeTweenDuration)
end

function MenuManager:AnimateMenuClose(menuFrame)
    tween(menuFrame, {BackgroundTransparency = 1}, menuTweenDuration)
    fadeDescendants(menuFrame, 1, fadeTweenDuration)

    task.spawn(function()
        task.wait(menuTweenDuration)
        menuFrame.Visible = false
    end)
end

function MenuManager:CloseAllMenus(menusFolder)
    for _, menu in pairs(menusFolder:GetChildren()) do
        if menu:IsA("Frame") then
            if menu.Visible then
                self:AnimateMenuClose(menu)
            end
        end
    end
end

function MenuManager:DisableAllButtons(buttonsFolder)
    for _, button in pairs(buttonsFolder:GetChildren()) do
        if button:IsA("ImageButton") then
            button.Active = false
            button.Interactable = false
            tween(button, {BackgroundTransparency = 1, ImageTransparency = 1}, menuTweenDuration)
        end
    end
end

function MenuManager:EnableAllButtons(buttonsFolder)
    for _, button in pairs(buttonsFolder:GetChildren()) do
        if button:IsA("ImageButton") then
            button.Active = true
            button.Interactable = true
            tween(button, {BackgroundTransparency = 0, ImageTransparency = 0}, menuTweenDuration)
        end
    end
end

function MenuManager:SetupButton(button, targetFrame)
	button.MouseButton1Click:Connect(function()
		if debounce then return end
		if not targetFrame then return end
		debounce = true
		if targetFrame.Visible then
			self:AnimateMenuClose(targetFrame)
			task.wait(menuCloseWait)
			debounce = false
			return
		end
		local wasAnyOpen = false
		for _, menu in pairs(targetFrame.Parent:GetChildren()) do
			if menu:IsA("Frame") then
				if menu.Visible and menu ~= targetFrame then
					print("[MenuManager]: Closing open menu: " .. menu.Name)
					self:AnimateMenuClose(menu)
					wasAnyOpen = true
				end
			end
		end
		if wasAnyOpen then
			task.wait(menuCloseWait)
		end
		self:AnimateMenuOpen(targetFrame)
		task.wait(menuTweenDuration)
		debounce = false
	end)
end

function MenuManager:IsMenuOpen(menusFolder)
    if not menusFolder then return end
    for _, menu in pairs(menusFolder:GetChildren()) do
        if menu:IsA("Frame") then
            if menu.Visible then
                return menu.Visible
            end
        end
    end
end
return MenuManager