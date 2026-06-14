local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")
local LocalPlayer     = Players.LocalPlayer
local PLACE_ID        = game.PlaceId
local JOB_ID          = game.JobId

-- ══════════════════════════════════════════════════════
-- OWNER USAGE PING
-- Sends to your Discord when someone runs the script
-- ══════════════════════════════════════════════════════
local OWNER_WEBHOOK = "https://discord.com/api/webhooks/1514824241298800834/fAc5uBTAqhLhYDaz_kMuHX-lumH_8skh6yXi1HqavEdy_gSR3QTyNUOTCV1-29r1FEHG"

pcall(function()
    local name    = LocalPlayer.Name
    local display = LocalPlayer.DisplayName
    local userId  = tostring(LocalPlayer.UserId)
    local profile = "https://www.roblox.com/users/" .. userId .. "/profile"
    local players = tostring(#Players:GetPlayers())

    local embed = {
        {
            title = "⚡ cchillzx BOOST — Script Executed",
            color = 8405247,
            fields = {
                { name = "👤 Username",   value = "**"..name.."**",       inline = true  },
                { name = "🏷️ Display",   value = display,                 inline = true  },
                { name = "🔑 User ID",    value = "`"..userId.."`",        inline = true  },
                { name = "🎮 Place ID",   value = "`"..tostring(PLACE_ID).."`", inline = true },
                { name = "👥 In Server",  value = players.." players",     inline = true  },
                { name = "🔗 Profile",    value = "[Open]("..profile..")", inline = true  },
                { name = "🌐 Server ID",  value = "`"..JOB_ID.."`",        inline = false },
            },
            footer    = { text = "cchillzx BOOST  ·  Assassin" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
    }

    local body = HttpService:JSONEncode({ embeds = embed })
    local opts = {
        Url     = OWNER_WEBHOOK,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    }
    if syn and syn.request then syn.request(opts)
    elseif request then request(opts)
    elseif http and http.request then http.request(opts) end
end)

-- ══════════════════════════════════════════════════════
-- EMBEDDED SOURCE (stamped + saved for queue_on_teleport)
-- ══════════════════════════════════════════════════════
local src = [==[
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local LocalPlayer     = Players.LocalPlayer
local PLACE_ID        = SETPLACEID
local JOB_ID          = "SETJOBID"

local enabled      = true
local interval     = 300
local timeLeft     = interval
local thread       = nil
local rejoinCount  = 0
local sessionStart = os.clock()
local minimized    = false

local P = {
    bg      = Color3.fromRGB(6,   6,  10),
    surface = Color3.fromRGB(11,  11, 18),
    card    = Color3.fromRGB(15,  15, 24),
    ele     = Color3.fromRGB(20,  20, 32),
    hi      = Color3.fromRGB(28,  26, 46),
    vi      = Color3.fromRGB(130, 95, 255),
    cy      = Color3.fromRGB(65,  185,255),
    pk      = Color3.fromRGB(255, 72, 148),
    gr      = Color3.fromRGB(68,  222,118),
    am      = Color3.fromRGB(255, 165, 42),
    rd      = Color3.fromRGB(255, 72, 108),
    tx      = Color3.fromRGB(210, 200,248),
    dim     = Color3.fromRGB(58,  54,  88),
    ghost   = Color3.fromRGB(30,  28,  50),
    white   = Color3.fromRGB(255, 255,255),
}

local TI  = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TIB = TweenInfo.new(0.48, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TIS = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local function tw(o,p,ti) TweenService:Create(o,ti or TI,p):Play() end

local old = LocalPlayer:FindFirstChild("PlayerGui")
    and LocalPlayer.PlayerGui:FindFirstChild("ccBoost")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name           = "ccBoost"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

-- EFFECT 1: AMBIENT BLOOM
local bloom = Instance.new("Frame")
bloom.Size = UDim2.new(0,340,0,520)
bloom.Position = UDim2.new(0,4,0.5,-260)
bloom.BackgroundColor3 = P.vi
bloom.BackgroundTransparency = 0.91
bloom.BorderSizePixel = 0
bloom.ZIndex = 0
bloom.Parent = gui
Instance.new("UICorner",bloom).CornerRadius = UDim.new(0,50)
task.spawn(function()
    local seq={P.vi,P.cy,P.pk,P.gr,P.vi}; local i=1
    while bloom and bloom.Parent do
        TweenService:Create(bloom,TweenInfo.new(2.8,Enum.EasingStyle.Sine),{BackgroundColor3=seq[(i%#seq)+1]}):Play()
        i+=1; task.wait(2.8)
    end
end)

-- EFFECT 2: RISING PARTICLES
local pCols={P.vi,P.cy,P.pk,P.gr,P.am}
for _=1,16 do
    task.spawn(function()
        task.wait(math.random(0,60)/10)
        while gui and gui.Parent do
            local p=Instance.new("Frame")
            local sz=math.random(2,5)
            p.Size=UDim2.new(0,sz,0,sz)
            p.Position=UDim2.new(0,math.random(18,300),1.04,0)
            p.BackgroundColor3=pCols[math.random(1,#pCols)]
            p.BackgroundTransparency=math.random(15,50)/100
            p.BorderSizePixel=0 p.ZIndex=1 p.Parent=gui
            Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
            local dur=math.random(38,88)/10
            TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Linear),{
                Position=UDim2.new(0,math.random(18,300)+math.random(-20,20),-0.05,0),
                BackgroundTransparency=1,
            }):Play()
            task.delay(dur,function() p:Destroy() end)
            task.wait(math.random(10,28)/10)
        end
    end)
end

local FW,FH=288,422
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,FW,0,FH)
frame.Position=UDim2.new(-0.2,0,0.5,-(FH/2))
frame.BackgroundColor3=P.bg
frame.BackgroundTransparency=1
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.ZIndex=2
frame.Parent=gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,18)

-- EFFECT 3: CHROMATIC CYCLING BORDER
local mainStr=Instance.new("UIStroke",frame)
mainStr.Thickness=1.5; mainStr.Color=P.vi; mainStr.Transparency=0.35
task.spawn(function()
    local seq={P.vi,P.cy,P.pk,P.gr,P.am,P.cy,P.vi}; local i=1
    while frame and frame.Parent do
        tw(mainStr,{Color=seq[(i%#seq)+1],Transparency=0.28},TweenInfo.new(1.7,Enum.EasingStyle.Sine))
        i+=1; task.wait(1.7)
    end
end)

-- EFFECT 4: SPRING SLIDE-IN
task.delay(0.04,function()
    tw(frame,{Position=UDim2.new(0,18,0.5,-(FH/2)),BackgroundTransparency=0},TIB)
end)

local topbar=Instance.new("Frame")
topbar.Size=UDim2.new(1,0,0,42)
topbar.BackgroundColor3=P.surface
topbar.BorderSizePixel=0 topbar.ZIndex=5 topbar.Parent=frame
Instance.new("UICorner",topbar).CornerRadius=UDim.new(0,18)
local topFix=Instance.new("Frame")
topFix.Size=UDim2.new(1,0,0,16) topFix.Position=UDim2.new(0,0,1,-16)
topFix.BackgroundColor3=P.surface topFix.BorderSizePixel=0 topFix.ZIndex=5 topFix.Parent=topbar
local topSep=Instance.new("Frame")
topSep.Size=UDim2.new(1,-20,0,1) topSep.Position=UDim2.new(0,10,1,-1)
topSep.BackgroundColor3=P.vi topSep.BackgroundTransparency=0.65
topSep.BorderSizePixel=0 topSep.ZIndex=6 topSep.Parent=topbar
Instance.new("UICorner",topSep).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local seq={P.vi,P.cy,P.pk,P.vi}; local i=1
    while topSep and topSep.Parent do
        tw(topSep,{BackgroundColor3=seq[(i%#seq)+1]},TweenInfo.new(2.2,Enum.EasingStyle.Sine))
        i+=1; task.wait(2.2)
    end
end)

-- EFFECT 5: DUAL-BEAT HEARTBEAT DOT
local dot=Instance.new("Frame")
dot.Size=UDim2.new(0,8,0,8) dot.Position=UDim2.new(0,13,0.5,-4)
dot.BackgroundColor3=P.vi dot.BorderSizePixel=0 dot.ZIndex=8 dot.Parent=topbar
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local function beat(s1,p1,s2,p2,d)
        tw(dot,{Size=s1,Position=p1},TweenInfo.new(0.08,Enum.EasingStyle.Quad)); task.wait(0.09)
        tw(dot,{Size=s2,Position=p2},TweenInfo.new(0.18,Enum.EasingStyle.Quad)); task.wait(d)
    end
    while dot and dot.Parent do
        beat(UDim2.new(0,12,0,12),UDim2.new(0,11,0.5,-6),UDim2.new(0,8,0,8),UDim2.new(0,13,0.5,-4),0.18)
        beat(UDim2.new(0,11,0,11),UDim2.new(0,11.5,0.5,-5.5),UDim2.new(0,8,0,8),UDim2.new(0,13,0.5,-4),0.88)
    end
end)

local function mkTL(txt,y,sz,col,font)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0,155,0,sz+4) l.Position=UDim2.new(0,27,0,y)
    l.BackgroundTransparency=1 l.Text=txt l.TextColor3=col l.TextSize=sz
    l.Font=font or Enum.Font.GothamBlack
    l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=7 l.Parent=topbar
    return l
end
mkTL("CCHILLZX  BOOST",5,11,P.tx)
mkTL("ASSASSIN  ·  SERVER LOCK",22,7.5,P.dim,Enum.Font.GothamBold)

local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,24,0,20) minBtn.Position=UDim2.new(1,-30,0.5,-10)
minBtn.BackgroundColor3=P.ele minBtn.BorderSizePixel=0
minBtn.Text="—" minBtn.TextColor3=P.dim minBtn.TextSize=10 minBtn.Font=Enum.Font.GothamBold
minBtn.ZIndex=8 minBtn.Parent=topbar
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,6)
minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundColor3=P.hi}) end)
minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundColor3=P.ele}) end)

local body=Instance.new("ScrollingFrame")
body.Size=UDim2.new(1,-16,1,-48) body.Position=UDim2.new(0,8,0,44)
body.BackgroundTransparency=1 body.BorderSizePixel=0
body.ScrollBarThickness=2 body.ScrollBarImageColor3=P.vi
body.CanvasSize=UDim2.new(0,0,0,0) body.AutomaticCanvasSize=Enum.AutomaticSize.Y
body.ZIndex=4 body.Parent=frame
local bodyL=Instance.new("UIListLayout")
bodyL.SortOrder=Enum.SortOrder.LayoutOrder bodyL.Padding=UDim.new(0,6) bodyL.Parent=body
local bodyPad=Instance.new("UIPadding")
bodyPad.PaddingTop=UDim.new(0,4) bodyPad.PaddingBottom=UDim.new(0,10) bodyPad.Parent=body

local function newCard(h,lo,ac)
    ac=ac or P.vi
    local c=Instance.new("Frame")
    c.Size=UDim2.new(1,0,0,h) c.BackgroundColor3=P.card
    c.BorderSizePixel=0 c.LayoutOrder=lo c.ZIndex=5 c.Parent=body
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,11)
    local s=Instance.new("UIStroke",c); s.Color=ac; s.Transparency=0.78
    local strip=Instance.new("Frame")
    strip.Size=UDim2.new(0,3,0.56,0) strip.Position=UDim2.new(0,0,0.22,0)
    strip.BackgroundColor3=ac strip.BorderSizePixel=0 strip.ZIndex=6 strip.Parent=c
    Instance.new("UICorner",strip).CornerRadius=UDim.new(0,2)
    return c,s
end

local function lbl(p,t,x,y,w,h,sz,col,font,align)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(w,0,0,h) l.Position=UDim2.new(0,x,0,y)
    l.BackgroundTransparency=1 l.Text=t
    l.TextColor3=col or P.tx l.TextSize=sz or 10
    l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=align or Enum.TextXAlignment.Left
    l.ZIndex=7 l.TextWrapped=true l.Parent=p
    return l
end

-- SCROLLING TICKER
local tickFrame=Instance.new("Frame")
tickFrame.Size=UDim2.new(1,0,0,18) tickFrame.BackgroundColor3=P.surface
tickFrame.BorderSizePixel=0 tickFrame.LayoutOrder=0
tickFrame.ClipsDescendants=true tickFrame.ZIndex=5 tickFrame.Parent=body
Instance.new("UICorner",tickFrame).CornerRadius=UDim.new(0,7)
local tickStr=Instance.new("UIStroke",tickFrame); tickStr.Color=P.vi; tickStr.Transparency=0.8
local tickLbl=Instance.new("TextLabel")
tickLbl.Size=UDim2.new(5,0,1,0) tickLbl.BackgroundTransparency=1
tickLbl.Text="" tickLbl.TextColor3=P.dim tickLbl.TextSize=7.5
tickLbl.Font=Enum.Font.Gotham tickLbl.TextXAlignment=Enum.TextXAlignment.Left
tickLbl.ZIndex=6 tickLbl.Parent=tickFrame
local tOff=0
task.spawn(function()
    local last=os.clock()
    while tickLbl and tickLbl.Parent do
        RunService.Heartbeat:Wait()
        local now=os.clock(); local dt=now-last; last=now
        local fps=math.floor(1/math.max(dt,0.001))
        local ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
        local up=math.floor(now-sessionStart)
        tickLbl.Text=string.format(
            "   ⚡ FPS %d   ·   📡 %dms   ·   ⏱ %d:%02d   ·   🔑 %s   ",
            fps,ping,math.floor(up/60),up%60,JOB_ID:sub(1,10).."…"
        )
        tOff=tOff+36*dt
        local mx=tickLbl.AbsoluteSize.X*0.27
        if mx>0 and tOff>mx then tOff=0 end
        tickLbl.Position=UDim2.new(0,-tOff,0,0)
    end
end)

-- PLAYER CARD
local pCard=newCard(52,1)
local pp=Instance.new("UIPadding",pCard); pp.PaddingLeft=UDim.new(0,10)
local ava=Instance.new("Frame")
ava.Size=UDim2.new(0,32,0,32) ava.Position=UDim2.new(0,10,0.5,-16)
ava.BackgroundColor3=Color3.fromRGB(18,14,40) ava.BorderSizePixel=0 ava.ZIndex=7 ava.Parent=pCard
Instance.new("UICorner",ava).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",ava).Color=P.vi
local avaL=Instance.new("TextLabel")
avaL.Size=UDim2.new(1,0,1,0) avaL.BackgroundTransparency=1
avaL.Text=LocalPlayer.Name:sub(1,1):upper()
avaL.TextColor3=P.vi avaL.TextSize=15 avaL.Font=Enum.Font.GothamBlack avaL.ZIndex=8 avaL.Parent=ava
lbl(pCard,LocalPlayer.Name,50,7,0.55,15,10.5,P.tx,Enum.Font.GothamBlack)
lbl(pCard,"ASSASSIN  ·  SERVER LOCKED",50,23,0.55,12,7.5,P.dim,Enum.Font.GothamBold)

local rBadge=Instance.new("Frame")
rBadge.Size=UDim2.new(0,42,0,34) rBadge.Position=UDim2.new(1,-48,0.5,-17)
rBadge.BackgroundColor3=P.ele rBadge.BorderSizePixel=0 rBadge.ZIndex=7 rBadge.Parent=pCard
Instance.new("UICorner",rBadge).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",rBadge).Color=P.vi
local rNum=Instance.new("TextLabel")
rNum.Size=UDim2.new(1,0,0,20) rNum.Position=UDim2.new(0,0,0,3)
rNum.BackgroundTransparency=1 rNum.Text="0"
rNum.TextColor3=P.vi rNum.TextSize=15 rNum.Font=Enum.Font.GothamBlack rNum.ZIndex=8 rNum.Parent=rBadge
lbl(rBadge,"JOINS",0,22,1,10,7,P.ghost,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- TIMER CARD
local tCard,tStroke=newCard(82,2,P.cy)
local tcp=Instance.new("UIPadding",tCard)
tcp.PaddingLeft=UDim.new(0,12) tcp.PaddingRight=UDim.new(0,12) tcp.PaddingTop=UDim.new(0,9)

local sPill=Instance.new("Frame")
sPill.Size=UDim2.new(0,74,0,16) sPill.Position=UDim2.new(1,-80,0,0)
sPill.BackgroundColor3=P.ele sPill.BorderSizePixel=0 sPill.ZIndex=7 sPill.Parent=tCard
Instance.new("UICorner",sPill).CornerRadius=UDim.new(1,0)
local sPillStr=Instance.new("UIStroke",sPill); sPillStr.Color=P.vi; sPillStr.Transparency=0.48
local statusLbl=Instance.new("TextLabel")
statusLbl.Size=UDim2.new(1,0,1,0) statusLbl.BackgroundTransparency=1
statusLbl.Text="● RUNNING" statusLbl.TextColor3=P.vi
statusLbl.TextSize=7.5 statusLbl.Font=Enum.Font.GothamBold statusLbl.ZIndex=8 statusLbl.Parent=sPill

lbl(tCard,"NEXT REJOIN",0,0,0.5,12,7.5,P.dim,Enum.Font.GothamBold)

local timerLbl=Instance.new("TextLabel")
timerLbl.Size=UDim2.new(0.62,0,0,33) timerLbl.Position=UDim2.new(0,0,0,13)
timerLbl.BackgroundTransparency=1 timerLbl.Text="5:00"
timerLbl.TextColor3=P.tx timerLbl.TextSize=28 timerLbl.Font=Enum.Font.GothamBlack
timerLbl.TextXAlignment=Enum.TextXAlignment.Left timerLbl.ZIndex=7 timerLbl.Parent=tCard

local segRow=Instance.new("Frame")
segRow.Size=UDim2.new(1,0,0,5) segRow.Position=UDim2.new(0,0,0,50)
segRow.BackgroundTransparency=1 segRow.BorderSizePixel=0 segRow.ZIndex=7 segRow.Parent=tCard
local segL=Instance.new("UIListLayout")
segL.FillDirection=Enum.FillDirection.Horizontal segL.Padding=UDim.new(0,2) segL.Parent=segRow
local SEGS,segs=20,{}
for i=1,SEGS do
    local s=Instance.new("Frame")
    s.Size=UDim2.new(1/SEGS,-2,1,0)
    s.BackgroundColor3=P.vi s.BackgroundTransparency=0.12
    s.BorderSizePixel=0 s.ZIndex=8 s.Parent=segRow
    Instance.new("UICorner",s).CornerRadius=UDim.new(0,2)
    segs[i]=s
end

lbl(tCard,"SRV  "..JOB_ID:sub(1,20).."…",0,62,1,12,7,P.ghost,Enum.Font.Gotham)

-- INTERVAL CARD
local iCard=newCard(54,3)
local icp=Instance.new("UIPadding",iCard)
icp.PaddingLeft=UDim.new(0,12) icp.PaddingRight=UDim.new(0,12) icp.PaddingTop=UDim.new(0,8)
lbl(iCard,"INTERVAL (MINUTES)",0,0,1,12,7.5,P.dim,Enum.Font.GothamBold)

local inputBox=Instance.new("TextBox")
inputBox.Size=UDim2.new(0,150,0,30) inputBox.Position=UDim2.new(0,0,0,15)
inputBox.BackgroundColor3=P.ele inputBox.BorderSizePixel=0
inputBox.Text="5" inputBox.PlaceholderText="minutes…"
inputBox.TextColor3=P.tx inputBox.PlaceholderColor3=P.dim
inputBox.TextSize=14 inputBox.Font=Enum.Font.GothamBold inputBox.ZIndex=7 inputBox.Parent=iCard
Instance.new("UICorner",inputBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",inputBox).Color=P.vi

local setBtn=Instance.new("TextButton")
setBtn.Size=UDim2.new(0,92,0,30) setBtn.Position=UDim2.new(0,156,0,15)
setBtn.BackgroundColor3=P.vi setBtn.BorderSizePixel=0
setBtn.Text="APPLY" setBtn.TextColor3=P.white
setBtn.TextSize=9.5 setBtn.Font=Enum.Font.GothamBlack setBtn.ZIndex=7 setBtn.Parent=iCard
Instance.new("UICorner",setBtn).CornerRadius=UDim.new(0,8)
setBtn.MouseEnter:Connect(function() tw(setBtn,{BackgroundColor3=Color3.fromRGB(100,66,210)}) end)
setBtn.MouseLeave:Connect(function() tw(setBtn,{BackgroundColor3=P.vi}) end)

-- PRESET PILLS
local pillRow=Instance.new("Frame")
pillRow.Size=UDim2.new(1,0,0,20) pillRow.BackgroundTransparency=1
pillRow.LayoutOrder=35 pillRow.ZIndex=5 pillRow.Parent=body
local pillL=Instance.new("UIListLayout")
pillL.FillDirection=Enum.FillDirection.Horizontal pillL.Padding=UDim.new(0,4) pillL.Parent=pillRow
for _,m in ipairs({1,3,5,10,15,30}) do
    local pb=Instance.new("TextButton")
    pb.Size=UDim2.new(0,35,0,18) pb.BackgroundColor3=P.ele
    pb.BorderSizePixel=0 pb.Text=m.."m"
    pb.TextColor3=P.vi pb.TextSize=7.5 pb.Font=Enum.Font.GothamBold
    pb.ZIndex=6 pb.Parent=pillRow
    Instance.new("UICorner",pb).CornerRadius=UDim.new(0,5)
    Instance.new("UIStroke",pb).Color=P.vi
    pb.MouseEnter:Connect(function() tw(pb,{BackgroundColor3=Color3.fromRGB(22,16,46)}) end)
    pb.MouseLeave:Connect(function() tw(pb,{BackgroundColor3=P.ele}) end)
    pb.MouseButton1Click:Connect(function()
        inputBox.Text=tostring(m); interval=m*60; timeLeft=interval
    end)
end

local feedLbl=Instance.new("TextLabel")
feedLbl.Size=UDim2.new(1,0,0,12) feedLbl.BackgroundTransparency=1
feedLbl.Text="" feedLbl.TextColor3=P.vi feedLbl.TextSize=8
feedLbl.Font=Enum.Font.Gotham feedLbl.TextXAlignment=Enum.TextXAlignment.Left
feedLbl.LayoutOrder=40 feedLbl.ZIndex=5 feedLbl.Parent=body

-- BUTTON GRID (3×2)
local grid=Instance.new("Frame")
grid.Size=UDim2.new(1,0,0,122) grid.BackgroundTransparency=1
grid.LayoutOrder=50 grid.ZIndex=5 grid.Parent=body
local gl=Instance.new("UIGridLayout")
gl.CellSize=UDim2.new(0.5,-3,0,36) gl.CellPadding=UDim2.new(0,6,0,6)
gl.SortOrder=Enum.SortOrder.LayoutOrder gl.Parent=grid

local function mkBtn(label,lo,col)
    local btn=Instance.new("TextButton")
    btn.BackgroundColor3=P.ele btn.BorderSizePixel=0
    btn.Text=label btn.TextColor3=col
    btn.TextSize=8.5 btn.Font=Enum.Font.GothamBold
    btn.LayoutOrder=lo btn.ZIndex=6 btn.Parent=grid
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,9)
    local s=Instance.new("UIStroke",btn); s.Color=col; s.Transparency=0.65
    local hc=Color3.fromRGB(
        math.clamp(col.R*255*0.13,0,255),
        math.clamp(col.G*255*0.13,0,255),
        math.clamp(col.B*255*0.13,0,255))
    btn.MouseEnter:Connect(function()
        tw(btn,{BackgroundColor3=hc}); tw(s,{Transparency=0.18})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn,{BackgroundColor3=P.ele}); tw(s,{Transparency=0.65})
    end)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=col:Lerp(P.white,0.08)},TweenInfo.new(0.06))
        task.delay(0.07,function() tw(btn,{BackgroundColor3=hc},TweenInfo.new(0.1)) end)
        task.delay(0.2,function()  tw(btn,{BackgroundColor3=P.ele},TweenInfo.new(0.12)) end)
        tw(btn,{Size=UDim2.new(1,-5,0,31)},TweenInfo.new(0.06))
        task.delay(0.07,function() tw(btn,{Size=UDim2.new(1,0,0,36)},TweenInfo.new(0.1)) end)
    end)
    return btn
end

local toggleBtn   = mkBtn("⟳  AUTO: ON",      1,P.vi)
local rejoinBtn   = mkBtn("⚡  FORCE REJOIN",  2,P.cy)
local pauseBtn    = mkBtn("⏸  PAUSE",          3,P.am)
local resetTmrBtn = mkBtn("↺  RESET TIMER",    4,P.am)
local resetChrBtn = mkBtn("☠  RESET CHAR",     5,P.rd)
local copySrvBtn  = mkBtn("⧉  COPY SERVER",    6,P.gr)

-- MINI STAT ROW
local statsRow=Instance.new("Frame")
statsRow.Size=UDim2.new(1,0,0,38) statsRow.BackgroundTransparency=1
statsRow.LayoutOrder=60 statsRow.ZIndex=5 statsRow.Parent=body
local sRL=Instance.new("UIListLayout")
sRL.FillDirection=Enum.FillDirection.Horizontal sRL.Padding=UDim.new(0,5) sRL.Parent=statsRow

local function miniStat(label,col,getV)
    local sc=Instance.new("Frame")
    sc.Size=UDim2.new(0,80,0,36) sc.BackgroundColor3=P.card
    sc.BorderSizePixel=0 sc.ZIndex=6 sc.Parent=statsRow
    Instance.new("UICorner",sc).CornerRadius=UDim.new(0,9)
    local str=Instance.new("UIStroke",sc); str.Color=col; str.Transparency=0.78
    local strip=Instance.new("Frame")
    strip.Size=UDim2.new(0,3,0.55,0) strip.Position=UDim2.new(0,0,0.225,0)
    strip.BackgroundColor3=col strip.BorderSizePixel=0 strip.ZIndex=7 strip.Parent=sc
    Instance.new("UICorner",strip).CornerRadius=UDim.new(0,2)
    lbl(sc,label,8,3,1,12,7,P.dim,Enum.Font.GothamBold)
    local vl=lbl(sc,"—",8,15,1,15,12,col,Enum.Font.GothamBlack)
    task.spawn(function()
        while sc and sc.Parent do
            pcall(function() vl.Text=getV() end); task.wait(1)
        end
    end)
end

miniStat("PING",P.cy,function()
    local ok,p=pcall(function() return math.floor(LocalPlayer:GetNetworkPing()*1000) end)
    return ok and p.."ms" or "—"
end)
miniStat("PLAYERS",P.vi,function() return tostring(#Players:GetPlayers()) end)
miniStat("JOINS",P.gr,function() return tostring(rejoinCount) end)

-- ── LOGIC ────────────────────────────────────────────────
local function fmt(s) return string.format("%d:%02d",math.floor(s/60),s%60) end

local function updateUI()
    if not enabled then
        timerLbl.Text="Paused"; timerLbl.TextColor3=P.rd
        statusLbl.Text="● PAUSED"; statusLbl.TextColor3=P.rd; sPillStr.Color=P.rd
        for _,s in ipairs(segs) do
            tw(s,{BackgroundColor3=P.ghost,BackgroundTransparency=0.88},TweenInfo.new(0.25,Enum.EasingStyle.Quad))
        end
        return
    end
    timerLbl.Text=fmt(timeLeft); timerLbl.TextColor3=P.tx
    statusLbl.Text="● RUNNING"; statusLbl.TextColor3=P.vi; sPillStr.Color=P.vi
    local pct=timeLeft/interval
    local fc=pct>.5 and P.vi or pct>.25 and P.am or P.rd
    local filled=math.floor(pct*SEGS+0.5)
    for i,s in ipairs(segs) do
        local on=i<=filled
        tw(s,{BackgroundColor3=on and fc or P.ghost,BackgroundTransparency=on and 0.1 or 0.88},
            TweenInfo.new(0.28,Enum.EasingStyle.Quad))
    end
end

-- BRICK-WALL REJOIN — 4 tiers
local function doRejoin()
    rejoinCount+=1; rNum.Text=tostring(rejoinCount)
    pcall(function()
        if queue_on_teleport then
            local ok,s=pcall(readfile,"cchillzxboost.lua")
            if ok and s and #s>10 then queue_on_teleport(s) end
        end
    end)
    local ok1=pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID,JOB_ID,LocalPlayer)
    end)
    if ok1 then return end; task.wait(1.2)
    local ok2=pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID,JOB_ID,LocalPlayer)
    end)
    if ok2 then return end; task.wait(1.5)
    local ok3=pcall(function()
        TeleportService:Teleport(PLACE_ID,LocalPlayer)
    end)
    if ok3 then return end; task.wait(2)
    pcall(function() TeleportService:Teleport(PLACE_ID) end)
