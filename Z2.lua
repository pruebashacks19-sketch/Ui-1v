local ZUI = {}
ZUI.__index = ZUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(13, 15, 20),
    Sidebar = Color3.fromRGB(17, 19, 25),
    Panel = Color3.fromRGB(20, 23, 30),
    Element = Color3.fromRGB(25, 28, 36),
    ElementHover = Color3.fromRGB(31, 35, 45),
    Border = Color3.fromRGB(42, 46, 58),
    Text = Color3.fromRGB(240, 242, 247),
    SubText = Color3.fromRGB(145, 151, 164),
    Blue = Color3.fromRGB(55, 145, 255),
    BlueLight = Color3.fromRGB(100, 180, 255),
    Red = Color3.fromRGB(240, 75, 85),
    White = Color3.fromRGB(255, 255, 255)
}

local function tween(obj, time, props, style, direction)
    local info = TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function padding(parent, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = parent
    return p
end

local function makeText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or Theme.Text
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function iconText(parent, text)
    local label = makeText(parent, text, 15, Theme.SubText, Enum.Font.GothamBold)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    return label
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function ZUI:Notify(options)
    options = options or {}

    local gui = self.ScreenGui
    if not gui then return end

    local holder = gui:FindFirstChild("Notifications")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "Notifications"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(0, 320, 1, -20)
        holder.Position = UDim2.new(1, -335, 0, 10)
        holder.Parent = gui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Parent = holder
    end

    local note = Instance.new("Frame")
    note.Size = UDim2.new(1, 0, 0, 72)
    note.BackgroundColor3 = Theme.Panel
    note.BackgroundTransparency = 0.04
    note.Parent = holder
    corner(note, 10)
    stroke(note, Theme.Border)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -18)
    bar.Position = UDim2.new(0, 8, 0, 9)
    bar.BackgroundColor3 = Theme.Blue
    bar.BorderSizePixel = 0
    bar.Parent = note
    corner(bar, 2)

    local titleLabel = makeText(note, options.Title or "Z UI", 14, Theme.Text, Enum.Font.GothamBold)
    titleLabel.Position = UDim2.new(0, 22, 0, 10)
    titleLabel.Size = UDim2.new(1, -32, 0, 20)

    local msgLabel = makeText(note, options.Content or options.Message or "", 12, Theme.SubText)
    msgLabel.Position = UDim2.new(0, 22, 0, 32)
    msgLabel.Size = UDim2.new(1, -32, 0, 30)
    msgLabel.TextWrapped = true

    note.Position = UDim2.new(1, 30, 0, 0)
    tween(note, 0.35, {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(options.Duration or 3, function()
        if note.Parent then
            tween(note, 0.3, {
                Position = UDim2.new(1, 30, 0, 0),
                BackgroundTransparency = 1
            })
            task.wait(0.32)
            note:Destroy()
        end
    end)
end

function ZUI:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, ZUI)

    local old = CoreGui:FindFirstChild("ZUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.ScreenGui = gui
    self.Services = {}
    self.ActiveService = nil

    local finalSize = options.Size or UDim2.fromOffset(720, 460)

    local main = Instance.new("Frame")
    main.Name = "Window"
    main.Size = finalSize
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 12)
    stroke(main, Theme.Border)
    self.Main = main

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 58)
    topbar.BackgroundColor3 = Theme.Panel
    topbar.BorderSizePixel = 0
    topbar.Parent = main

    local title = makeText(topbar, options.Title or "Z UI", 17, Theme.Text, Enum.Font.GothamBold)
    title.Position = UDim2.new(0, 18, 0, 9)
    title.Size = UDim2.new(1, -150, 0, 22)

    local subtitle = makeText(topbar, options.Subtitle or "Modern Interface", 11, Theme.SubText)
    subtitle.Position = UDim2.new(0, 19, 0, 31)
    subtitle.Size = UDim2.new(1, -150, 0, 18)

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Text = "×"
    close.TextColor3 = Theme.SubText
    close.TextSize = 24
    close.Font = Enum.Font.Gotham
    close.BackgroundTransparency = 1
    close.Size = UDim2.fromOffset(40, 40)
    close.Position = UDim2.new(1, -48, 0, 9)
    close.Parent = topbar

    close.MouseEnter:Connect(function()
        tween(close, 0.15, {TextColor3 = Theme.Red})
    end)
    close.MouseLeave:Connect(function()
        tween(close, 0.15, {TextColor3 = Theme.SubText})
    end)
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    makeDraggable(topbar, main)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 175, 1, -58)
    sidebar.Position = UDim2.new(0, 0, 0, 58)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebarTitle = makeText(sidebar, "SERVICES", 10, Theme.SubText, Enum.Font.GothamBold)
    sidebarTitle.Position = UDim2.new(0, 17, 0, 14)
    sidebarTitle.Size = UDim2.new(1, -25, 0, 18)

    local serviceList = Instance.new("ScrollingFrame")
    serviceList.Name = "ServiceList"
    serviceList.BackgroundTransparency = 1
    serviceList.BorderSizePixel = 0
    serviceList.Position = UDim2.new(0, 8, 0, 42)
    serviceList.Size = UDim2.new(1, -16, 1, -50)
    serviceList.ScrollBarThickness = 2
    serviceList.ScrollBarImageColor3 = Theme.Blue
    serviceList.CanvasSize = UDim2.new()
    serviceList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    serviceList.Parent = sidebar

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = serviceList
    padding(serviceList, 0, 0, 3, 3)

    local selector = Instance.new("Frame")
    selector.Name = "BlueSelector"
    selector.Size = UDim2.new(0, 3, 0, 38)
    selector.Position = UDim2.new(0, 2, 0, 3)
    selector.BackgroundColor3 = Theme.Blue
    selector.BorderSizePixel = 0
    selector.Visible = false
    selector.ZIndex = 20
    selector.Parent = serviceList
    corner(selector, 2)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -175, 1, -58)
    content.Position = UDim2.new(0, 175, 0, 58)
    content.BackgroundColor3 = Theme.Background
    content.BorderSizePixel = 0
    content.Parent = main

    self.Sidebar = sidebar
    self.ServiceList = serviceList
    self.Selector = selector
    self.Content = content

    main.Size = UDim2.fromOffset(0, 0)
    tween(main, 0.5, {Size = finalSize}, Enum.EasingStyle.Back)

    return self
