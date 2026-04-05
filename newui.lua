local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WindUI = {} 
local GLOBAL_CARDS = {}

local ACCENT_BLUE = Color3.fromRGB(0, 122, 255)
local BG_COLOR = Color3.fromRGB(15, 18, 22)
local CARD_COLOR = Color3.fromRGB(35, 38, 45)

local ZOOM_IN = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local ZOOM_OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function CoreMakeDraggable(handle, frame)
    local drag = false; local startPos, dragStart
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = inp.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local dt = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dt.X, startPos.Y.Scale, startPos.Y.Offset + dt.Y)
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "WindUI_Notify"
NotifyGui.ResetOnSpawn = false
if gethui then NotifyGui.Parent = gethui() else NotifyGui.Parent = CoreGui end

local NotifList = Instance.new("Frame", NotifyGui)
NotifList.Size = UDim2.new(0, 300, 1, -20); NotifList.Position = UDim2.new(1, -320, 0, 10); NotifList.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", NotifList)
UIList.SortOrder = Enum.SortOrder.LayoutOrder; UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom; UIList.Padding = UDim.new(0, 12)

function WindUI:Notify(nc)
    local TitleStr = nc.Title or "Notification"
    local ContentStr = nc.Content or ""
    local DurationNum = nc.Duration or 3

    local Wrapper = Instance.new("Frame", NotifList); Wrapper.Size = UDim2.new(1, 0, 0, 75); Wrapper.BackgroundTransparency = 1; Wrapper.ClipsDescendants = true
    local Card = Instance.new("Frame", Wrapper); Card.Size = UDim2.new(1, 0, 1, 0); Card.Position = UDim2.new(1, 350, 0, 0); Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.1
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Card).Color = Color3.fromRGB(60, 60, 70); Instance.new("UIStroke", Card).Thickness = 1.2

    local TimerLine = Instance.new("Frame", Card); TimerLine.Size = UDim2.new(1, -24, 0, 3); TimerLine.Position = UDim2.new(0, 12, 1, -8); TimerLine.BackgroundColor3 = ACCENT_BLUE; TimerLine.BorderSizePixel = 0
    Instance.new("UICorner", TimerLine).CornerRadius = UDim.new(1, 0)

    local T = Instance.new("TextLabel", Card); T.Size = UDim2.new(1, -24, 0, 20); T.Position = UDim2.new(0, 15, 0, 12); T.Text = TitleStr; T.TextColor3 = Color3.new(1, 1, 1); T.Font = Enum.Font.GothamBold; T.TextSize = 15; T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left
    local C = Instance.new("TextLabel", Card); C.Size = UDim2.new(1, -24, 0, 20); C.Position = UDim2.new(0, 15, 0, 32); C.Text = ContentStr; C.TextColor3 = Color3.fromRGB(160, 160, 160); C.Font = Enum.Font.GothamMedium; C.TextSize = 12; C.BackgroundTransparency = 1; C.TextXAlignment = Enum.TextXAlignment.Left; C.TextWrapped = true

    TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(TimerLine, TweenInfo.new(DurationNum, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()

    task.delay(DurationNum, function()
        TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 0, 0)}):Play(); task.wait(0.3)
        TweenService:Create(Wrapper, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.2)
        Wrapper:Destroy()
    end)
end

function WindUI:Popup(pc)
    self:Notify({ Title = pc.Title or "Popup", Content = pc.Content or "", Duration = 5 })
end

