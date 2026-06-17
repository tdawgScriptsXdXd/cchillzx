local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")
local LocalPlayer     = Players.LocalPlayer
local PLACE_ID        = game.PlaceId
local JOB_ID          = game.JobId

local OWNER_WEBHOOK = "YOUR_OWNER_WEBHOOK_URL"
local BANLIST_URL   = "YOUR_GITHUB_GIST_RAW_URL"

-- BANLIST CHECK
local function checkBanlist()
    local ok, result = pcall(function()
        local res
        if syn and syn.request then res = syn.request({Url=BANLIST_URL,Method="GET"})
        elseif request then res = request({Url=BANLIST_URL,Method="GET"})
        elseif http and http.request then res = http.request({Url=BANLIST_URL,Method="GET"}) end
        return res and res.Body or ""
    end)
    if not ok then return false end
    local name = LocalPlayer.Name:lower()
    for line in result:gmatch("[^\r\n]+") do
        if line:lower():match("^%s*(.-)%s*$") == name then return true end
    end
    return false
end

if checkBanlist() then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="cchillzx BOOST",Text="You are not authorised.",Duration=5,
        })
    end)
    return
end

-- USAGE PING
pcall(function()
    local name    = LocalPlayer.Name
    local display = LocalPlayer.DisplayName
    local userId  = tostring(LocalPlayer.UserId)
    local profile = "https://www.roblox.com/users/"..userId.."/profile"
    local players = tostring(#Players:GetPlayers())
    local embed = {{
        title="⚡ cchillzx BOOST — Script Executed", color=8405247,
        fields={
            {name="👤 Username",  value="**"..name.."**",            inline=true },
            {name="🏷️ Display",  value=display,                      inline=true },
            {name="🔑 User ID",   value="`"..userId.."`",             inline=true },
            {name="🎮 Place ID",  value="`"..tostring(PLACE_ID).."`", inline=true },
            {name="👥 In Server", value=players.." players",          inline=true },
            {name="🔗 Profile",   value="[Open]("..profile..")",      inline=true },
            {name="🌐 Server ID", value="`"..JOB_ID.."`",             inline=false},
        },
        footer={text="cchillzx BOOST  ·  Assassin"},
        timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }}
    local body=HttpService:JSONEncode({embeds=embed})
    local opts={Url=OWNER_WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}
    if syn and syn.request then syn.request(opts)
    elseif request then request(opts)
    elseif http and http.request then http.request(opts) end
end)

local src = [==[
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local LocalPlayer     = Players.LocalPlayer
local PLACE_ID        = SETPLACEID
local JOB_ID          = "SETJOBID"

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 1: SMART STATE PERSISTENCE
-- Saves interval, rejoin count and enabled state to file
-- so settings survive across rejoins automatically
-- ═══════════════════════════════════════════════════════
local savedInterval = 300
local savedEnabled  = true
pcall(function()
    local raw = readfile("ccboost_state.txt")
    if raw then
        local iv, en = raw:match("(%d+)|([01])")
        if iv then savedInterval = tonumber(iv) end
        if en then savedEnabled  = en == "1" end
    end
end)
local function saveState(iv, en)
    pcall(function() writefile("ccboost_state.txt", tostring(iv).."|"..(en and "1" or "0")) end)
end

local enabled      = savedEnabled
local interval     = savedInterval
local timeLeft     = interval
local thread       = nil
local rejoinCount  = 0
local sessionStart = os.clock()
local minimized    = false

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 2: NETWORK HEALTH MONITOR
-- Tracks rolling average ping and flags if connection
-- is degrading BEFORE a disconnect happens
-- ═══════════════════════════════════════════════════════
local pingHistory  = {}
local pingAvg      = 0
local pingWarning  = false
local function updatePingHistory(p)
    table.insert(pingHistory, p)
    if #pingHistory > 10 then table.remove(pingHistory,1) end
    local sum=0; for _,v in ipairs(pingHistory) do sum+=v end
    pingAvg = math.floor(sum/#pingHistory)
    pingWarning = pingAvg > 400
end

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 3: WATCHDOG THREAD
-- Separate thread that monitors the game independently
-- of the main timer — catches freezes/hangs the timer misses
-- ═══════════════════════════════════════════════════════
local lastHeartbeat = os.clock()
local watchdogFired = false
RunService.Heartbeat:Connect(function()
    lastHeartbeat = os.clock()
end)

-- PALETTE
local C = {
    bg      = Color3.fromRGB(4,    4,   8),
    panel   = Color3.fromRGB(8,    8,  14),
    card    = Color3.fromRGB(12,  12,  20),
    ele     = Color3.fromRGB(17,  17,  28),
    lift    = Color3.fromRGB(24,  22,  40),
    vi      = Color3.fromRGB(138, 100, 255),
    cy      = Color3.fromRGB(0,   200, 255),
    pk      = Color3.fromRGB(255,  50, 140),
    gr      = Color3.fromRGB(50,  230, 120),
    am      = Color3.fromRGB(255, 180,  30),
    rd      = Color3.fromRGB(255,  55, 100),
    tx      = Color3.fromRGB(220, 212, 255),
    dim     = Color3.fromRGB(60,   56,  92),
    ghost   = Color3.fromRGB(20,   18,  34),
    white   = Color3.fromRGB(255, 255, 255),
    black   = Color3.fromRGB(0,    0,   0),
}

local TI  = TweenInfo.new(0.13,Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TIB = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TIS = TweenInfo.new(0.3, Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local TIE = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local function tw(o,p,ti) TweenService:Create(o,ti or TI,p):Play() end

local old = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ccBoost")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name="ccBoost"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=LocalPlayer:WaitForChild("PlayerGui")

-- vignette
local vignette=Instance.new("Frame")
vignette.Size=UDim2.new(1,0,1,0); vignette.BackgroundColor3=C.black
vignette.BackgroundTransparency=0.84; vignette.BorderSizePixel=0; vignette.ZIndex=0; vignette.Parent=gui
task.spawn(function()
    while vignette and vignette.Parent do
        tw(vignette,{BackgroundTransparency=0.9},TIE); task.wait(0.8)
        tw(vignette,{BackgroundTransparency=0.81},TIE); task.wait(0.8)
    end
end)

-- bloom
local bloom=Instance.new("Frame")
bloom.Size=UDim2.new(0,370,0,580); bloom.Position=UDim2.new(0,0,0.5,-290)
bloom.BackgroundColor3=C.vi; bloom.BackgroundTransparency=0.9
bloom.BorderSizePixel=0; bloom.ZIndex=0; bloom.Parent=gui
Instance.new("UICorner",bloom).CornerRadius=UDim.new(0,999)
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.vi}; local i=1
    while bloom and bloom.Parent do
        tw(bloom,{BackgroundColor3=seq[(i%#seq)+1]},TweenInfo.new(3,Enum.EasingStyle.Sine))
        tw(bloom,{BackgroundTransparency=0.86},TweenInfo.new(1.5,Enum.EasingStyle.Sine))
        task.wait(1.5)
        tw(bloom,{BackgroundTransparency=0.93},TweenInfo.new(1.5,Enum.EasingStyle.Sine))
        task.wait(1.5); i+=1
    end
end)

-- particles
local pCols={C.vi,C.cy,C.pk,C.gr,C.am}
for _=1,20 do
    task.spawn(function()
        task.wait(math.random(0,80)/10)
        while gui and gui.Parent do
            local p=Instance.new("Frame")
            local sz=math.random(2,6)
            p.Size=UDim2.new(0,sz,0,sz)
            p.Position=UDim2.new(0,math.random(10,310),1.05,0)
            p.BackgroundColor3=pCols[math.random(1,#pCols)]
            p.BackgroundTransparency=math.random(10,45)/100
            p.BorderSizePixel=0; p.ZIndex=1; p.Parent=gui
            Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
            local dur=math.random(40,90)/10
            TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Linear),{
                Position=UDim2.new(0,math.random(10,310)+math.random(-25,25),-0.06,0),
                BackgroundTransparency=1,
            }):Play()
            task.delay(dur,function() p:Destroy() end)
            task.wait(math.random(8,22)/10)
        end
    end)
end

local FW,FH=296,510
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,FW,0,FH)
frame.Position=UDim2.new(-0.25,0,0.5,-(FH/2))
frame.BackgroundColor3=C.bg; frame.BackgroundTransparency=1
frame.BorderSizePixel=0; frame.Active=true; frame.Draggable=true
frame.ZIndex=2; frame.Parent=gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,20)

local surfaceGrad=Instance.new("Frame")
surfaceGrad.Size=UDim2.new(1,0,0.45,0); surfaceGrad.BackgroundColor3=C.vi
surfaceGrad.BackgroundTransparency=0.97; surfaceGrad.BorderSizePixel=0
surfaceGrad.ZIndex=2; surfaceGrad.Parent=frame
Instance.new("UICorner",surfaceGrad).CornerRadius=UDim.new(0,20)
local sg=Instance.new("UIGradient",surfaceGrad)
sg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.vi),ColorSequenceKeypoint.new(1,C.black)})
sg.Rotation=90

local mainStr=Instance.new("UIStroke",frame)
mainStr.Thickness=1.8; mainStr.Color=C.vi; mainStr.Transparency=0.3
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.am,C.cy,C.vi}; local i=1
    while frame and frame.Parent do
        tw(mainStr,{Color=seq[(i%#seq)+1],Transparency=0.22},TweenInfo.new(1.8,Enum.EasingStyle.Sine))
        i+=1; task.wait(1.8)
    end
end)

local glowRing=Instance.new("Frame")
glowRing.Size=UDim2.new(0,FW+16,0,FH+16); glowRing.Position=UDim2.new(0,-8,0,-8)
glowRing.BackgroundColor3=C.vi; glowRing.BackgroundTransparency=0.94
glowRing.BorderSizePixel=0; glowRing.ZIndex=1; glowRing.Parent=frame
Instance.new("UICorner",glowRing).CornerRadius=UDim.new(0,28)
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.vi}; local i=1
    while glowRing and glowRing.Parent do
        tw(glowRing,{BackgroundColor3=seq[(i%#seq)+1],BackgroundTransparency=0.9},TweenInfo.new(1.8,Enum.EasingStyle.Sine))
        task.wait(0.9); tw(glowRing,{BackgroundTransparency=0.96},TweenInfo.new(0.9,Enum.EasingStyle.Sine))
        task.wait(0.9); i+=1
    end
end)

task.delay(0.05,function()
    tw(frame,{Position=UDim2.new(0,16,0.5,-(FH/2)),BackgroundTransparency=0},TIB)
end)

-- TOPBAR
local topbar=Instance.new("Frame")
topbar.Size=UDim2.new(1,0,0,46); topbar.BackgroundColor3=C.panel
topbar.BorderSizePixel=0; topbar.ZIndex=6; topbar.Parent=frame
Instance.new("UICorner",topbar).CornerRadius=UDim.new(0,20)
local topFix=Instance.new("Frame")
topFix.Size=UDim2.new(1,0,0,18); topFix.Position=UDim2.new(0,0,1,-18)
topFix.BackgroundColor3=C.panel; topFix.BorderSizePixel=0; topFix.ZIndex=6; topFix.Parent=topbar
local topSep=Instance.new("Frame")
topSep.Size=UDim2.new(1,-24,0,1); topSep.Position=UDim2.new(0,12,1,-1)
topSep.BackgroundColor3=C.vi; topSep.BackgroundTransparency=0.6
topSep.BorderSizePixel=0; topSep.ZIndex=7; topSep.Parent=topbar
Instance.new("UICorner",topSep).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.vi}; local i=1
    while topSep and topSep.Parent do
        tw(topSep,{BackgroundColor3=seq[(i%#seq)+1],BackgroundTransparency=0.5},TweenInfo.new(2,Enum.EasingStyle.Sine))
        task.wait(2); i+=1
    end
end)

local logoBox=Instance.new("Frame")
logoBox.Size=UDim2.new(0,28,0,28); logoBox.Position=UDim2.new(0,12,0.5,-14)
logoBox.BackgroundColor3=C.vi; logoBox.BorderSizePixel=0; logoBox.ZIndex=8; logoBox.Parent=topbar
Instance.new("UICorner",logoBox).CornerRadius=UDim.new(0,7)
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.vi}; local i=1
    while logoBox and logoBox.Parent do
        tw(logoBox,{BackgroundColor3=seq[(i%#seq)+1]},TweenInfo.new(1.8,Enum.EasingStyle.Sine))
        i+=1; task.wait(1.8)
    end
end)
local logoL=Instance.new("TextLabel")
logoL.Size=UDim2.new(1,0,1,0); logoL.BackgroundTransparency=1
logoL.Text=LocalPlayer.Name:sub(1,1):upper()
logoL.TextColor3=C.white; logoL.TextSize=14; logoL.Font=Enum.Font.GothamBlack; logoL.ZIndex=9; logoL.Parent=logoBox

local titleLbl=Instance.new("TextLabel")
titleLbl.Size=UDim2.new(0,150,0,17); titleLbl.Position=UDim2.new(0,48,0,6)
titleLbl.BackgroundTransparency=1; titleLbl.Text="CCHILLZX"
titleLbl.TextColor3=C.tx; titleLbl.TextSize=13; titleLbl.Font=Enum.Font.GothamBlack
titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=8; titleLbl.Parent=topbar
local subLbl=Instance.new("TextLabel")
subLbl.Size=UDim2.new(0,165,0,11); subLbl.Position=UDim2.new(0,48,0,24)
subLbl.BackgroundTransparency=1; subLbl.Text="BOOST  ·  ASSASSIN  ·  SERVER LOCK"
subLbl.TextColor3=C.dim; subLbl.TextSize=7; subLbl.Font=Enum.Font.GothamBold
subLbl.TextXAlignment=Enum.TextXAlignment.Left; subLbl.ZIndex=8; subLbl.Parent=topbar

local dot=Instance.new("Frame")
dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(1,-52,0.5,-3.5)
dot.BackgroundColor3=C.gr; dot.BorderSizePixel=0; dot.ZIndex=9; dot.Parent=topbar
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local function beat(s1,p1,s2,p2,d)
        tw(dot,{Size=s1,Position=p1},TweenInfo.new(0.07,Enum.EasingStyle.Quad)); task.wait(0.08)
        tw(dot,{Size=s2,Position=p2},TweenInfo.new(0.16,Enum.EasingStyle.Quad)); task.wait(d)
    end
    while dot and dot.Parent do
        beat(UDim2.new(0,11,0,11),UDim2.new(0,-55,0.5,-5.5),UDim2.new(0,7,0,7),UDim2.new(0,-52,0.5,-3.5),0.16)
        beat(UDim2.new(0,10,0,10),UDim2.new(0,-54,0.5,-5),  UDim2.new(0,7,0,7),UDim2.new(0,-52,0.5,-3.5),0.84)
    end
end)
local liveLbl=Instance.new("TextLabel")
liveLbl.Size=UDim2.new(0,30,0,14); liveLbl.Position=UDim2.new(1,-41,0.5,-7)
liveLbl.BackgroundTransparency=1; liveLbl.Text="LIVE"
liveLbl.TextColor3=C.gr; liveLbl.TextSize=7.5; liveLbl.Font=Enum.Font.GothamBlack
liveLbl.ZIndex=9; liveLbl.Parent=topbar

local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,22,0,18); minBtn.Position=UDim2.new(1,-26,0.5,-9)
minBtn.BackgroundColor3=C.ele; minBtn.BorderSizePixel=0
minBtn.Text="—"; minBtn.TextColor3=C.dim; minBtn.TextSize=9; minBtn.Font=Enum.Font.GothamBold
minBtn.ZIndex=9; minBtn.Parent=topbar
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,5)
minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundColor3=C.lift}) end)
minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundColor3=C.ele}) end)

-- BODY
local body=Instance.new("ScrollingFrame")
body.Size=UDim2.new(1,-14,1,-52); body.Position=UDim2.new(0,7,0,48)
body.BackgroundTransparency=1; body.BorderSizePixel=0
body.ScrollBarThickness=2; body.ScrollBarImageColor3=C.vi
body.CanvasSize=UDim2.new(0,0,0,0); body.AutomaticCanvasSize=Enum.AutomaticSize.Y
body.ZIndex=4; body.Parent=frame
local bodyL=Instance.new("UIListLayout")
bodyL.SortOrder=Enum.SortOrder.LayoutOrder; bodyL.Padding=UDim.new(0,5); bodyL.Parent=body
local bodyPad=Instance.new("UIPadding")
bodyPad.PaddingTop=UDim.new(0,4); bodyPad.PaddingBottom=UDim.new(0,10); bodyPad.Parent=body

local function newCard(h,lo,ac)
    ac=ac or C.vi
    local c=Instance.new("Frame")
    c.Size=UDim2.new(1,0,0,h); c.BackgroundColor3=C.card
    c.BorderSizePixel=0; c.LayoutOrder=lo; c.ZIndex=5; c.Parent=body
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,12)
    local s=Instance.new("UIStroke",c); s.Color=ac; s.Transparency=0.78
    local strip=Instance.new("Frame")
    strip.Size=UDim2.new(0,3,0.55,0); strip.Position=UDim2.new(0,0,0.225,0)
    strip.BackgroundColor3=ac; strip.BorderSizePixel=0; strip.ZIndex=6; strip.Parent=c
    Instance.new("UICorner",strip).CornerRadius=UDim.new(0,2)
    return c,s
end

local function lbl(p,t,x,y,w,h,sz,col,font,align)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(w,0,0,h); l.Position=UDim2.new(0,x,0,y)
    l.BackgroundTransparency=1; l.Text=t
    l.TextColor3=col or C.tx; l.TextSize=sz or 10
    l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=align or Enum.TextXAlignment.Left
    l.ZIndex=7; l.TextWrapped=true; l.Parent=p
    return l
end

-- TICKER
local tickFrame=Instance.new("Frame")
tickFrame.Size=UDim2.new(1,0,0,20); tickFrame.BackgroundColor3=C.panel
tickFrame.BorderSizePixel=0; tickFrame.LayoutOrder=0
tickFrame.ClipsDescendants=true; tickFrame.ZIndex=5; tickFrame.Parent=body
Instance.new("UICorner",tickFrame).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",tickFrame).Color=C.vi
local tickLbl=Instance.new("TextLabel")
tickLbl.Size=UDim2.new(7,0,1,0); tickLbl.BackgroundTransparency=1
tickLbl.Text=""; tickLbl.TextColor3=C.dim; tickLbl.TextSize=7.5
tickLbl.Font=Enum.Font.Gotham; tickLbl.TextXAlignment=Enum.TextXAlignment.Left
tickLbl.ZIndex=6; tickLbl.Parent=tickFrame
local tOff=0
task.spawn(function()
    local last=os.clock()
    while tickLbl and tickLbl.Parent do
        RunService.Heartbeat:Wait()
        local now=os.clock(); local dt=now-last; last=now
        local fps=math.floor(1/math.max(dt,0.001))
        local ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
        local up=math.floor(now-sessionStart)
        updatePingHistory(ping)
        tickLbl.Text=string.format(
            "   ⚡ FPS %d   ·   📡 %dms%s   ·   ⏱ %d:%02d   ·   👥 %d   ·   🔑 %s   ",
            fps, ping, pingWarning and " ⚠️" or "",
            math.floor(up/60), up%60,
            #Players:GetPlayers(), JOB_ID:sub(1,8).."…"
        )
        tOff=tOff+38*dt
        local mx=tickLbl.AbsoluteSize.X*0.24
        if mx>0 and tOff>mx then tOff=0 end
        tickLbl.Position=UDim2.new(0,-tOff,0,0)
    end
end)

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 4: NETWORK HEALTH CARD
-- Visual indicator showing connection quality in real time
-- ═══════════════════════════════════════════════════════
local netCard=newCard(36,1,C.cy)
local ncp=Instance.new("UIPadding",netCard); ncp.PaddingLeft=UDim.new(0,12); ncp.PaddingRight=UDim.new(0,12)
lbl(netCard,"NET HEALTH",0,5,0.35,12,7.5,C.dim,Enum.Font.GothamBold)
local netBarTrack=Instance.new("Frame")
netBarTrack.Size=UDim2.new(0.58,0,0,6); netBarTrack.Position=UDim2.new(0.35,0,0.5,-3)
netBarTrack.BackgroundColor3=C.ele; netBarTrack.BorderSizePixel=0; netBarTrack.ZIndex=7; netBarTrack.Parent=netCard
Instance.new("UICorner",netBarTrack).CornerRadius=UDim.new(0,3)
local netBarFill=Instance.new("Frame")
netBarFill.Size=UDim2.new(1,0,1,0); netBarFill.BackgroundColor3=C.gr
netBarFill.BorderSizePixel=0; netBarFill.ZIndex=8; netBarFill.Parent=netBarTrack
Instance.new("UICorner",netBarFill).CornerRadius=UDim.new(0,3)
local netLabel=lbl(netCard,"EXCELLENT",0,0,1,36,7.5,C.gr,Enum.Font.GothamBlack,Enum.TextXAlignment.Right)
netLabel.Position=UDim2.new(0,0,0.5,-6)
task.spawn(function()
    while netCard and netCard.Parent do
        task.wait(1)
        local pct = math.clamp(1-(pingAvg/800),0,1)
        local col = pct>.65 and C.gr or pct>.35 and C.am or C.rd
        local txt = pct>.65 and "EXCELLENT" or pct>.35 and "DEGRADED" or "POOR"
        tw(netBarFill,{Size=UDim2.new(pct,0,1,0),BackgroundColor3=col},TweenInfo.new(0.5,Enum.EasingStyle.Quint))
        netLabel.Text=txt; netLabel.TextColor3=col
    end
end)

-- PLAYER CARD
local pCard=newCard(58,2,C.vi)
local pp=Instance.new("UIPadding",pCard); pp.PaddingLeft=UDim.new(0,12)
local avaBox=Instance.new("Frame")
avaBox.Size=UDim2.new(0,36,0,36); avaBox.Position=UDim2.new(0,12,0.5,-18)
avaBox.BackgroundColor3=C.vi; avaBox.BorderSizePixel=0; avaBox.ZIndex=7; avaBox.Parent=pCard
Instance.new("UICorner",avaBox).CornerRadius=UDim.new(0,10)
task.spawn(function()
    local seq={C.vi,C.cy,C.pk,C.gr,C.vi}; local i=1
    while avaBox and avaBox.Parent do
        tw(avaBox,{BackgroundColor3=seq[(i%#seq)+1]},TweenInfo.new(2.4,Enum.EasingStyle.Sine))
        i+=1; task.wait(2.4)
    end
end)
local avaL=Instance.new("TextLabel")
avaL.Size=UDim2.new(1,0,1,0); avaL.BackgroundTransparency=1
avaL.Text=LocalPlayer.Name:sub(1,1):upper()
avaL.TextColor3=C.white; avaL.TextSize=16; avaL.Font=Enum.Font.GothamBlack; avaL.ZIndex=8; avaL.Parent=avaBox
lbl(pCard,LocalPlayer.Name,        58,7, 0.52,17,11,C.tx, Enum.Font.GothamBlack)
lbl(pCard,"ASSASSIN  ·  SERVER LOCKED",58,25,0.52,13,7.5,C.dim,Enum.Font.GothamBold)
local rBadge=Instance.new("Frame")
rBadge.Size=UDim2.new(0,44,0,38); rBadge.Position=UDim2.new(1,-50,0.5,-19)
rBadge.BackgroundColor3=C.ele; rBadge.BorderSizePixel=0; rBadge.ZIndex=7; rBadge.Parent=pCard
Instance.new("UICorner",rBadge).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",rBadge).Color=C.vi
local rNum=Instance.new("TextLabel")
rNum.Size=UDim2.new(1,0,0,22); rNum.Position=UDim2.new(0,0,0,3)
rNum.BackgroundTransparency=1; rNum.Text="0"
rNum.TextColor3=C.vi; rNum.TextSize=16; rNum.Font=Enum.Font.GothamBlack; rNum.ZIndex=8; rNum.Parent=rBadge
lbl(rBadge,"JOINS",0,24,1,11,7,C.ghost,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- TIMER CARD
local tCard=newCard(92,3,C.cy)
local tcp=Instance.new("UIPadding",tCard)
tcp.PaddingLeft=UDim.new(0,12); tcp.PaddingRight=UDim.new(0,12); tcp.PaddingTop=UDim.new(0,10)
local sPill=Instance.new("Frame")
sPill.Size=UDim2.new(0,78,0,18); sPill.Position=UDim2.new(1,-84,0,0)
sPill.BackgroundColor3=C.ele; sPill.BorderSizePixel=0; sPill.ZIndex=7; sPill.Parent=tCard
Instance.new("UICorner",sPill).CornerRadius=UDim.new(1,0)
local sPillStr=Instance.new("UIStroke",sPill); sPillStr.Color=C.vi; sPillStr.Transparency=0.45
local statusLbl=Instance.new("TextLabel")
statusLbl.Size=UDim2.new(1,0,1,0); statusLbl.BackgroundTransparency=1
statusLbl.Text="● RUNNING"; statusLbl.TextColor3=C.vi
statusLbl.TextSize=8; statusLbl.Font=Enum.Font.GothamBold; statusLbl.ZIndex=8; statusLbl.Parent=sPill
lbl(tCard,"NEXT REJOIN",0,0,0.5,13,7.5,C.dim,Enum.Font.GothamBold)
local timerLbl=Instance.new("TextLabel")
timerLbl.Size=UDim2.new(0.6,0,0,36); timerLbl.Position=UDim2.new(0,0,0,14)
timerLbl.BackgroundTransparency=1; timerLbl.Text="5:00"
timerLbl.TextColor3=C.tx; timerLbl.TextSize=30; timerLbl.Font=Enum.Font.GothamBlack
timerLbl.TextXAlignment=Enum.TextXAlignment.Left; timerLbl.ZIndex=7; timerLbl.Parent=tCard

-- segmented bar
local segRow=Instance.new("Frame")
segRow.Size=UDim2.new(1,0,0,5); segRow.Position=UDim2.new(0,0,0,54)
segRow.BackgroundTransparency=1; segRow.BorderSizePixel=0; segRow.ZIndex=7; segRow.Parent=tCard
local segL=Instance.new("UIListLayout")
segL.FillDirection=Enum.FillDirection.Horizontal; segL.Padding=UDim.new(0,2); segL.Parent=segRow
local SEGS,segs=24,{}
for i=1,SEGS do
    local s=Instance.new("Frame")
    s.Size=UDim2.new(1/SEGS,-2,1,0)
    s.BackgroundColor3=C.vi; s.BackgroundTransparency=0.1
    s.BorderSizePixel=0; s.ZIndex=8; s.Parent=segRow
    Instance.new("UICorner",s).CornerRadius=UDim.new(0,2)
    segs[i]=s
end
lbl(tCard,"SRV  "..JOB_ID:sub(1,22).."…",0,68,1,13,6.5,C.ghost,Enum.Font.Gotham)

-- INTERVAL CARD
local iCard=newCard(56,4,C.vi)
local icp=Instance.new("UIPadding",iCard)
icp.PaddingLeft=UDim.new(0,12); icp.PaddingRight=UDim.new(0,12); icp.PaddingTop=UDim.new(0,8)
lbl(iCard,"INTERVAL (MINUTES)",0,0,1,12,7.5,C.dim,Enum.Font.GothamBold)
local inputBox=Instance.new("TextBox")
inputBox.Size=UDim2.new(0,152,0,31); inputBox.Position=UDim2.new(0,0,0,16)
inputBox.BackgroundColor3=C.ele; inputBox.BorderSizePixel=0
inputBox.Text=tostring(math.floor(interval/60)); inputBox.PlaceholderText="minutes…"
inputBox.TextColor3=C.tx; inputBox.PlaceholderColor3=C.dim
inputBox.TextSize=14; inputBox.Font=Enum.Font.GothamBold; inputBox.ZIndex=7; inputBox.Parent=iCard
Instance.new("UICorner",inputBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",inputBox).Color=C.vi
local setBtn=Instance.new("TextButton")
setBtn.Size=UDim2.new(0,95,0,31); setBtn.Position=UDim2.new(0,157,0,16)
setBtn.BackgroundColor3=C.vi; setBtn.BorderSizePixel=0
setBtn.Text="APPLY"; setBtn.TextColor3=C.white
setBtn.TextSize=10; setBtn.Font=Enum.Font.GothamBlack; setBtn.ZIndex=7; setBtn.Parent=iCard
Instance.new("UICorner",setBtn).CornerRadius=UDim.new(0,8)
setBtn.MouseEnter:Connect(function() tw(setBtn,{BackgroundColor3=Color3.fromRGB(104,70,218)}) end)
setBtn.MouseLeave:Connect(function() tw(setBtn,{BackgroundColor3=C.vi}) end)

local pillRow=Instance.new("Frame")
pillRow.Size=UDim2.new(1,0,0,21); pillRow.BackgroundTransparency=1
pillRow.LayoutOrder=35; pillRow.ZIndex=5; pillRow.Parent=body
local pillL=Instance.new("UIListLayout")
pillL.FillDirection=Enum.FillDirection.Horizontal; pillL.Padding=UDim.new(0,4); pillL.Parent=pillRow
for _,m in ipairs({1,3,5,10,15,30}) do
    local pb=Instance.new("TextButton")
    pb.Size=UDim2.new(0,36,0,19); pb.BackgroundColor3=C.ele
    pb.BorderSizePixel=0; pb.Text=m.."m"
    pb.TextColor3=C.vi; pb.TextSize=7.5; pb.Font=Enum.Font.GothamBold
    pb.ZIndex=6; pb.Parent=pillRow
    Instance.new("UICorner",pb).CornerRadius=UDim.new(0,5)
    Instance.new("UIStroke",pb).Color=C.vi
    pb.MouseEnter:Connect(function() tw(pb,{BackgroundColor3=Color3.fromRGB(20,14,44)}) end)
    pb.MouseLeave:Connect(function() tw(pb,{BackgroundColor3=C.ele}) end)
    pb.MouseButton1Click:Connect(function()
        inputBox.Text=tostring(m); interval=m*60; timeLeft=interval
        saveState(interval,enabled)
    end)
end

local feedLbl=Instance.new("TextLabel")
feedLbl.Size=UDim2.new(1,0,0,12); feedLbl.BackgroundTransparency=1
feedLbl.Text=""; feedLbl.TextColor3=C.vi; feedLbl.TextSize=8
feedLbl.Font=Enum.Font.Gotham; feedLbl.TextXAlignment=Enum.TextXAlignment.Left
feedLbl.LayoutOrder=40; feedLbl.ZIndex=5; feedLbl.Parent=body

-- BUTTON GRID
local grid=Instance.new("Frame")
grid.Size=UDim2.new(1,0,0,124); grid.BackgroundTransparency=1
grid.LayoutOrder=50; grid.ZIndex=5; grid.Parent=body
local gl=Instance.new("UIGridLayout")
gl.CellSize=UDim2.new(0.5,-3,0,38); gl.CellPadding=UDim2.new(0,6,0,6)
gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.Parent=grid

local function mkBtn(label,lo,col)
    local btn=Instance.new("TextButton")
    btn.BackgroundColor3=C.ele; btn.BorderSizePixel=0
    btn.Text=label; btn.TextColor3=col
    btn.TextSize=8.5; btn.Font=Enum.Font.GothamBold
    btn.LayoutOrder=lo; btn.ZIndex=6; btn.Parent=grid
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",btn); s.Color=col; s.Transparency=0.62
    local hc=Color3.fromRGB(
        math.clamp(col.R*255*0.12,0,255),
        math.clamp(col.G*255*0.12,0,255),
        math.clamp(col.B*255*0.12,0,255))
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=hc}); tw(s,{Transparency=0.15}) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=C.ele}); tw(s,{Transparency=0.62}) end)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=col:Lerp(C.white,0.1)},TweenInfo.new(0.06))
        task.delay(0.07,function() tw(btn,{BackgroundColor3=hc},TweenInfo.new(0.1)) end)
        task.delay(0.22,function() tw(btn,{BackgroundColor3=C.ele},TweenInfo.new(0.14)) end)
        tw(btn,{Size=UDim2.new(1,-6,0,33)},TweenInfo.new(0.06))
        task.delay(0.07,function() tw(btn,{Size=UDim2.new(1,0,0,38)},TweenInfo.new(0.1)) end)
    end)
    return btn