end


-- Service API wrappers
-- Allows: Main:CreateButton(...), Main:CreateToggle(...), etc.
local function attachServiceMethods(service, window)
    function service:CreateSection(text)
        return window:CreateSection(self, text)
    end

    function service:CreateLabel(options)
        return window:CreateLabel(self, options)
    end

    function service:CreateButton(options)
        return window:CreateButton(self, options)
    end

    function service:CreateToggle(options)
        return window:CreateToggle(self, options)
    end

    function service:CreateSlider(options)
        return window:CreateSlider(self, options)
    end

    function service:CreateInput(options)
        return window:CreateInput(self, options)
    end

    function service:CreateDropdown(options)
        return window:CreateDropdown(self, options)
    end

    return service
end


function ZUI:CreateService(name, icon)
    assert(self.Main, "CreateWindow must be called first.")

    local service = {
        Name = name,
        Window = self,
        Elements = {}
    }

    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = Theme.Sidebar
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self.ServiceList

    local iconLabel = iconText(button, icon or "•")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.fromOffset(30, 38)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)

    local label = makeText(button, name, 12, Theme.SubText, Enum.Font.GothamMedium)
    label.Name = "Label"
    label.Size = UDim2.new(1, -42, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "_Page"
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Blue
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    padding(page, 18, 18, 18, 18)

    service.Button = button
    service.Page = page

    button.MouseEnter:Connect(function()
        if self.ActiveService ~= service then
            tween(button, 0.15, {
                BackgroundTransparency = 0.65,
                BackgroundColor3 = Theme.ElementHover
            })
            tween(label, 0.15, {TextColor3 = Theme.Text})
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveService ~= service then
            tween(button, 0.15, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Theme.Sidebar
            })
            tween(label, 0.15, {TextColor3 = Theme.SubText})
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:SelectService(service)
    end)

    table.insert(self.Services, service)

    if not self.ActiveService then
        task.defer(function()
            self:SelectService(service, true)
        end)
    end

    return attachServiceMethods(service, self)
end

function ZUI:SelectService(service, instant)
    if not service then return end

    self.ActiveService = service

    for _, s in ipairs(self.Services) do
        local active = s == service
        s.Page.Visible = active

        tween(s.Button, instant and 0 or 0.18, {
            BackgroundTransparency = active and 0.88 or 1,
            BackgroundColor3 = active and Theme.Blue or Theme.Sidebar
        })

        local lbl = s.Button:FindFirstChild("Label")
        local icon = s.Button:FindFirstChild("Icon")

        if lbl then
            tween(lbl, instant and 0 or 0.18, {
                TextColor3 = active and Theme.Text or Theme.SubText
            })
        end

        if icon then
            tween(icon, instant and 0 or 0.18, {
                TextColor3 = active and Theme.BlueLight or Theme.SubText
            })
        end
    end

    task.defer(function()
        local targetY = service.Button.AbsolutePosition.Y
            - self.ServiceList.AbsolutePosition.Y
            + self.ServiceList.CanvasPosition.Y

        local targetHeight = service.Button.AbsoluteSize.Y

        self.Selector.Visible = true

        if instant then
            self.Selector.Position = UDim2.new(0, 2, 0, targetY)
            self.Selector.Size = UDim2.new(0, 3, 0, targetHeight)
        else
            tween(self.Selector, 0.35, {
                Position = UDim2.new(0, 2, 0, targetY),
                Size = UDim2.new(0, 3, 0, targetHeight)
            }, Enum.EasingStyle.Quint)

            self.Selector.BackgroundTransparency = 0.15
            tween(self.Selector, 0.35, {BackgroundTransparency = 0})
        end
    end)