function WindUI:CreateWindow(WinConf)
    local Window = {}
    local WTitle = type(WinConf) == "table" and WinConf.Title or WinConf or "RainbowAI"
    local WVersion = type(WinConf) == "table" and WinConf.Version or "1.0.0"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RainbowAI_WindUI_Core"
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

    local Blur = Instance.new("BlurEffect", Lighting)
    Blur.Size = 0

    local Main = Instance.new("CanvasGroup", ScreenGui)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = BG_COLOR; Main.BackgroundTransparency = 0.15; Main.GroupTransparency = 1; Main.BorderSizePixel = 0
    local MainScale = Instance.new("UIScale", Main)
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 24)
    local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255,255,255); Stroke.Transparency = 0.85; Stroke.Thickness = 1.5

    local TopDrag = Instance.new("TextButton", Main); TopDrag.Size = UDim2.new(1, -150, 0, 70); TopDrag.BackgroundTransparency = 1; TopDrag.Text = ""; TopDrag.ZIndex = 1
    CoreMakeDraggable(TopDrag, Main)

    local Sidebar = Instance.new("Frame", Main); Sidebar.BackgroundTransparency = 1; Sidebar.ZIndex = 2
    local TitleLabel = Instance.new("TextLabel", Sidebar); TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.BackgroundTransparency = 1; TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd; TitleLabel.Text = WTitle
    local VersionLabel = Instance.new("TextLabel", Sidebar); VersionLabel.Text = "v" .. WVersion:gsub("^v", ""); VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 120); VersionLabel.Font = Enum.Font.GothamMedium; VersionLabel.TextSize = 12; VersionLabel.TextXAlignment = Enum.TextXAlignment.Left; VersionLabel.BackgroundTransparency = 1

    local NavList = Instance.new("ScrollingFrame", Sidebar); NavList.BackgroundTransparency = 1; NavList.ScrollBarThickness = 0
    NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y; NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
    local NavPadding = Instance.new("UIPadding", NavList); NavPadding.PaddingBottom = UDim.new(0, 20)
    Instance.new("UIListLayout", NavList).Padding = UDim.new(0, 10)

    local ProfileCard = Instance.new("Frame", Sidebar)
    ProfileCard.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
    ProfileCard.BackgroundTransparency = 0.4
    Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 12)

    local Avatar = Instance.new("ImageLabel", ProfileCard)
    Avatar.BackgroundColor3 = Color3.fromRGB(45, 48, 55); Avatar.BorderSizePixel = 0
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local DisplayName = Instance.new("TextLabel", ProfileCard)
    DisplayName.TextColor3 = Color3.new(1, 1, 1); DisplayName.Font = Enum.Font.GothamBold; DisplayName.TextSize = 13
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left; DisplayName.BackgroundTransparency = 1; DisplayName.TextTruncate = Enum.TextTruncate.AtEnd

    local UserName = Instance.new("TextLabel", ProfileCard)
    UserName.TextColor3 = Color3.fromRGB(150, 150, 150); UserName.Font = Enum.Font.GothamMedium; UserName.TextSize = 11
    UserName.TextXAlignment = Enum.TextXAlignment.Left; UserName.BackgroundTransparency = 1; UserName.TextTruncate = Enum.TextTruncate.AtEnd

    if Players.LocalPlayer then
        DisplayName.Text = Players.LocalPlayer.DisplayName
        UserName.Text = "@" .. Players.LocalPlayer.Name
        task.spawn(function()
            local s, img = pcall(function() return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
            if s and img then Avatar.Image = img end
        end)
    else
        DisplayName.Text = "Loading..."
        UserName.Text = "@guest"
    end

    local Content = Instance.new("Frame", Main); Content.BackgroundTransparency = 1; Content.ZIndex = 2
    local Search = Instance.new("TextBox", Content); Search.Size = UDim2.new(1, -150, 0, 40); Search.Position = UDim2.new(0, 20, 0, 25); Search.BackgroundTransparency = 1; Search.PlaceholderText = "搜索..."; Search.Text = ""; Search.TextColor3 = Color3.fromRGB(255, 255, 255); Search.Font = Enum.Font.Gotham; Search.TextSize = 15; Search.TextXAlignment = Enum.TextXAlignment.Left; Search.ZIndex = 10; Search.Active = true
    local PageHold = Instance.new("Frame", Content); PageHold.Size = UDim2.new(1, -20, 1, -90); PageHold.Position = UDim2.new(0, 0, 0, 80); PageHold.BackgroundTransparency = 1

    local GlobalSearchPage = Instance.new("ScrollingFrame", Content); GlobalSearchPage.Size = UDim2.new(1, -20, 1, -90); GlobalSearchPage.Position = UDim2.new(0, 0, 0, 80); GlobalSearchPage.BackgroundTransparency = 1; GlobalSearchPage.ScrollBarThickness = 2; GlobalSearchPage.Visible = false
    GlobalSearchPage.AutomaticCanvasSize = Enum.AutomaticSize.Y; GlobalSearchPage.CanvasSize = UDim2.new(0,0,0,0)
    local GSPadding = Instance.new("UIPadding", GlobalSearchPage); GSPadding.PaddingBottom = UDim.new(0, 20)
    local GLL = Instance.new("UIListLayout", GlobalSearchPage); GLL.Padding = UDim.new(0, 10); GLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    GLL.SortOrder = Enum.SortOrder.LayoutOrder

    local currentScale = 1
    local function GetScreenSize()
        local size = ScreenGui.AbsoluteSize
        if size.X > 0 then return size end
        if workspace.CurrentCamera then return workspace.CurrentCamera.ViewportSize end
        return Vector2.new(1920, 1080)
    end

    local function UpdateLayout()
        local vp = GetScreenSize()
        if vp.X == 0 then return end

        local isMobile = (vp.X < 800 or vp.Y < 500)
        currentScale = isMobile and 0.85 or 1

        if Main.Visible then TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = currentScale}):Play() end

        if isMobile then
            TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, 620, 0, 370)}):Play()
            Sidebar.Size = UDim2.new(0, 160, 1, 0)
            Content.Size = UDim2.new(1, -160, 1, 0); Content.Position = UDim2.new(0, 160, 0, 0)
            TitleLabel.Size = UDim2.new(1, -10, 0, 36); TitleLabel.Position = UDim2.new(0, 20, 0, 20); TitleLabel.TextSize = 22
            VersionLabel.Size = UDim2.new(1, -10, 0, 20); VersionLabel.Position = UDim2.new(0, 20, 0, 48)
            NavList.Size = UDim2.new(1, 0, 1, -150); NavList.Position = UDim2.new(0, 0, 0, 80)

            ProfileCard.Size = UDim2.new(1, -20, 0, 45); ProfileCard.Position = UDim2.new(0, 10, 1, -55)
            Avatar.Size = UDim2.new(0, 30, 0, 30); Avatar.Position = UDim2.new(0, 6, 0.5, -15)
            DisplayName.Size = UDim2.new(1, -44, 0, 20); DisplayName.Position = UDim2.new(0, 40, 0, 4)
            UserName.Size = UDim2.new(1, -44, 0, 20); UserName.Position = UDim2.new(0, 40, 0, 20)

            NotifList.Size = UDim2.new(0, 220, 1, -20); NotifList.Position = UDim2.new(1, -230, 0, 10)
        else
            TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, 850, 0, 500)}):Play()
            Sidebar.Size = UDim2.new(0, 210, 1, 0)
            Content.Size = UDim2.new(1, -210, 1, 0); Content.Position = UDim2.new(0, 210, 0, 0)
            TitleLabel.Size = UDim2.new(1, -10, 0, 36); TitleLabel.Position = UDim2.new(0, 20, 0, 22); TitleLabel.TextSize = 26
            VersionLabel.Size = UDim2.new(1, -10, 0, 20); VersionLabel.Position = UDim2.new(0, 20, 0, 54)
            NavList.Size = UDim2.new(1, 0, 1, -175); NavList.Position = UDim2.new(0, 0, 0, 95)

            ProfileCard.Size = UDim2.new(1, -30, 0, 50); ProfileCard.Position = UDim2.new(0, 15, 1, -65)
            Avatar.Size = UDim2.new(0, 34, 0, 34); Avatar.Position = UDim2.new(0, 8, 0.5, -17)
            DisplayName.Size = UDim2.new(1, -54, 0, 20); DisplayName.Position = UDim2.new(0, 48, 0, 6)
            UserName.Size = UDim2.new(1, -54, 0, 20); UserName.Position = UDim2.new(0, 48, 0, 24)

            NotifList.Size = UDim2.new(0, 300, 1, -20); NotifList.Position = UDim2.new(1, -320, 0, 10)
        end
    end
    ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLayout)
    UpdateLayout() 

    MainScale.Scale = currentScale * 0.8 

    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = Search.Text:lower()
        if q == "" then
            GlobalSearchPage.Visible = false; PageHold.Visible = true
            for _, obj in ipairs(GLOBAL_CARDS) do 
                if obj.Instance and obj.Parent then obj.Instance.Parent = obj.Parent; obj.Instance.Visible = true end
            end
        else
            PageHold.Visible = false; GlobalSearchPage.Visible = true
            for _, obj in ipairs(GLOBAL_CARDS) do 
                if obj.Instance and obj.Instance.Name then
                    if obj.Instance.Name:lower():find(q) then obj.Instance.Parent = GlobalSearchPage; obj.Instance.Visible = true
                    else obj.Instance.Visible = false end
                end
            end
        end
    end)

    local function MakeCtrlBtn(char, rx)
        local btn = Instance.new("TextButton", Main); btn.Size = UDim2.new(0, 36, 0, 36); btn.Position = UDim2.new(1, rx, 0, 25); btn.BackgroundColor3 = (char=="X" and Color3.fromRGB(255,60,60) or Color3.fromRGB(255,255,255)); btn.BackgroundTransparency = (char=="X" and 0 or 0.8); btn.Text = char; btn.TextColor3 = (char=="X" and Color3.new(1,1,1) or Color3.new(0,0,0)); btn.Font = Enum.Font.GothamBold; btn.TextSize = 18; btn.AutoButtonColor = false; btn.ZIndex = 999
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        return btn
    end
    local BtnClose, BtnMini = MakeCtrlBtn("X", -55), MakeCtrlBtn("-", -100)

    local Pill = Instance.new("CanvasGroup", ScreenGui); Pill.Size = UDim2.new(0, 240, 0, 50); Pill.Position = UDim2.new(0.5, 0, 0.08, 0); Pill.AnchorPoint = Vector2.new(0.5, 0.5); Pill.BackgroundColor3 = BG_COLOR; Pill.BackgroundTransparency = 0.2; Pill.GroupTransparency = 1; Pill.Visible = false
    local PillScale = Instance.new("UIScale", Pill); PillScale.Scale = 0.5; Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    local PGrad = Instance.new("UIGradient", Instance.new("UIStroke", Pill)); PGrad.Parent.Thickness = 2; PGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, ACCENT_BLUE), ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, ACCENT_BLUE) })
    local ranim = RunService.RenderStepped:Connect(function() if Pill.Visible then PGrad.Rotation = (PGrad.Rotation + 3) % 360 end end)

    local PIcons = {{22, 15, "rbxassetid://7733717447"}, {1, 50, nil, true}, {24, 65, "rbxassetid://6031289132"}}
    for i, v in ipairs(PIcons) do
        local obj = Instance.new(v[4] and "Frame" or "ImageLabel", Pill); obj.Size = v[4] and UDim2.new(0,1,0.5,0) or UDim2.new(0,v[1],0,v[1]); obj.Position = v[4] and UDim2.new(0,v[2],0.25,0) or UDim2.new(0,v[2],0.5, -(v[1]/2)); obj.BackgroundTransparency = v[4] and 0.8 or 1
        if v[3] then obj.Image = v[3]; obj.ImageColor3 = i==1 and Color3.fromRGB(150,150,150) or Color3.new(1,1,1) end
        if v[4] then obj.BackgroundColor3 = Color3.new(1,1,1); obj.BorderSizePixel = 0 end
    end

    local PillT = Instance.new("TextLabel", Pill); PillT.Size = UDim2.new(0, 90, 1, 0); PillT.Position = UDim2.new(0, 100, 0, 0); PillT.Text = "RainbowAI 助手"; PillT.TextColor3 = Color3.new(1,1,1); PillT.Font = Enum.Font.GothamMedium; PillT.TextSize = 15; PillT.TextXAlignment = Enum.TextXAlignment.Left; PillT.BackgroundTransparency = 1
    local PCheck = Instance.new("TextLabel", Pill); PCheck.Size = UDim2.new(0, 24, 0, 24); PCheck.Position = UDim2.new(1, -35, 0.5, -12); PCheck.Text = ""; PCheck.TextColor3 = ACCENT_BLUE; PCheck.Font = Enum.Font.Gotham; PCheck.TextSize = 22; PCheck.BackgroundTransparency = 1
    local PDragZone = Instance.new("TextButton", Pill); PDragZone.Size = UDim2.new(0, 60, 1, 0); PDragZone.BackgroundTransparency = 1; PDragZone.Text = ""; PDragZone.ZIndex=99
    CoreMakeDraggable(PDragZone, Pill)
    local PClkZone = Instance.new("TextButton", Pill); PClkZone.Size = UDim2.new(1, -60, 1, 0); PClkZone.Position = UDim2.new(0, 60, 0, 0); PClkZone.BackgroundTransparency = 1; PClkZone.Text = ""; PClkZone.ZIndex=99

    local AnimLock = false
    local function ToggleMini(minimize)
        if AnimLock then return end; AnimLock = true
        if minimize then
            TweenService:Create(Blur, ZOOM_OUT, {Size = 0}):Play(); TweenService:Create(MainScale, ZOOM_OUT, {Scale = currentScale * 0.8}):Play(); TweenService:Create(Main, ZOOM_OUT, {GroupTransparency = 1}):Play(); task.wait(0.3)
            Main.Visible = false; Pill.Visible = true; PillScale.Scale = 0.5
            TweenService:Create(PillScale, ZOOM_IN, {Scale = 1}):Play(); TweenService:Create(Pill, ZOOM_IN, {GroupTransparency = 0}):Play()
        else
            TweenService:Create(PillScale, ZOOM_OUT, {Scale = 0.5}):Play(); TweenService:Create(Pill, ZOOM_OUT, {GroupTransparency = 1}):Play(); task.wait(0.3)
            Pill.Visible = false; Main.Visible = true; MainScale.Scale = currentScale * 0.8
            TweenService:Create(Blur, ZOOM_IN, {Size = 16}):Play(); TweenService:Create(MainScale, ZOOM_IN, {Scale = currentScale}):Play(); TweenService:Create(Main, ZOOM_IN, {GroupTransparency = 0}):Play()
        end
        AnimLock = false
    end
    BtnMini.MouseButton1Click:Connect(function() ToggleMini(true) end)
    PClkZone.MouseButton1Click:Connect(function() ToggleMini(false) end)
    BtnClose.MouseButton1Click:Connect(function()
        TweenService:Create(MainScale, ZOOM_OUT, {Scale = currentScale * 0.8}):Play(); TweenService:Create(Main, ZOOM_OUT, {GroupTransparency = 1}):Play()
        TweenService:Create(Blur, ZOOM_OUT, {Size = 0}):Play(); task.wait(0.3)
        if ranim then ranim:Disconnect() end; Blur:Destroy(); ScreenGui:Destroy()
    end)

    TweenService:Create(Blur, ZOOM_IN, {Size = 16}):Play(); TweenService:Create(MainScale, ZOOM_IN, {Scale = currentScale}):Play(); TweenService:Create(Main, ZOOM_IN, {GroupTransparency = 0}):Play()

    function Window:Tag() end
    function Window:EditOpenButton() end

    local TABS_OBJ = {}

    function Window:Tab(cnf)
        local TT = cnf.Title or "No Title"
        local locked = cnf.Locked or false
        local tabLayoutCounter = 0

        local NBtn = Instance.new("TextButton", NavList)
        NBtn.Size = UDim2.new(1, -20, 0, 45); NBtn.Position = UDim2.new(0, 10, 0, 0); NBtn.BackgroundTransparency = 1; NBtn.AutoButtonColor = false; NBtn.Text = TT .. (locked and " (🔒)" or "")
        NBtn.TextColor3 = Color3.fromRGB(130, 130, 130); NBtn.Font = Enum.Font.GothamBold; NBtn.TextSize = 15; NBtn.TextXAlignment = Enum.TextXAlignment.Left
        local padding = Instance.new("UIPadding", NBtn); padding.PaddingLeft = UDim.new(0, 15)
        Instance.new("UICorner", NBtn).CornerRadius = UDim.new(0, 10)

        local Page = Instance.new("ScrollingFrame", PageHold)
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.CanvasSize = UDim2.new(0,0,0,0)
        local PagePadding = Instance.new("UIPadding", Page); PagePadding.PaddingBottom = UDim.new(0, 20)
        local LL = Instance.new("UIListLayout", Page)
        LL.Padding = UDim.new(0, 10); LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        LL.SortOrder = Enum.SortOrder.LayoutOrder

        NBtn.MouseButton1Click:Connect(function()
            if locked then return end
            if Search.Text ~= "" then Search.Text = "" end

            for _, t in pairs(TABS_OBJ) do
                t.Page.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(130, 130, 130)}):Play()
            end
            Page.Visible = true
            TweenService:Create(NBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15, BackgroundColor3 = ACCENT_BLUE, TextColor3 = Color3.new(1,1,1)}):Play()
        end)

        table.insert(TABS_OBJ, {Btn = NBtn, Page = Page})

        if #TABS_OBJ == 1 then
            Page.Visible = true; NBtn.BackgroundTransparency = 0.15; NBtn.BackgroundColor3 = ACCENT_BLUE; NBtn.TextColor3 = Color3.new(1,1,1)
        end