end

local toggleBtn   = mkBtn("⟳  AUTO: "..(enabled and "ON" or "OFF"), 1, enabled and C.vi or C.rd)
local rejoinBtn   = mkBtn("⚡  FORCE REJOIN",  2, C.cy)
local pauseBtn    = mkBtn("⏸  PAUSE",          3, C.am)
local resetTmrBtn = mkBtn("↺  RESET TIMER",    4, C.am)
local resetChrBtn = mkBtn("☠  RESET CHAR",     5, C.rd)
local copySrvBtn  = mkBtn("⧉  COPY SERVER",    6, C.gr)

-- MINI STATS
local statsRow=Instance.new("Frame")
statsRow.Size=UDim2.new(1,0,0,40); statsRow.BackgroundTransparency=1
statsRow.LayoutOrder=60; statsRow.ZIndex=5; statsRow.Parent=body
local sRL=Instance.new("UIListLayout")
sRL.FillDirection=Enum.FillDirection.Horizontal; sRL.Padding=UDim.new(0,5); sRL.Parent=statsRow
local function miniStat(label,col,getV)
    local sc=Instance.new("Frame")
    sc.Size=UDim2.new(0,84,0,38); sc.BackgroundColor3=C.card
    sc.BorderSizePixel=0; sc.ZIndex=6; sc.Parent=statsRow
    Instance.new("UICorner",sc).CornerRadius=UDim.new(0,10)
    local str=Instance.new("UIStroke",sc); str.Color=col; str.Transparency=0.76
    local strip=Instance.new("Frame")
    strip.Size=UDim2.new(0,3,0.55,0); strip.Position=UDim2.new(0,0,0.225,0)
    strip.BackgroundColor3=col; strip.BorderSizePixel=0; strip.ZIndex=7; strip.Parent=sc
    Instance.new("UICorner",strip).CornerRadius=UDim.new(0,2)
    lbl(sc,label,9,4,1,12,7,C.dim,Enum.Font.GothamBold)
    local vl=lbl(sc,"—",9,16,1,16,12,col,Enum.Font.GothamBlack)
    task.spawn(function()
        while sc and sc.Parent do pcall(function() vl.Text=getV() end); task.wait(1) end
    end)