end

function ZUI:_CreateCard(service, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height or 56)
    card.BackgroundColor3 = Theme.Element
    card.BorderSizePixel = 0
    card.Parent = service.Page
    corner(card, 9)
    stroke(card, Theme.Border)

    card.MouseEnter:Connect(function()
        tween(card, 0.15, {BackgroundColor3 = Theme.ElementHover})
    end)

    card.MouseLeave:Connect(function()
        tween(card, 0.15, {BackgroundColor3 = Theme.Element})
    end)

    return card
end

function ZUI:CreateSection(service, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundTransparency = 1
    holder.Parent = service.Page

    local label = makeText(holder, text or "Section", 11, Theme.BlueLight, Enum.Font.GothamBold)
    label.Size = UDim2.new(1, 0, 1, 0)

    return holder
end

function ZUI:CreateLabel(service, options)
    options = type(options) == "string" and {Text = options} or options or {}

    local card = self:_CreateCard(service, options.Height or 52)
    local title = makeText(card, options.Text or options.Name or "Label", 13, Theme.Text)
    title.Position = UDim2.new(0, 14, 0, 8)
    title.Size = UDim2.new(1, -28, 1, -16)
    title.TextWrapped = true

    return card
end

function ZUI:CreateButton(service, options)
    options = options or {}

    local card = self:_CreateCard(service, 58)

    local title = makeText(card, options.Name or "Button", 13, Theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.new(0, 14, 0, 7)
    title.Size = UDim2.new(1, -115, 0, 20)

    local desc = makeText(card, options.Description or "", 10, Theme.SubText)
    desc.Position = UDim2.new(0, 14, 0, 29)
    desc.Size = UDim2.new(1, -115, 0, 18)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(82, 32)
    button.Position = UDim2.new(1, -94, 0.5, -16)
    button.BackgroundColor3 = Theme.Blue
    button.Text = options.Text or "Run"
    button.TextColor3 = Theme.White
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = card
    corner(button, 7)

    button.MouseEnter:Connect(function()
        tween(button, 0.15, {BackgroundColor3 = Theme.BlueLight})
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.15, {BackgroundColor3 = Theme.Blue})
    end)

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            task.spawn(options.Callback)
        end
    end)

    return card
end

function ZUI:CreateToggle(service, options)
    options = options or {}

    local state = options.Default == true
    local card = self:_CreateCard(service, 58)

    local title = makeText(card, options.Name or "Toggle", 13, Theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.new(0, 14, 0, 7)
    title.Size = UDim2.new(1, -85, 0, 20)

    local desc = makeText(card, options.Description or "", 10, Theme.SubText)
    desc.Position = UDim2.new(0, 14, 0, 29)
    desc.Size = UDim2.new(1, -85, 0, 18)

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(44, 24)
    toggle.Position = UDim2.new(1, -58, 0.5, -12)
    toggle.BackgroundColor3 = Theme.Border
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = card
    corner(toggle, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Theme.White
    knob.Parent = toggle
    corner(knob, 9)

    local function update(fire)
        tween(toggle, 0.2, {
            BackgroundColor3 = state and Theme.Blue or Theme.Border
        })

        tween(knob, 0.2, {
            Position = state
                and UDim2.new(1, -21, 0.5, -9)
                or UDim2.new(0, 3, 0.5, -9)
        })

        if fire and options.Callback then
            task.spawn(options.Callback, state)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        update(true)
    end)

    update(false)

    local object = {}

    function object:Set(value)
        state = value == true
        update(true)
    end

    function object:Get()
        return state
    end

    return object
end

function ZUI:CreateSlider(service, options)
    options = options or {}

    local min = options.Min or 0
    local max = options.Max or 100
    local value = math.clamp(options.Default or min, min, max)

    local card = self:_CreateCard(service, 76)

    local title = makeText(card, options.Name or "Slider", 13, Theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.new(0, 14, 0, 7)
    title.Size = UDim2.new(1, -80, 0, 20)

    local valueLabel = makeText(card, tostring(value), 11, Theme.BlueLight, Enum.Font.GothamBold)
    valueLabel.Position = UDim2.new(1, -65, 0, 8)
    valueLabel.Size = UDim2.fromOffset(50, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 6)
    bar.Position = UDim2.new(0, 14, 0, 48)
    bar.BackgroundColor3 = Theme.Border
    bar.BorderSizePixel = 0
    bar.P