local CustomTabAPI = {}

        function CustomTabAPI:Section(sc)
            tabLayoutCounter = tabLayoutCounter + 1
            local SFrame = Instance.new("Frame", Page); SFrame.Name = sc.Title or "Section"
            SFrame.Size = UDim2.new(1, -20, 0, 30); SFrame.BackgroundTransparency = 1; SFrame.LayoutOrder = tabLayoutCounter
            local T = Instance.new("TextLabel", SFrame)
            T.Size = UDim2.new(1, 0, 1, 0); T.Text = sc.Title or "Section"; T.Font = Enum.Font.GothamBold; T.TextSize = 16; T.TextColor3 = Color3.fromRGB(200, 200, 200); T.TextXAlignment = Enum.TextXAlignment.Left; T.BackgroundTransparency = 1
            table.insert(GLOBAL_CARDS, {Instance = SFrame, Parent = Page})
            return SFrame
        end

        function CustomTabAPI:Paragraph(pc)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("Frame", Page); Card.Name = pc.Title or "Paragraph"
            Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.5; Card.BorderSizePixel = 0; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local T = Instance.new("TextLabel", Card)
            T.Size = UDim2.new(1, -20, 0, 25); T.Position = UDim2.new(0, 15, 0, 5); T.Text = pc.Title or ""; T.Font = Enum.Font.GothamBold; T.TextSize = 15; T.TextColor3 = Color3.new(1,1,1); T.TextXAlignment = Enum.TextXAlignment.Left; T.BackgroundTransparency = 1

            local D = Instance.new("TextLabel", Card)
            D.Size = UDim2.new(1, -30, 0, 0); D.Position = UDim2.new(0, 15, 0, 30); D.Text = pc.Desc or ""; D.Font = Enum.Font.GothamMedium; D.TextSize = 12; D.TextColor3 = Color3.fromRGB(150, 150, 150); D.TextXAlignment = Enum.TextXAlignment.Left; D.TextYAlignment = Enum.TextYAlignment.Top; D.BackgroundTransparency = 1; D.TextWrapped = true; D.RichText = true

            local function updateSize()
                D.Size = UDim2.new(1, -30, 0, D.TextBounds.Y)
                Card.Size = UDim2.new(1, -20, 0, 40 + D.TextBounds.Y)
            end
            D:GetPropertyChangedSignal("TextBounds"):Connect(updateSize); updateSize()

            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            local PObj = {}
            function PObj:SetDesc(newDesc) D.Text = newDesc end
            return PObj
        end

        function CustomTabAPI:Button(bc)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("TextButton", Page); Card.Size = UDim2.new(1, -20, 0, 45); Card.Name = bc.Title or "Btn"; Card.BackgroundColor3 = bc.Color or CARD_COLOR; Card.BackgroundTransparency = bc.Color and 0.2 or 0.5; Card.AutoButtonColor = false; Card.Text = ""; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local TL = Instance.new("TextLabel", Card); TL.Position = UDim2.new(0, 15, 0, 0)
            TL.Text = (bc.Title or "") .. (bc.Locked and " 🔒" or ""); TL.TextColor3 = Color3.new(1,1,1); TL.Font = Enum.Font.GothamBold; TL.TextSize = 14; TL.BackgroundTransparency = 1; TL.TextXAlignment = Enum.TextXAlignment.Left

            if bc.Desc and bc.Desc ~= "" then
                TL.Position = UDim2.new(0, 15, 0, 8); TL.Size = UDim2.new(1, -20, 0, 20)
                local DL = Instance.new("TextLabel", Card); DL.Position = UDim2.new(0, 15, 0, 28); DL.Text = bc.Desc; DL.TextColor3 = Color3.fromRGB(200, 200, 200); DL.Font = Enum.Font.GothamMedium; DL.TextSize = 11; DL.BackgroundTransparency = 1; DL.TextXAlignment = Enum.TextXAlignment.Left; DL.TextWrapped = true; DL.TextYAlignment = Enum.TextYAlignment.Top
                
                local function updateSize()
                    DL.Size = UDim2.new(1, -30, 0, DL.TextBounds.Y)
                    Card.Size = UDim2.new(1, -20, 0, 38 + DL.TextBounds.Y)
                end
                DL:GetPropertyChangedSignal("TextBounds"):Connect(updateSize); updateSize()
            else
                TL.Size = UDim2.new(1, -20, 1, 0)
            end

            Card.MouseButton1Click:Connect(function()
                if bc.Locked then return end
                local sc = Instance.new("UIScale", Card); sc.Scale = 0.95; TweenService:Create(sc, ZOOM_IN, {Scale = 1}):Play(); task.delay(0.5, function() sc:Destroy() end)
                TweenService:Create(Card, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play(); task.delay(0.1, function() TweenService:Create(Card, TweenInfo.new(0.4), {BackgroundTransparency = bc.Color and 0.2 or 0.5}):Play() end)
                if bc.Callback then bc.Callback() end
            end)
            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            return Card
        end

        function CustomTabAPI:Toggle(tc)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("TextButton", Page); Card.Name = tc.Title or "Toggle"; Card.Size = UDim2.new(1, -20, 0, 50); Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.5; Card.AutoButtonColor = false; Card.Text = ""; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local TL = Instance.new("TextLabel", Card); TL.Size = UDim2.new(1, -80, 0, 20); TL.Position = UDim2.new(0, 15, 0, 15)
            if tc.Desc and tc.Desc ~= "" then TL.Position = UDim2.new(0, 15, 0, 8) end 
            TL.Text = tc.Title or ""; TL.TextColor3 = Color3.new(1,1,1); TL.Font = Enum.Font.GothamBold; TL.TextSize = 14; TL.BackgroundTransparency = 1; TL.TextXAlignment = Enum.TextXAlignment.Left

            if tc.Desc and tc.Desc ~= "" then
                local DL = Instance.new("TextLabel", Card); DL.Size = UDim2.new(1, -80, 0, 20); DL.Position = UDim2.new(0, 15, 0, 26); DL.Text = tc.Desc; DL.TextColor3 = Color3.fromRGB(140, 140, 140); DL.Font = Enum.Font.GothamMedium; DL.TextSize = 11; DL.BackgroundTransparency = 1; DL.TextXAlignment = Enum.TextXAlignment.Left
            end

            local Pill = Instance.new("Frame", Card); Pill.Size = UDim2.new(0, 40, 0, 22); Pill.Position = UDim2.new(1, -55, 0.5, -11); Pill.BackgroundColor3 = Color3.fromRGB(60,60,65)
            Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
            local Circle = Instance.new("Frame", Pill); Circle.Size = UDim2.new(0, 18, 0, 18); Circle.Position = UDim2.new(0, 2, 0.5, -9); Circle.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local state = tc.Value or false
            local function Update(anim)
                local endPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local endCol = state and ACCENT_BLUE or Color3.fromRGB(60,60,65)
                if anim then
                    TweenService:Create(Circle, TweenInfo.new(0.2), {Position = endPos}):Play()
                    TweenService:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3 = endCol}):Play()
                else
                    Circle.Position = endPos; Pill.BackgroundColor3 = endCol
                end
            end
            Update(false)

            Card.MouseButton1Click:Connect(function()
                state = not state; Update(true); if tc.Callback then tc.Callback(state) end
            end)
            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            return Card
        end

        function CustomTabAPI:Dropdown(dc)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("Frame", Page); Card.Name = dc.Title or "Dropdown"; Card.Size = UDim2.new(1, -20, 0, 50); Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.5; Card.ClipsDescendants = true; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local Btn = Instance.new("TextButton", Card); Btn.Size = UDim2.new(1, 0, 0, 50); Btn.BackgroundTransparency = 1; Btn.Text = ""

            local TL = Instance.new("TextLabel", Btn); TL.Size = UDim2.new(1, -120, 0, 20); TL.Position = UDim2.new(0, 15, 0, 15); TL.Text = dc.Title or ""; TL.TextColor3 = Color3.new(1,1,1); TL.Font = Enum.Font.GothamBold; TL.TextSize = 14; TL.BackgroundTransparency = 1; TL.TextXAlignment = Enum.TextXAlignment.Left
            local DL = Instance.new("TextLabel", Btn); DL.Size = UDim2.new(1, -120, 0, 20); DL.Position = UDim2.new(0, 15, 0, 28); DL.Text = dc.Desc or ""; DL.TextColor3 = Color3.fromRGB(140, 140, 140); DL.Font = Enum.Font.GothamMedium; DL.TextSize = 11; DL.BackgroundTransparency = 1; DL.TextXAlignment = Enum.TextXAlignment.Left
            local ValL = Instance.new("TextLabel", Btn); ValL.Size = UDim2.new(0, 90, 0, 50); ValL.Position = UDim2.new(1, -105, 0, 0); ValL.Text = dc.Value or ""; ValL.TextColor3 = ACCENT_BLUE; ValL.Font = Enum.Font.GothamBold; ValL.TextSize = 13; ValL.BackgroundTransparency = 1; ValL.TextXAlignment = Enum.TextXAlignment.Right

            local Scroll = Instance.new("ScrollingFrame", Card); Scroll.Size = UDim2.new(1, -30, 0, 120); Scroll.Position = UDim2.new(0, 15, 0, 50); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.Visible = false
            Scroll.Active = true 
            Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            local SList = Instance.new("UIListLayout", Scroll); SList.Padding = UDim.new(0, 5)

            local open = false
            Btn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    Scroll.Visible = true
                    Scroll.ScrollingEnabled = true
                else
                    Scroll.ScrollingEnabled = false
                end
                TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = open and UDim2.new(1, -20, 0, 180) or UDim2.new(1, -20, 0, 50)}):Play()
                if not open then task.delay(0.3, function() if not open then Scroll.Visible = false end end) end
            end)

            for _, opt in ipairs(dc.Values or {}) do
                local OB = Instance.new("TextButton", Scroll); OB.Size = UDim2.new(1, 0, 0, 30); OB.BackgroundColor3 = Color3.fromRGB(20, 22, 26); OB.Text = "  " .. opt.Title; OB.TextColor3 = Color3.new(1,1,1); OB.Font = Enum.Font.GothamMedium; OB.TextSize = 13; OB.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", OB).CornerRadius = UDim.new(0, 6)
                OB.MouseButton1Click:Connect(function()
                    ValL.Text = opt.Title; open = false
                    Scroll.ScrollingEnabled = false
                    TweenService:Create(Card, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 50)}):Play()
                    task.delay(0.3, function() if not open then Scroll.Visible = false end end)
                    if dc.Callback then dc.Callback(opt) end
                end)
            end
            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            return Card
        end

        function CustomTabAPI:Input(ic)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("Frame", Page); Card.Name = ic.Title or "Input"; Card.Size = UDim2.new(1, -20, 0, 80); Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.5; Card.BorderSizePixel = 0; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local TL = Instance.new("TextLabel", Card); TL.Text = ic.Title; TL.Size = UDim2.new(1, -30, 0, 20); TL.Position = UDim2.new(0, 15, 0, 12); TL.TextColor3 = Color3.new(1,1,1); TL.Font = Enum.Font.GothamBold; TL.TextSize = 14; TL.BackgroundTransparency = 1; TL.TextXAlignment = Enum.TextXAlignment.Left

            local BoxGroup = Instance.new("Frame", Card); BoxGroup.Size = UDim2.new(1, -30, 0, 32); BoxGroup.Position = UDim2.new(0, 15, 0, 38); BoxGroup.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
            Instance.new("UICorner", BoxGroup).CornerRadius = UDim.new(0,8); Instance.new("UIStroke", BoxGroup).Color = Color3.fromRGB(55,60,70)

            local TBox = Instance.new("TextBox", BoxGroup); TBox.Size = UDim2.new(1, -16, 1, 0); TBox.Position = UDim2.new(0, 8, 0, 0); TBox.BackgroundTransparency = 1; TBox.PlaceholderText = ic.Placeholder or "请输入文本..."; TBox.Text = ic.Value or ""; TBox.TextColor3 = Color3.new(1,1,1); TBox.Font = Enum.Font.GothamMedium; TBox.TextSize = 13; TBox.TextXAlignment = Enum.TextXAlignment.Left; TBox.ClearTextOnFocus = false
            TBox.FocusLost:Connect(function() if ic.Callback then ic.Callback(TBox.Text) end end)
            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            return Card
        end

        function CustomTabAPI:Slider(sc)
            tabLayoutCounter = tabLayoutCounter + 1
            local Card = Instance.new("Frame", Page); Card.Name = sc.Title or "Slider"; Card.Size = UDim2.new(1, -20, 0, 70); Card.BackgroundColor3 = CARD_COLOR; Card.BackgroundTransparency = 0.5; Card.BorderSizePixel = 0; Card.LayoutOrder = tabLayoutCounter
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

            local cMin, cMax, cDef = sc.Value.Min or 0, sc.Value.Max or 100, sc.Value.Default or 50; local cStep = sc.Step or 1

            local TL = Instance.new("TextLabel", Card); TL.Text = sc.Title; TL.Size = UDim2.new(0.6, 0, 0, 20); TL.Position = UDim2.new(0, 15, 0, 12); TL.TextColor3 = Color3.new(1,1,1); TL.Font = Enum.Font.GothamBold; TL.TextSize = 14; TL.BackgroundTransparency = 1; TL.TextXAlignment = Enum.TextXAlignment.Left
            local VL = Instance.new("TextLabel", Card); VL.Text = tostring(cDef); VL.Size = UDim2.new(0.3, 0, 0, 20); VL.Position = UDim2.new(1, -45, 0, 12); VL.TextColor3 = ACCENT_BLUE; VL.Font = Enum.Font.GothamBold; VL.TextSize = 14; VL.BackgroundTransparency = 1; VL.TextXAlignment = Enum.TextXAlignment.Right

            local Trk = Instance.new("TextButton", Card); Trk.Size = UDim2.new(1, -30, 0, 8); Trk.Position = UDim2.new(0, 15, 0, 42); Trk.BackgroundColor3 = Color3.fromRGB(20,20,24); Trk.AutoButtonColor = false; Trk.Text = ""
            Instance.new("UICorner", Trk).CornerRadius = UDim.new(1,0)
            local Fill = Instance.new("Frame", Trk); Fill.Size = UDim2.new((cDef-cMin)/(cMax-cMin), 0, 1, 0); Fill.BackgroundColor3 = ACCENT_BLUE
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

            local dg = false
            local function RefreshDrag(i)
                local p = math.clamp((i.Position.X - Trk.AbsolutePosition.X)/Trk.AbsoluteSize.X, 0, 1)
                local math_v = math.floor((cMin + (cMax-cMin) * p)/cStep + 0.5) * cStep
                local cur = math.clamp(math_v, cMin, cMax)
                Fill.Size = UDim2.new((cur - cMin)/(cMax - cMin), 0, 1, 0); VL.Text = tostring(cur)
                if sc.Callback then sc.Callback(cur) end
            end

            Trk.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; RefreshDrag(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then RefreshDrag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end end)
            table.insert(GLOBAL_CARDS, {Instance = Card, Parent = Page})
            return Card
        end

        return CustomTabAPI
    end
    return Window
end
return WindUI