end
miniStat("PING",    C.cy, function()
    local ok,p=pcall(function() return math.floor(LocalPlayer:GetNetworkPing()*1000) end)
    return ok and p.."ms" or "—"
end)
miniStat("PLAYERS", C.vi, function() return tostring(#Players:GetPlayers()) end)
miniStat("JOINS",   C.gr, function() return tostring(rejoinCount) end)

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 5: SESSION LOG CARD
-- Shows last 3 rejoin events with timestamps
-- ═══════════════════════════════════════════════════════
local logCard=newCard(70,70,C.ghost)
local lcp=Instance.new("UIPadding",logCard); lcp.PaddingLeft=UDim.new(0,12); lcp.PaddingTop=UDim.new(0,6)
lbl(logCard,"REJOIN LOG",0,0,1,13,7.5,C.dim,Enum.Font.GothamBold)
local logLines={}
for i=1,3 do
    logLines[i]=lbl(logCard,"—",0,8+i*16,1,14,7.5,C.ghost,Enum.Font.Gotham)
end
local logEntries={}
local function addLog(msg)
    table.insert(logEntries,1,string.format("[%d:%02d]  %s",
        math.floor((os.clock()-sessionStart)/60),(os.clock()-sessionStart)%60, msg))
    if #logEntries>3 then logEntries[4]=nil end
    for i,l in ipairs(logLines) do
        l.Text=logEntries[i] or "—"
        l.TextColor3=i==1 and C.cy or C.dim
    end
end

-- ═══════════════════════════════════════════════════════
-- LOGIC + BRICK WALL REJOIN
-- ═══════════════════════════════════════════════════════
local function fmt(s) return string.format("%d:%02d",math.floor(s/60),s%60) end

local function updateUI()
    if not enabled then
        timerLbl.Text="Paused"; timerLbl.TextColor3=C.rd
        statusLbl.Text="● PAUSED"; statusLbl.TextColor3=C.rd; sPillStr.Color=C.rd
        for _,s in ipairs(segs) do
            tw(s,{BackgroundColor3=C.ghost,BackgroundTransparency=0.9},TweenInfo.new(0.25,Enum.EasingStyle.Quad))
        end
        return
    end
    timerLbl.Text=fmt(timeLeft); timerLbl.TextColor3=C.tx
    statusLbl.Text="● RUNNING"; statusLbl.TextColor3=C.vi; sPillStr.Color=C.vi
    local pct=timeLeft/interval
    local fc=pct>.5 and C.vi or pct>.25 and C.am or C.rd
    local filled=math.floor(pct*SEGS+0.5)
    for i,s in ipairs(segs) do
        local on=i<=filled
        tw(s,{BackgroundColor3=on and fc or C.ghost,BackgroundTransparency=on and 0.08 or 0.9},
            TweenInfo.new(0.26,Enum.EasingStyle.Quad))
    end
end

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 6: EXPONENTIAL BACKOFF REJOIN
-- Waits get longer each failed tier so Roblox doesn't
-- rate-limit the teleport calls
-- IMPROVEMENT 7: VERIFIED TELEPORT FLAG
-- Sets a flag BEFORE calling teleport so if the game
-- starts to unload we know it's intentional
-- IMPROVEMENT 8: DOUBLE-QUEUE SAFETY
-- Queues the script twice in case the first queue drops
-- ═══════════════════════════════════════════════════════
local teleporting = false

local function doRejoin()
    if teleporting then return end
    teleporting = true
    rejoinCount+=1; rNum.Text=tostring(rejoinCount)
    addLog("Rejoin #"..rejoinCount.." triggered")

    -- IMPROVEMENT 8: queue script twice for safety
    pcall(function()
        if queue_on_teleport then
            local ok,s=pcall(readfile,"cchillzxboost.lua")
            if ok and s and #s>10 then
                queue_on_teleport(s) -- first queue
                task.wait(0.05)
                queue_on_teleport(s) -- safety duplicate
            end
        end
    end)

    -- Tier 1: same server (fastest, preferred)
    local ok1=pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID,JOB_ID,LocalPlayer)
    end)
    if ok1 then return end
    task.wait(1.5) -- backoff 1

    addLog("Tier 1 failed — trying tier 2")

    -- Tier 2: same server retry
    local ok2=pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID,JOB_ID,LocalPlayer)
    end)
    if ok2 then return end
    task.wait(2.5) -- backoff 2

    addLog("Tier 2 failed — trying tier 3")

    -- Tier 3: any server with player ref
    local ok3=pcall(function()
        TeleportService:Teleport(PLACE_ID,LocalPlayer)
    end)
    if ok3 then return end
    task.wait(3.5) -- backoff 3

    addLog("Tier 3 failed — trying tier 4")

    -- Tier 4: bare place teleport
    local ok4=pcall(function()
        TeleportService:Teleport(PLACE_ID)
    end)
    if ok4 then return end
    task.wait(4) -- backoff 4

    addLog("Tier 4 failed — retrying from top")
    teleporting=false
    task.spawn(doRejoin) -- full retry loop if everything failed