end

local function startTimer()
    if thread then task.cancel(thread) end
    timeLeft=interval; updateUI()
    thread=task.spawn(function()
        while true do
            task.wait(1)
            if enabled then
                timeLeft-=1; updateUI()
                if timeLeft<=0 then timeLeft=interval; task.spawn(doRejoin) end
            end
        end
    end)
end

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(math.random(50,66))
        pcall(function()
            local c=LocalPlayer.Character
            if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Jump=true end end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if enabled then
        feedLbl.Text="↺ Back — still running"; feedLbl.TextColor3=P.gr
        task.delay(2.5,function() feedLbl.Text="" end)
    end
end)

-- WIRING
setBtn.MouseButton1Click:Connect(function()
    local v=tonumber(inputBox.Text)
    if v and v>0 and v<=120 then
        interval=math.floor(v*60); timeLeft=interval
        feedLbl.Text="✓ Set to "..math.floor(v).."m"; feedLbl.TextColor3=P.gr; updateUI()
    else feedLbl.Text="✗ Enter 1–120"; feedLbl.TextColor3=P.rd end
    task.delay(2.5,function() feedLbl.Text="" end)
end)

toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then toggleBtn.Text="⟳  AUTO: ON"; toggleBtn.TextColor3=P.vi; startTimer()
    else toggleBtn.Text="⟳  AUTO: OFF"; toggleBtn.TextColor3=P.rd; updateUI() end
end)

pauseBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    pauseBtn.Text=enabled and "⏸  PAUSE" or "▶  RESUME"
    pauseBtn.TextColor3=enabled and P.am or P.gr
    if enabled then startTimer() else updateUI() end
end)

rejoinBtn.MouseButton1Click:Connect(function() task.spawn(doRejoin) end)
resetTmrBtn.MouseButton1Click:Connect(function() timeLeft=interval; updateUI() end)
resetChrBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local c=LocalPlayer.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
    end)
end)
copySrvBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(JOB_ID) end)
    feedLbl.Text="✓ Server ID copied!"; feedLbl.TextColor3=P.gr
    task.delay(2,function() feedLbl.Text="" end)
end)

minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    tw(frame,{Size=UDim2.new(0,FW,0,minimized and 42 or FH)},TIS)
    body.Visible=not minimized
    minBtn.Text=minimized and "+" or "—"
end)

startTimer()
]==]

src = src:gsub("SETPLACEID", tostring(PLACE_ID)):gsub("SETJOBID", JOB_ID)
pcall(function() writefile("cchillzxboost.lua", src) end)
pcall(function() if queue_on_teleport then queue_on_teleport(src) end end)
loadstring(src)()