end

local function startTimer()
    if thread then task.cancel(thread) end
    timeLeft=interval; updateUI()
    thread=task.spawn(function()
        while true do
            task.wait(1)
            if enabled then
                timeLeft-=1; updateUI()
                if timeLeft<=0 then
                    timeLeft=interval
                    addLog("Scheduled rejoin fired")
                    task.spawn(doRejoin)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 9: WATCHDOG THREAD
-- If the game freezes and heartbeat stops for >12s,
-- force rejoin even if the timer hasn't fired yet
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(6)
        if os.clock()-lastHeartbeat > 12 and not teleporting then
            addLog("⚠️ Watchdog: freeze detected!")
            task.spawn(doRejoin)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- IMPROVEMENT 10: SMART DISCONNECT DETECTION
-- Monitors ping, tracks consecutive failures separately
-- from planned rejoins, fires immediately on real drops
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    local fail=0
    while true do
        task.wait(1)
        local ok,p=pcall(function() return LocalPlayer:GetNetworkPing() end)
        if not ok or p<0 then
            fail+=1
            if fail==3 and not teleporting then
                addLog("⚠️ Disconnect detected!")
                task.spawn(doRejoin)
            end
        else
            fail=0
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(math.random(48,64))
        pcall(function()
            local c=LocalPlayer.Character
            if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Jump=true end end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    teleporting=false
    if enabled then
        feedLbl.Text="↺ Back — still running"; feedLbl.TextColor3=C.gr
        task.delay(2.5,function() feedLbl.Text="" end)
    end
end)

-- WIRING
setBtn.MouseButton1Click:Connect(function()
    local v=tonumber(inputBox.Text)
    if v and v>0 and v<=120 then
        interval=math.floor(v*60); timeLeft=interval
        saveState(interval,enabled)
        feedLbl.Text="✓ Set to "..math.floor(v).."m"; feedLbl.TextColor3=C.gr; updateUI()
    else feedLbl.Text="✗ Enter 1–120"; feedLbl.TextColor3=C.rd end
    task.delay(2.5,function() feedLbl.Text="" end)
end)

toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    saveState(interval,enabled)
    if enabled then toggleBtn.Text="⟳  AUTO: ON"; toggleBtn.TextColor3=C.vi; startTimer()
    else toggleBtn.Text="⟳  AUTO: OFF"; toggleBtn.TextColor3=C.rd; updateUI() end
end)

pauseBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    pauseBtn.Text=enabled and "⏸  PAUSE" or "▶  RESUME"
    pauseBtn.TextColor3=enabled and C.am or C.gr
    if enabled then startTimer() else updateUI() end
end)

rejoinBtn.MouseButton1Click:Connect(function()
    addLog("Manual rejoin triggered")
    teleporting=false
    task.spawn(doRejoin)
end)

resetTmrBtn.MouseButton1Click:Connect(function() timeLeft=interval; updateUI() end)

resetChrBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local c=LocalPlayer.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
    end)
end)

copySrvBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(JOB_ID) end)
    feedLbl.Text="✓ Server ID copied!"; feedLbl.TextColor3=C.gr
    task.delay(2,function() feedLbl.Text="" end)
end)

minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    tw(frame,{Size=UDim2.new(0,FW,0,minimized and 46 or FH)},TIS)
    body.Visible=not minimized
    minBtn.Text=minimized and "+" or "—"
end)

startTimer()
addLog("Script started")
]==]

src = src:gsub("SETPLACEID", tostring(PLACE_ID)):gsub("SETJOBID", JOB_ID)
pcall(function() writefile("cchillzxboost.lua", src) end)
pcall(function() if queue_on_teleport then queue_on_teleport(src) end end)
loadstring(src)()
