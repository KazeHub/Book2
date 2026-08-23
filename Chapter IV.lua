local KazeUI = KazeUI or loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KazeHub/UI/refs/heads/main/Libraryhehe"
))()

local Window = KazeUI:CreateWindow({
    Title = "The Mimic",
    Author = "Kaze",
    Version = "Book II",
    Size = UDim2.fromOffset(500, 370),
    Icon = "79414074886215",
    Theme = "Midnight",
    GlowStyle = "Cycle",
    GlowColor = true,

    OpenButton = {
        Icon = "79414074886215",
        Size = UDim2.fromOffset(60, 60)
    },
})

local Player = Window:CreateTab({
    Title = "Player",
    Icon = "user"
})

local Workspace = clonenav or (cloneref and cloneref(game:GetService("Workspace"))) or game:GetService("Workspace")

Player:Section("Client")

local autoPressE = false

Player:Toggle({
    Title = "Auto free yourself",
    Default = false,
    Callback = function(state)
        autoPressE = state
        if not state then return end

        task.spawn(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui

            while autoPressE do
                local grabbedUI = PlayerGui:FindFirstChild("QuickTime") and PlayerGui.QuickTime:FindFirstChild("GrabbedUI")
                if grabbedUI and grabbedUI.Visible then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)
                end
                task.wait(0.05)
            end
        end)
    end
})

local InstantPromptEnabled = false
local promptConnection

Player:Toggle({
    Title = "Instant Prompt",
    Default = false,
    Callback = function(s)
        InstantPromptEnabled = s
        
        if promptConnection then
            promptConnection:Disconnect()
            promptConnection = nil
        end
        
        if InstantPromptEnabled then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
            
            promptConnection = Workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ProximityPrompt") then
                    descendant.HoldDuration = 0
                end
            end)
        end
    end
})


local Lighting = clonenav or (cloneref and cloneref(game:GetService("Lighting"))) or game:GetService("Lighting")

local FB_ENABLED = false
local fbConnection
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origShadows = Lighting.GlobalShadows

Player:Toggle({
    Title = "FullBright",
    Default = false,
    Callback = function(s)
        FB_ENABLED = s
        if fbConnection then 
            fbConnection:Disconnect() 
            fbConnection = nil
        end
        
        if FB_ENABLED then
            local function applyBright()
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
            end
            
            applyBright()
            fbConnection = Lighting.Changed:Connect(applyBright)
        else
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoorAmbient
            Lighting.Brightness = origBrightness
            Lighting.ClockTime = origClockTime
            Lighting.GlobalShadows = origShadows
        end
    end
})

local RunService = clonenav or (cloneref and cloneref(game:GetService("RunService"))) or game:GetService("RunService")
local Players = clonenav or (cloneref and cloneref(game:GetService("Players"))) or game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local NoclipEnabled = false
local noclipConnection

Player:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(s)
        NoclipEnabled = s
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if NoclipEnabled then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

Player:Slider({
    Title = "TP Walk Speed",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(v)
        TPWalkSpeed = v
    end
})

Player:Toggle({
    Title = "Enable TP Walk",
    Default = false,
    Callback = function(s)
        TPWalkEnabled = s

        if tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end

        if TPWalkEnabled then
            tpWalkConnection = RunService.Heartbeat:Connect(function(dt)
                local character = LocalPlayer.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (TPWalkSpeed * 0.05))
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- 1. FIXED FLY SCRIPT (NO FALLING ON STOP)
-- ==========================================
local TargetFlySpeed = 16
local FLY_ENABLED = false
local flyConnection

Player:Slider({
    Title = "Fly Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(val)
        TargetFlySpeed = val
    end
})

Player:Toggle({
    Title = "Enable Fly",
    Default = false,
    Callback = function(state)
        FLY_ENABLED = state
        
        local function stopFly()
            if flyConnection then 
                flyConnection:Disconnect() 
                flyConnection = nil 
            end
            
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                humanoid.PlatformStand = false
            end
            if hrp then
                hrp.Anchored = false
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        
        stopFly()
        
        if FLY_ENABLED then
            local camera = Workspace.CurrentCamera
            
            flyConnection = RunService.RenderStepped:Connect(function(dt)
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid then
                    local moveDir = humanoid.MoveDirection
                    
                    if moveDir.Magnitude > 0 then
                        -- Kapag gumagalaw: Unanchor at galawin ang CFrame
                        hrp.Anchored = false
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        
                        local cameraCF = camera.CFrame
                        local relativeVector = cameraCF:VectorToObjectSpace(moveDir)
                        local flyDirection = (cameraCF.RightVector * relativeVector.X) + (cameraCF.LookVector * -relativeVector.Z)
                        
                        if flyDirection.Magnitude > 0 then
                            flyDirection = flyDirection.Unit
                        end
                        
                        hrp.CFrame = CFrame.lookAlong(hrp.Position, flyDirection) + (flyDirection * (TargetFlySpeed * dt))
                    else
                        -- Kapag huminto: I-anchor ang HRP para hindi bumaba/mahulog
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.Anchored = true
                    end
                end
            end)
        end
    end
})

local Cave = Window:CreateTab({
    Title = "Cave",
    Icon = "Book"
})

Cave:Button({
    Title = "Cutscene",
    Callback = function()
        local hrp = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(-1232.2074, 46.726635, -2941.54321, 0, 0, 1, 0, 1, 0, -1, 0, 0)
    end
})

local Street = Window:CreateTab({
    Title = "Street",
    Icon = "construction"
})

-- Main Group Elements
Street:Button({
    Title = "Escape Enzukai",
    Callback = function()
        local p = game.Players.LocalPlayer
        local c = p.Character or p.CharacterAdded:Wait()
        local h = c:WaitForChild("HumanoidRootPart")
        local s1 = workspace:FindFirstChild("Section1")
        if s1 and s1:FindFirstChild("OfficeTeleA") and s1.OfficeTeleA:IsA("BasePart") then
            h.CFrame = s1.OfficeTeleA.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

-- Other Group Elements
Street:Button({
    Title = "Remove Glass",
    Callback = function()
        local s1 = workspace:FindFirstChild("Section1")
        if s1 and s1:FindFirstChild("EnzukaiSneakSequence") and s1.EnzukaiSneakSequence:FindFirstChild("Activators") then
            s1.EnzukaiSneakSequence.Activators:Destroy()
        end
    end
})

Street:Section("ESP")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espObjects = {}
local espConnections = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    for _, conn in ipairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    espObjects = {}
    espConnections = {}
end

local function createESP(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "enzukaiESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model
    table.insert(espObjects, highlight)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "enzukaiBillboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model.HumanoidRootPart
    table.insert(espObjects, billboard)

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextColor3 = Color3.fromRGB(255, 255, 0)
    text.TextScaled = false
    text.TextSize = 13
    text.Font = Enum.Font.SourceSansBold
    text.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not espEnabled or not model.Parent then
            billboard:Destroy()
            highlight:Destroy()
            conn:Disconnect()
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - model.HumanoidRootPart.Position).Magnitude
            text.Text = "Enzukai\n[" .. math.floor(dist) .. "]"
        end
    end)
    table.insert(espConnections, conn)
end

Street:Toggle({
    Title = "ESP Enzukai",
    Default = false,
    Callback = function(s)
        espEnabled = s
        clearESP()
        if not s then return end

        local folder = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("EnzukaiSneakSequence") and workspace.Section1.EnzukaiSneakSequence:FindFirstChild("Monster")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") then
                    createESP(obj)
                end
            end

            local conn = folder.ChildAdded:Connect(function(obj)
                if espEnabled and obj:IsA("Model") then
                    task.wait(0.1)
                    createESP(obj)
                end
            end)
            table.insert(espConnections, conn)
        end
    end
})

local WorkPlace = Window:CreateTab({
    Title = "WorkPlace",
    Icon = "briefcase-business"
})

WorkPlace:Button({
    Title = "Cutscene",
    Callback = function()
        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        local section = workspace:FindFirstChild("Section1")
        local objective = section and section:FindFirstChild("PlayerObjective")
        local npc = objective and objective:FindFirstChild("QuestGiverNPC")

        if npc and root then
            root.CFrame = npc:GetPivot() + Vector3.new(0, 3, 0)
            task.wait(0.3)
            for _, prompt in ipairs(npc:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and (prompt.Parent.Position - root.Position).Magnitude <= 8 then
                    fireproximityprompt(prompt)
                    break
                end
            end
        end
    end
})

WorkPlace:Button({
    Title = "Keypad Code",
    Callback = function()
        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        local section = workspace:FindFirstChild("Section1")
        local obj = section and section:FindFirstChild("PlayerObjective")
        local keypad = obj and obj:FindFirstChild("CodeDoor") and obj.CodeDoor:FindFirstChild("Keypad")

        if keypad and root then
            local tpTarget = keypad:FindFirstChild("Screen") or keypad:FindFirstChildWhichIsA("BasePart")
            if tpTarget then
                root.CFrame = tpTarget.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
                for _, prompt in ipairs(keypad:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled and (prompt.Parent.Position - root.Position).Magnitude <= 6 then
                        fireproximityprompt(prompt)
                        break
                    end
                end
            end
        end

        task.wait(1)
        if not obj then return end
        local folder = obj:FindFirstChild("CodeNumbers")
        local remote = obj:FindFirstChild("CodeDoor") and obj.CodeDoor:FindFirstChild("Remote")
        if not folder or not remote then return end

        local codes = {}
        for _, part in ipairs(folder:GetChildren()) do
            local gui = part:FindFirstChildWhichIsA("SurfaceGui", true)
            local textObj = gui and (gui:FindFirstChildWhichIsA("TextLabel", true) or gui:FindFirstChildWhichIsA("TextBox", true) or gui:FindFirstChildWhichIsA("TextButton", true))
            local value = textObj and tonumber(textObj.Text)
            if value then
                table.insert(codes, {Floor = tonumber(part.Name:match("%d+")) or 0, Value = value})
            end
        end

        table.sort(codes, function(a, b) return a.Floor > b.Floor end)

        local result = {}
        for i = 1, 6 do
            result[i] = codes[i] and codes[i].Value or 0
        end

        remote:FireServer(1, result)
    end
})

WorkPlace:Button({
    Title = "Dig & Escape",
    Callback = function()
        local LocalPlayer = game.Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart", 3)
        if not HRP then return end

        local shovelGiver = workspace.Section1.PlayerObjective.CodeDoor.ShovelGiver
        if shovelGiver and shovelGiver:IsA("BasePart") then
            HRP.CFrame = shovelGiver.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            for _, d in ipairs(shovelGiver:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    fireproximityprompt(d)
                    break
                end
            end
        end

        local toolName = "Mimic@Tool_Shovel"
        local backpack = LocalPlayer.Backpack
        local tool = backpack:FindFirstChild(toolName)
        if not tool then
            repeat
                tool = backpack:WaitForChild(toolName)
                task.wait(0.2)
            until tool
        end
        tool.Parent = Character
        task.wait(0.2)

        HRP.CFrame = CFrame.new(4450, 44, 1638)
        local dirt = workspace.Section1.PlayerObjective.DirtDigObjective
        if dirt then
            for i = 1, 5 do
                for _, d in ipairs(dirt:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        fireproximityprompt(d)
                        task.wait(0.5)
                        break
                    end
                end
            end
        end

        task.wait(0.5)
        HRP.CFrame = CFrame.new(4434, 44, 1638)
        task.wait(0.3)
        local tpDoor = workspace.Section1.PlayerObjective.TeleportDoor.PROMPT
        if tpDoor then
            for _, p in ipairs(tpDoor:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled then
                    fireproximityprompt(p)
                    break
                end
            end
        end
    end
})

WorkPlace:Button({
    Title = "Escape Isamu's Workplace",
    Callback = function()
        local LocalPlayer = game.Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = Character:WaitForChild("HumanoidRootPart")

        local partA = workspace:FindFirstChild("WHITE_FLAME_LANTERN") and workspace.WHITE_FLAME_LANTERN:FindFirstChild("PieceA")
        if partA then
            root.CFrame = partA.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.25)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                    if parentPart and (parentPart.Position - root.Position).Magnitude <= 10 then
                        fireproximityprompt(obj)
                        break
                    end
                end
            end
        end

        task.wait(0.25)
        local escapePos = CFrame.new(4976, 27, 1220)
        root.CFrame = escapePos
        task.wait(0.25)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                if parentPart and (parentPart.Position - root.Position).Magnitude <= 10 then
                    fireproximityprompt(obj)
                    break
                end
            end
        end
    end
})

local Mall = Window:CreateTab({
    Title = "Mall",
    Icon = "Building-2"
})


-- ==================== MAIN ====================
Mall:Button({
    Title = "Walkie Talkie",
    Callback = function()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart", 3)
        if not HRP then return end

        local section = workspace:FindFirstChild("Section2")
        local folder = section and section:FindFirstChild("WalkieTalkis")
        if not folder then return end

        local targets = {
            folder:FindFirstChild("WalkieTalkie"),
            folder:GetChildren()[6],
            folder:GetChildren()[7],
            folder:GetChildren()[8]
        }

        for _, target in ipairs(targets) do
            if target and target:IsA("BasePart") then
                HRP.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
                for _, obj in ipairs(target:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled and (obj.Parent.Position - HRP.Position).Magnitude <= 10 then
                        fireproximityprompt(obj)
                        break
                    end
                end
                task.wait(0.3)
            end
        end
    end
})

Mall:Button({
    Title = "Activate The Trigger",
    Callback = function()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart", 3)
        if not HRP then return end

        local section = workspace:FindFirstChild("Section2")
        local floor = section and section:FindFirstChild("Floor1")
        local trigger = floor and floor:FindFirstChild("TRIGGER")

        if trigger and trigger:IsA("BasePart") then
            HRP.CFrame = trigger.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.2)
        end

        HRP.CFrame = CFrame.new(-1333, -165, -1119)
    end
})

Mall:Button({
    Title = "Collect & Insert Coins",
    Callback = function()
        local function GetValidPart(Object)
            if Object:IsA("BasePart") and Object.Transparency < 1 then return Object end
            for _, Child in ipairs(Object:GetDescendants()) do
                if Child:IsA("BasePart") and Child.Transparency < 1 then return Child end
            end
        end

        local function TeleportAndFire(Object)
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local Root = Character:FindFirstChild("HumanoidRootPart")
            local Part = GetValidPart(Object)
            if Root and Part then
                Root.CFrame = Part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.25)
                for _, Descendant in ipairs(Object:GetDescendants()) do
                    if Descendant:IsA("ProximityPrompt") and Descendant.Enabled then
                        fireproximityprompt(Descendant)
                        break
                    end
                end
                task.wait(0.25)
                return true
            end
            return false
        end

        local Section = workspace:FindFirstChild("Section2")
        local CoinFolder = Section and Section:FindFirstChild("Floor2") and Section.Floor2:FindFirstChild("Coins")
        if not CoinFolder then return end

        local Candidates = {}
        for _, Object in ipairs(CoinFolder:GetChildren()) do
            if GetValidPart(Object) then table.insert(Candidates, Object) end
        end

        local Visited = {}
        local Count = 0
        while Count < 5 and #Candidates > 0 do
            local Index = math.random(1, #Candidates)
            local Choice = table.remove(Candidates, Index)
            if Choice and not Visited[Choice] then
                Visited[Choice] = true
                if TeleportAndFire(Choice) then Count += 1 end
            end
        end

        local CoinSlot = Section and Section:FindFirstChild("Floor2") and Section.Floor2:FindFirstChild("Carousel") and Section.Floor2.Carousel:FindFirstChild("CoinSlot")
        if CoinSlot then TeleportAndFire(CoinSlot) end
    end
})

Mall:Button({
    Title = "Blind Kyogi",
    Callback = function()
        local function GetValidPart(Object)
            if Object:IsA("BasePart") then return Object end
            for _, Descendant in ipairs(Object:GetDescendants()) do
                if Descendant:IsA("BasePart") then return Descendant end
            end
        end

        local function SafeTeleport(Position)
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local Root = Character:FindFirstChild("HumanoidRootPart")
            if Root then Root.CFrame = CFrame.new(Position) end
        end

        local function TeleportAndPrompt(Folder)
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local Root = Character:FindFirstChild("HumanoidRootPart")
            if not Root then return end

            for _, Item in ipairs(Folder:GetChildren()) do
                local Part = GetValidPart(Item)
                if Part then
                    Root.CFrame = Part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.25)
                    for _, Obj in ipairs(Item:GetDescendants()) do
                        if Obj:IsA("ProximityPrompt") and Obj.Enabled then
                            fireproximityprompt(Obj)
                            task.wait(0.25)
                            break
                        end
                    end
                    SafeTeleport(Vector3.new(-1333, -165, -1119))
                    task.wait(0.50)
                end
            end
        end

        local TimedTrial = workspace:FindFirstChild("Section2") and workspace.Section2:FindFirstChild("Floor1") and workspace.Section2.Floor1:FindFirstChild("TimedTrial")
        if not TimedTrial then return end

        for Index = 1, 3 do
            local Folder = TimedTrial:FindFirstChild(tostring(Index))
            if Folder then TeleportAndPrompt(Folder) end
        end
    end
})

Mall:Button({
    Title = "Auto Speaker Task",
    Callback = function()
        local function GetPart(Object)
            if Object:IsA("BasePart") then return Object end
            for _, Descendant in ipairs(Object:GetDescendants()) do
                if Descendant:IsA("BasePart") then return Descendant end
            end
        end

        local function FirePrompt(Object)
            for _, Descendant in ipairs(Object:GetDescendants()) do
                if Descendant:IsA("ProximityPrompt") and Descendant.Enabled then
                    fireproximityprompt(Descendant)
                    return true
                end
            end
            return false
        end

        local Section = workspace:FindFirstChild("Section2")
        local Speaker = Section and Section:FindFirstChild("Speaker")
        if not Speaker then return end

        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Root = Character:WaitForChild("HumanoidRootPart")
        local Part = GetPart(Speaker)
        if not Root or not Part then return end

        Root.CFrame = Part.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.25)
        FirePrompt(Speaker)

        Root.CFrame = CFrame.new(-1364, -120, -937)
        task.wait(0.25)

        if Speaker:FindFirstChild("Signal") then
            Speaker.Signal:FireServer()
        end

        task.wait(0.5)
        FirePrompt(Speaker)
    end
})

Mall:Button({
    Title = "Escape The Destroyed Mall",
    Callback = function()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart", 3)
        if not HRP then return end

        local tsukiya = workspace:FindFirstChild("Section2") and workspace.Section2:FindFirstChild("Floor3") and workspace.Section2.Floor3:FindFirstChild("Monster") and workspace.Section2.Floor3.Monster:FindFirstChild("Tsukiya")

        if tsukiya and tsukiya:IsA("BasePart") then
            HRP.CFrame = tsukiya.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            for _, prompt in ipairs(tsukiya:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and (HRP.Position - prompt.Parent.Position).Magnitude <= 10 then
                    fireproximityprompt(prompt)
                    break
                end
            end
        end

        local exit = workspace:FindFirstChild("Section2") and workspace.Section2:FindFirstChild("Exit")
        if exit and exit:IsA("BasePart") then
            HRP.CFrame = exit.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
        end
    end
})

Mall:Section("ESP")

-- ==================== OTHER ====================
local espEnabled = false
local espObjects = {}
local espConnections = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    for _, conn in ipairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    espObjects = {}
    espConnections = {}
end

local function createESP(model, name)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "mallESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model
    table.insert(espObjects, highlight)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "mallBillboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model.HumanoidRootPart
    table.insert(espObjects, billboard)

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextColor3 = Color3.fromRGB(255, 255, 0)
    text.TextScaled = false
    text.TextSize = 13
    text.Font = Enum.Font.SourceSansBold
    text.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not espEnabled or not model.Parent then
            if billboard then billboard:Destroy() end
            if highlight then highlight:Destroy() end
            conn:Disconnect()
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - model.HumanoidRootPart.Position).Magnitude
            text.Text = name .. "\n[" .. math.floor(dist) .. "]"
        end
    end)
    table.insert(espConnections, conn)
end

Mall:Toggle({
    Title = "ESP",
    Default = false,
    Callback = function(s)
        espEnabled = s
        clearESP()
        if not s then return end

        local monsters = {
            {Path = workspace.Section2.Floor1.Monster.Tenome, Name = "Tenome"},
            {Path = workspace.Section2.Floor2.Monster.Rin, Name = "Rin"},
            {Path = workspace.Section2.Floor3.Monster.Tsukiya, Name = "Tsukiya"}
        }

        for _, m in ipairs(monsters) do
            if m.Path and m.Path.Parent then
                createESP(m.Path, m.Name)
            end
        end
    end
})

local MallChase = Window:CreateTab({
    Title = "Mall Chase",
    Icon = "Building-2"
})

MallChase:Button({
    Title = "Escape Chase 1",
    Callback = function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local LocalPlayer = Players.LocalPlayer

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        local chaseSeq = workspace:WaitForChild("Section2.5"):WaitForChild("ChaseSequence")
        local startPoint = chaseSeq:WaitForChild("StartPoint")
        local endPoint = chaseSeq:WaitForChild("EndPoint")
        local waypointsFolder = chaseSeq:WaitForChild("MAINCHASERS"):WaitForChild("Waypoints")

        -- Instant teleport to StartPoint
        humanoidRootPart.CFrame = startPoint.CFrame
        task.wait(0.2)

        -- Get and sort waypoints
        local waypoints = waypointsFolder:GetChildren()
        table.sort(waypoints, function(a, b)
            local numA = tonumber(a.Name:match("%d+")) or 0
            local numB = tonumber(b.Name:match("%d+")) or 0
            return numA < numB
        end)

        local tweenSpeed = 2

        -- Tween from waypoint 2 to 20
        for i = 2, #waypoints do
            local waypoint = waypoints[i]
            local targetCFrame = waypoint:IsA("BasePart") and waypoint.CFrame or CFrame.new(waypoint.Position)
            local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
        end

        -- Final tween to EndPoint
        local finalCFrame = endPoint:IsA("BasePart") and endPoint.CFrame or CFrame.new(endPoint.Position)
        local finalTween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = finalCFrame})
        finalTween:Play()
        finalTween.Completed:Wait()
    end
})

MallChase:Button({
	Title = "Escape Chase 2",
	Callback = function()
		local lp = game.Players.LocalPlayer
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") or lp.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 3)
		local s = workspace:FindFirstChild("Section2.5")
		if not (hrp and s) then return end

		local elev = s:FindFirstChild("Elevator")
		if elev then
			local parts = {}
			for _,v in ipairs(elev:GetDescendants()) do if v:IsA("BasePart") then parts[#parts+1] = v.Position end end
			if #parts > 0 then
				local c = Vector3.zero
				for _,p in ipairs(parts) do c += p end
				hrp.CFrame = CFrame.new((c/#parts) + Vector3.new(0,3,0))
				task.wait(0.25)
			end
		end

		local hit = s:FindFirstChild("ChaseSequence") and s.ChaseSequence:FindFirstChild("SecondChaseStuff") and s.ChaseSequence.SecondChaseStuff:FindFirstChild("ElevatorHit")
		if hit and hit:IsA("BasePart") then hrp.CFrame = hit.CFrame + Vector3.new(0,3,0) end
	end
})

local Parking = Window:CreateTab({
    Title = "Parking Slot",
    Icon = "circle-parking"
})

Parking:Button({
    Title = "Auto Repair Vehicle",
    Locked = false,
    Description = "",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local minigamePath = workspace:WaitForChild("Section2.5"):WaitForChild("ChihiroMinigame"):WaitForChild("CarFixObjective")
        local carPartsFolder = minigamePath:WaitForChild("CarParts")
        local vehicleBuilder = minigamePath:WaitForChild("Vehicle"):WaitForChild("Builder")

        local wheelSlots = {
            vehicleBuilder:WaitForChild("FL"),
            vehicleBuilder:WaitForChild("FR"),
            vehicleBuilder:WaitForChild("RL"),
            vehicleBuilder:WaitForChild("RR")
        }

        local mainPart = vehicleBuilder:WaitForChild("Main")

        local validPartNames = {
            ["Car Wheel"] = true,
            ["GasCan"] = true,
            ["Gas Can"] = true,
            ["V8 Engine"] = true,
            ["Steering Wheel"] = true
        }

        local function triggerPrompt(parentObject)
            local prompt = parentObject:FindFirstChildOfClass("ProximityPrompt") or parentObject:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                elseif fireoldproximityprompt then
                    fireoldproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration)
                    prompt:InputHoldEnd()
                end
            end
        end

        local function teleportTo(targetObject)
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            local targetCFrame
            if targetObject:IsA("BasePart") then
                targetCFrame = targetObject.CFrame
            elseif targetObject:IsA("Attachment") then
                targetCFrame = targetObject.WorldCFrame
            elseif targetObject:IsA("Model") then
                targetCFrame = targetObject:GetPivot()
            end

            if targetCFrame then
                hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
            end
        end

        local allParts = carPartsFolder:GetChildren()
        local availableParts = {}

        for _, object in ipairs(allParts) do
            if object:IsA("BasePart") or object:IsA("Model") then
                table.insert(availableParts, object)
            end
        end

        local currentWheelIndex = 1

        for i = 1, #availableParts, 3 do
            local batchCollectedNames = {}

            for j = i, math.min(i + 2, #availableParts) do
                local part = availableParts[j]
                if part and part.Parent then
                    local partName = part.Name
                    teleportTo(part)
                    triggerPrompt(part)
                    table.insert(batchCollectedNames, partName)
                    task.wait(0.4)
                end
            end

            for _, itemName in ipairs(batchCollectedNames) do
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local backpack = LocalPlayer:WaitForChild("Backpack")

                local tool = backpack:FindFirstChild(itemName) or character:FindFirstChild(itemName)

                if tool and tool:IsA("Tool") and validPartNames[tool.Name] then
                    if tool.Parent == backpack then
                        humanoid:EquipTool(tool)
                        task.wait(0.3)
                    end

                    if tool.Name == "Car Wheel" then
                        if currentWheelIndex <= #wheelSlots then
                            local targetSlot = wheelSlots[currentWheelIndex]
                            teleportTo(targetSlot)
                            triggerPrompt(targetSlot)
                            currentWheelIndex += 1
                        end
                    else
                        teleportTo(mainPart)
                        triggerPrompt(mainPart)
                    end

                    task.wait(0.4)
                end
            end
        end
    end
})

Parking:Section("Chihiro Minigame")

Parking:Button({
    Title = "Fix Chihiro Minigame",
    Callback = function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 3)
        local gui = PlayerGui:FindFirstChild("S2.5")
        if gui then
            local scriptObj = gui:FindFirstChild("LocalScript")
            if scriptObj and scriptObj:IsA("LocalScript") then
                scriptObj.Enabled = false
                task.wait(0.2)
                scriptObj.Enabled = true
            end
        end
    end
})

Parking:Button({
    Title = "Answer",
    Callback = function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local SectionGui = PlayerGui:WaitForChild("S2.5")
        local Selectors = SectionGui:WaitForChild("Selectors")
        local QuestionLabel = SectionGui:WaitForChild("Questions"):WaitForChild("Question")

        local rawQuestion = QuestionLabel.Text
        local questionText = rawQuestion:lower()
            :gsub("%s+", " ")
            :gsub("^%s*(.-)%s*$", "%1")

        local answerMap = {
            ["i was once a curious girl, now i wear a white dress and a pink hat, forever smiling. who am i?"] = "Hiachi Masashige",
            ["i sit quietly, made of stone, and show the way to a sacred throne. what am i?"] = "Torii Gate",
            ["flames consume at my decree, yokai kneel and follow me. jealous hearts, i twist and pry, for my father, worlds will die. speak my name, who am i?"] = "Enzukai",
            ["i guard the shrine in silence, standing still with fierce eyes. what am i?"] = "A Komainu",
            ["what is our cult name?"] = "Kiiroibara Cult",
            ["i am pathetic, regretful, and i'm the reason my brother died. who am i?"] = "Me",
            ["i bloom in spring, soft and sweet, pink and white, on branches i greet. i am kintoru's favorite. what am i?"] = "Cherry Blossom",
            ["i have no voice, yet i tell stories in ink. i'm soft in your hand, but i carve into time. what am i?"] = "A Brush",
            ["four i shaped in shadows dire— flames of envy, a burning pyre. chains of control, unyielding, tight, one reborn, one filled with spite, who forged them all? speak my fate."] = "Evil God"
        }

        local correctAnswer = answerMap[questionText]

        if not correctAnswer then
            notify(
                "No Match Found",
                "Question not recognized.\n\n" .. rawQuestion,
                5
            )
            return
        end

        -- Always show the correct answer
        notify(
            "Correct Answer",
            "The correct answer is: " .. correctAnswer,
            5
        )

        local chosenIndex = nil
        local expected = correctAnswer:lower()
            :gsub("%s+", " ")
            :gsub("^%s*(.-)%s*$", "%1")

        for index, selector in ipairs(Selectors:GetChildren()) do
            local label = selector:FindFirstChild("Label", true)

            if label and label:IsA("TextLabel") then
                local answerText = label.Text:lower()
                    :gsub("%s+", " ")
                    :gsub("^%s*(.-)%s*$", "%1")

                if answerText == expected then
                    chosenIndex = index
                    break
                end
            end
        end

        if not chosenIndex then
            notify(
                "Answer Not Found",
                "The correct answer is:\n" .. correctAnswer ..
                "\n\nBut it wasn't found in the 3 choices.",
                5
            )
            return
        end

        local section = workspace:FindFirstChild("Section2.5")
        local chihiro = section and section:FindFirstChild("ChihiroMinigame")
        local trivia = chihiro and chihiro:FindFirstChild("Trivia")
        local triviaSignal = trivia and trivia:FindFirstChild("Signal")

        if triviaSignal then
            triviaSignal:FireServer(1, chosenIndex)
        else
            notify(
                "Signal Not Found",
                "Could not find the Trivia Signal.",
                5
            )
        end
    end
})

local Temple = Window:CreateTab({
    Title = "Temple",
    Icon = "Landmark"
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local selectedPaint = "Paint A"

-- Utility helper to safely get nested instances without throwing errors if unloaded
local function GetPath(...)
    local current = workspace
    for _, name in ipairs({...}) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function GetValidPart(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    if model:IsA("Model") then
        if model.PrimaryPart then return model.PrimaryPart end
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then return v end
        end
    end
    return nil
end

local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

Temple:Dropdown({
    Title = "Select Paint",
    Options = { "Paint A", "Paint B", "Paint C", "Paint D" },
    Callback = function(option)
        selectedPaint = option
    end
})

Temple:Button({
    Title = "Teleport to Paint",
    Callback = function()
        local paintPuzzle = GetPath("Section3", "PaintPuzzle")
        if not paintPuzzle then return end

        local targetName = "PaintStation_" .. string.sub(selectedPaint, -1)
        local target = paintPuzzle:FindFirstChild(targetName)
        if not target then return end

        local HRP = GetHRP()
        local part = GetValidPart(target)
        if HRP and part then
            HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

Temple:Button({
    Title = "Bless Ink",
    Callback = function()
        local HRP = GetHRP()
        if not HRP then return end

        local function firePromptIn(target)
            if not target then return end
            local part = GetValidPart(target)
            if not part then return end
            
            HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            
            for _, prompt in ipairs(target:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration)
                        prompt:InputHoldEnd()
                    end
                    break
                end
            end
            task.wait(0.4)
        end

        local ingredients = GetPath("Section3", "PaintPuzzle", "Ingredients")
        if not ingredients then return end

        firePromptIn(ingredients:FindFirstChild("Orchid"))
        firePromptIn(ingredients:FindFirstChild("Water"))
        firePromptIn(ingredients:FindFirstChild("PlaceInkHere"))
    end
})

-- ==================== PAINT DRAWING ====================
local StationPoints = {
    PaintStation_A = {Vector2.new(29,44),Vector2.new(34,44),Vector2.new(39,45),Vector2.new(43,46),Vector2.new(47,46),Vector2.new(51,46),Vector2.new(56,46),Vector2.new(61,45),Vector2.new(66,44),Vector2.new(71,44),Vector2.new(75,44),Vector2.new(79,43),Vector2.new(83,43),Vector2.new(87,43),Vector2.new(91,43),Vector2.new(95,43),Vector2.new(99,44),Vector2.new(104,44),Vector2.new(108,44),Vector2.new(112,44),Vector2.new(116,44),Vector2.new(120,44),Vector2.new(124,45),Vector2.new(128,45),Vector2.new(131,49),Vector2.new(133,53),Vector2.new(134,57),Vector2.new(58,72),Vector2.new(58,68),Vector2.new(58,64),Vector2.new(59,59),Vector2.new(59,55),Vector2.new(59,50),Vector2.new(59,39),Vector2.new(60,34),Vector2.new(31,104),Vector2.new(35,104),Vector2.new(39,104),Vector2.new(44,104),Vector2.new(49,104),Vector2.new(53,104),Vector2.new(57,104),Vector2.new(61,104),Vector2.new(65,104),Vector2.new(69,104),Vector2.new(73,105),Vector2.new(74,109),Vector2.new(73,113),Vector2.new(73,117),Vector2.new(73,121),Vector2.new(73,125),Vector2.new(73,100),Vector2.new(73,96),Vector2.new(74,92),Vector2.new(74,88),Vector2.new(74,84),Vector2.new(45,86),Vector2.new(45,90),Vector2.new(46,95),Vector2.new(45,99),Vector2.new(45,109),Vector2.new(46,113),Vector2.new(45,117),Vector2.new(45,121),Vector2.new(82,70),Vector2.new(86,67),Vector2.new(90,64),Vector2.new(94,62),Vector2.new(98,61),Vector2.new(81,104),Vector2.new(86,103),Vector2.new(90,103),Vector2.new(94,103),Vector2.new(98,103),Vector2.new(102,102),Vector2.new(106,103),Vector2.new(110,103),Vector2.new(114,103),Vector2.new(118,103),Vector2.new(122,103),Vector2.new(125,107),Vector2.new(126,111),Vector2.new(128,116),Vector2.new(129,120),Vector2.new(130,124),Vector2.new(130,112),Vector2.new(129,106),Vector2.new(129,102),Vector2.new(127,97),Vector2.new(126,93),Vector2.new(125,89),Vector2.new(123,85),Vector2.new(121,81),Vector2.new(100,88),Vector2.new(100,92),Vector2.new(100,97),Vector2.new(98,107),Vector2.new(97,112),Vector2.new(97,116),Vector2.new(101,118)},
    PaintStation_B = {Vector2.new(28,109),Vector2.new(32,109),Vector2.new(36,111),Vector2.new(40,113),Vector2.new(44,116),Vector2.new(48,119),Vector2.new(51,123),Vector2.new(53,127),Vector2.new(35,105),Vector2.new(39,102),Vector2.new(42,98),Vector2.new(46,96),Vector2.new(64,119),Vector2.new(64,115),Vector2.new(63,111),Vector2.new(63,107),Vector2.new(63,103),Vector2.new(63,99),Vector2.new(68,110),Vector2.new(72,110),Vector2.new(76,110),Vector2.new(80,110),Vector2.new(84,110),Vector2.new(82,114),Vector2.new(82,118),Vector2.new(82,122),Vector2.new(83,126),Vector2.new(84,105),Vector2.new(83,101),Vector2.new(83,97),Vector2.new(99,125),Vector2.new(103,125),Vector2.new(107,125),Vector2.new(111,123),Vector2.new(90,109),Vector2.new(94,109),Vector2.new(98,109),Vector2.new(102,109),Vector2.new(106,109),Vector2.new(110,109),Vector2.new(114,109),Vector2.new(118,109),Vector2.new(122,109),Vector2.new(126,109),Vector2.new(130,109),Vector2.new(130,113),Vector2.new(131,117),Vector2.new(133,121),Vector2.new(133,125),Vector2.new(129,105),Vector2.new(128,100),Vector2.new(127,96),Vector2.new(125,92),Vector2.new(113,98),Vector2.new(109,96),Vector2.new(105,96),Vector2.new(101,95),Vector2.new(138,90),Vector2.new(136,86),Vector2.new(134,82),Vector2.new(132,78),Vector2.new(131,74),Vector2.new(129,70),Vector2.new(126,49),Vector2.new(128,45),Vector2.new(130,41),Vector2.new(131,36),Vector2.new(133,32),Vector2.new(135,38),Vector2.new(137,34),Vector2.new(133,27),Vector2.new(26,59),Vector2.new(30,59),Vector2.new(35,59),Vector2.new(40,59),Vector2.new(40,64),Vector2.new(39,70),Vector2.new(38,74),Vector2.new(38,78),Vector2.new(43,80),Vector2.new(46,84),Vector2.new(42,84),Vector2.new(38,55),Vector2.new(38,49),Vector2.new(37,45),Vector2.new(36,40),Vector2.new(36,36),Vector2.new(49,59),Vector2.new(53,59),Vector2.new(57,59),Vector2.new(57,63),Vector2.new(57,67),Vector2.new(56,71),Vector2.new(56,75),Vector2.new(60,76),Vector2.new(64,77),Vector2.new(68,77),Vector2.new(72,77),Vector2.new(76,78),Vector2.new(80,78),Vector2.new(85,79),Vector2.new(89,79),Vector2.new(93,79),Vector2.new(97,79),Vector2.new(100,75),Vector2.new(99,71),Vector2.new(99,67),Vector2.new(99,63),Vector2.new(100,58),Vector2.new(100,54),Vector2.new(100,50),Vector2.new(100,46),Vector2.new(99,42),Vector2.new(95,39),Vector2.new(91,38),Vector2.new(87,38),Vector2.new(83,38),Vector2.new(79,39),Vector2.new(75,39),Vector2.new(71,39),Vector2.new(67,40),Vector2.new(63,41),Vector2.new(59,45),Vector2.new(59,49),Vector2.new(71,70),Vector2.new(70,66),Vector2.new(71,62),Vector2.new(70,57),Vector2.new(70,53),Vector2.new(70,49),Vector2.new(84,72),Vector2.new(84,67),Vector2.new(84,63),Vector2.new(84,55),Vector2.new(84,51),Vector2.new(85,47),Vector2.new(114,86),Vector2.new(114,82),Vector2.new(115,77),Vector2.new(115,73),Vector2.new(115,68),Vector2.new(115,62),Vector2.new(115,58),Vector2.new(115,54),Vector2.new(115,50),Vector2.new(115,46),Vector2.new(116,42),Vector2.new(115,38),Vector2.new(118,34)},
    PaintStation_C = {Vector2.new(37,123),Vector2.new(37,119),Vector2.new(38,115),Vector2.new(38,111),Vector2.new(34,110),Vector2.new(35,105),Vector2.new(38,100),Vector2.new(39,95),Vector2.new(41,91),Vector2.new(61,92),Vector2.new(62,96),Vector2.new(62,100),Vector2.new(62,104),Vector2.new(61,108),Vector2.new(61,112),Vector2.new(62,116),Vector2.new(61,120),Vector2.new(62,124),Vector2.new(67,107),Vector2.new(71,107),Vector2.new(75,107),Vector2.new(79,107),Vector2.new(83,107),Vector2.new(87,107),Vector2.new(91,107),Vector2.new(95,107),Vector2.new(99,108),Vector2.new(103,108),Vector2.new(107,108),Vector2.new(111,108),Vector2.new(115,108),Vector2.new(119,108),Vector2.new(123,108),Vector2.new(127,108),Vector2.new(131,108),Vector2.new(135,108),Vector2.new(139,108),Vector2.new(81,122),Vector2.new(85,122),Vector2.new(89,122),Vector2.new(93,122),Vector2.new(98,123),Vector2.new(102,123),Vector2.new(106,123),Vector2.new(110,123),Vector2.new(115,124),Vector2.new(119,125),Vector2.new(81,93),Vector2.new(85,94),Vector2.new(89,94),Vector2.new(93,94),Vector2.new(97,94),Vector2.new(101,94),Vector2.new(105,94),Vector2.new(109,94),Vector2.new(32,47),Vector2.new(37,43),Vector2.new(42,41),Vector2.new(45,34),Vector2.new(47,30),Vector2.new(57,80),Vector2.new(57,73),Vector2.new(57,68),Vector2.new(57,61),Vector2.new(57,56),Vector2.new(58,50),Vector2.new(58,46),Vector2.new(58,40),Vector2.new(58,36),Vector2.new(58,32),Vector2.new(31,67),Vector2.new(35,68),Vector2.new(40,68),Vector2.new(44,68),Vector2.new(48,69),Vector2.new(53,68),Vector2.new(62,67),Vector2.new(67,67),Vector2.new(72,67),Vector2.new(77,68),Vector2.new(81,68),Vector2.new(85,69),Vector2.new(90,70),Vector2.new(95,71),Vector2.new(99,72),Vector2.new(104,74),Vector2.new(108,76),Vector2.new(112,77),Vector2.new(116,79),Vector2.new(121,81),Vector2.new(125,83),Vector2.new(129,85),Vector2.new(133,86),Vector2.new(84,62),Vector2.new(89,62),Vector2.new(93,61),Vector2.new(98,60),Vector2.new(102,58),Vector2.new(106,53),Vector2.new(110,51),Vector2.new(114,49),Vector2.new(118,45),Vector2.new(123,41),Vector2.new(128,37),Vector2.new(131,33),Vector2.new(134,29),Vector2.new(74,38),Vector2.new(78,38),Vector2.new(83,38),Vector2.new(89,40),Vector2.new(94,41),Vector2.new(99,43),Vector2.new(103,44),Vector2.new(108,46),Vector2.new(118,51),Vector2.new(123,53),Vector2.new(127,57),Vector2.new(131,62),Vector2.new(132,66),Vector2.new(135,70)},
    PaintStation_D = {Vector2.new(97,65),Vector2.new(100,71),Vector2.new(104,79),Vector2.new(101,74),Vector2.new(108,85),Vector2.new(112,88),Vector2.new(109,80),Vector2.new(103,67),Vector2.new(106,75),Vector2.new(98,53),Vector2.new(101,63),Vector2.new(99,58),Vector2.new(94,47),Vector2.new(98,47),Vector2.new(103,53),Vector2.new(101,123),Vector2.new(105,123),Vector2.new(109,123),Vector2.new(114,123),Vector2.new(118,123),Vector2.new(122,123),Vector2.new(101,94),Vector2.new(107,92),Vector2.new(111,93),Vector2.new(82,127),Vector2.new(80,120),Vector2.new(81,115),Vector2.new(81,111),Vector2.new(81,106),Vector2.new(79,101),Vector2.new(79,97),Vector2.new(66,93),Vector2.new(70,92),Vector2.new(74,92),Vector2.new(78,90),Vector2.new(83,88),Vector2.new(29,110),Vector2.new(33,110),Vector2.new(37,111),Vector2.new(42,112),Vector2.new(47,115),Vector2.new(49,119),Vector2.new(48,124),Vector2.new(44,125),Vector2.new(53,119),Vector2.new(57,115),Vector2.new(61,111),Vector2.new(40,94),Vector2.new(45,97),Vector2.new(50,99),Vector2.new(54,101),Vector2.new(58,103),Vector2.new(62,106),Vector2.new(66,109),Vector2.new(69,113),Vector2.new(73,115),Vector2.new(87,109),Vector2.new(93,109),Vector2.new(100,109),Vector2.new(105,110),Vector2.new(109,110),Vector2.new(113,110),Vector2.new(117,110),Vector2.new(121,110),Vector2.new(126,110),Vector2.new(131,110),Vector2.new(45,80),Vector2.new(45,75),Vector2.new(46,70),Vector2.new(46,64),Vector2.new(46,60),Vector2.new(46,56),Vector2.new(46,51),Vector2.new(46,47),Vector2.new(47,43),Vector2.new(47,38),Vector2.new(46,34),Vector2.new(44,30),Vector2.new(25,58),Vector2.new(31,58),Vector2.new(38,59),Vector2.new(34,58),Vector2.new(41,59),Vector2.new(51,58),Vector2.new(55,59),Vector2.new(59,58),Vector2.new(63,58),Vector2.new(67,58),Vector2.new(71,58),Vector2.new(71,79),Vector2.new(71,75),Vector2.new(72,70),Vector2.new(72,64),Vector2.new(70,54),Vector2.new(71,50),Vector2.new(71,46),Vector2.new(71,41),Vector2.new(71,36),Vector2.new(71,32),Vector2.new(132,75),Vector2.new(128,75),Vector2.new(123,75),Vector2.new(119,76),Vector2.new(115,77),Vector2.new(111,76),Vector2.new(93,78),Vector2.new(93,72),Vector2.new(96,42),Vector2.new(96,38),Vector2.new(96,34),Vector2.new(100,34),Vector2.new(105,34),Vector2.new(111,34),Vector2.new(117,34),Vector2.new(122,35),Vector2.new(127,35),Vector2.new(131,35),Vector2.new(135,35),Vector2.new(126,40),Vector2.new(126,46),Vector2.new(126,51),Vector2.new(127,55),Vector2.new(126,59),Vector2.new(128,63),Vector2.new(128,67),Vector2.new(128,71)}
}

local function getNearestStation()
    local HRP = GetHRP()
    if not HRP then return nil end

    local paintPuzzle = GetPath("Section3", "PaintPuzzle")
    if not paintPuzzle then return nil end

    local playerPos = HRP.Position
    local nearestStation = nil
    local shortestDistance = math.huge

    for name, points in pairs(StationPoints) do
        local stationModel = paintPuzzle:FindFirstChild(name)
        if stationModel and stationModel:FindFirstChild("Pad") then
            local pad = stationModel.Pad
            local padPos = pad:GetPivot().Position
            local distance = (playerPos - padPos).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                local remote = pad:FindFirstChild("Controls") and pad.Controls:FindFirstChild("Draw")
                if remote then
                    nearestStation = { Remote = remote, Points = points }
                end
            end
        end
    end
    return nearestStation
end

Temple:Button({
    Title = "Auto Draw",
    Callback = function()
        local nearestStation = getNearestStation()
        if nearestStation and nearestStation.Remote then
            for _, point in ipairs(nearestStation.Points) do
                nearestStation.Remote:FireServer(CFrame.new(), point, 0)
                task.wait(0.01)
            end
        else
            warn("Could not find a valid PaintStation nearby!")
        end
    end
})

local currentPillarIndex = 1
local totalPillars = 4

Temple:Button({
    Title = "Submit Paint",
    Callback = function()
        local HRP = GetHRP()
        if not HRP then return end

        local folder = GetPath("Section3", "MagicPillars")
        if not folder then return end

        local pillars = {}
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Model") and v.Name == "Pillar" then
                table.insert(pillars, v)
            end
        end

        table.sort(pillars, function(a, b)
            return a:GetFullName() < b:GetFullName()
        end)

        local targetPillar = pillars[currentPillarIndex]
        if targetPillar then
            local basePart = targetPillar:FindFirstChildWhichIsA("BasePart")
            if basePart then
                HRP.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)
            end
        end

        currentPillarIndex += 1
        if currentPillarIndex > totalPillars then
            currentPillarIndex = 1
        end
    end
})

Temple:Button({
    Title = "Collect Item & Fix Bow",
    Locked = false,
    Description = "",
    Callback = function()
        local function triggerPrompt(parentObject)
            if not parentObject then return end
            local prompt = parentObject:FindFirstChildOfClass("ProximityPrompt") or parentObject:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration)
                    prompt:InputHoldEnd()
                end
            end
        end

        local function teleportTo(targetObject)
            if not targetObject then return end
            local HRP = GetHRP()
            if not HRP then return end

            local targetCFrame
            if targetObject:IsA("BasePart") then
                targetCFrame = targetObject.CFrame
            elseif targetObject:IsA("Attachment") then
                targetCFrame = targetObject.WorldCFrame
            elseif targetObject:IsA("Model") then
                targetCFrame = targetObject:GetPivot()
            end

            if targetCFrame then
                HRP.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
            end
        end

        -- Collect Lantern Pieces
        local pieceFolder = GetPath("WHITE_FLAME_LANTERN", "PieceDnE")
        if pieceFolder then
            for _, item in ipairs(pieceFolder:GetChildren()) do
                teleportTo(item)
                triggerPrompt(item)
                task.wait(0.4)
            end
        end

        -- Place Ink
        local placeInk = GetPath("Section3", "PaintPuzzle", "Ingredients", "PlaceInkHere")
        if placeInk then
            teleportTo(placeInk)
            triggerPrompt(placeInk)
        end
    end
})

Temple:Section("ESP")

local espEnabled = false
local espObjects = {}
local espConnections = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    for _, conn in ipairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    espObjects = {}
    espConnections = {}
end

local function createESP(model, name)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "senzaiESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model
    table.insert(espObjects, highlight)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "senzaiBillboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model.HumanoidRootPart
    table.insert(espObjects, billboard)

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextColor3 = Color3.fromRGB(255, 255, 0)
    text.TextScaled = false
    text.TextSize = 13
    text.Font = Enum.Font.SourceSansBold
    text.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not espEnabled or not model.Parent then
            if billboard then billboard:Destroy() end
            if highlight then highlight:Destroy() end
            conn:Disconnect()
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - model.HumanoidRootPart.Position).Magnitude
            text.Text = name .. "\n[" .. math.floor(dist) .. "]"
        end
    end)
    table.insert(espConnections, conn)
end

Temple:Toggle({
    Title = "ESP Senzai",
    Default = false,
    Callback = function(s)
        espEnabled = s
        clearESP()
        if not s then return end

        local senzai = workspace.Section3.Monster:FindFirstChild("Senzai")
        if senzai then
            createESP(senzai, "Senzai")
        end
    end
})


local StreetTokyo = Window:CreateTab({
    Title = "Street Tokyo",
    Icon = "Building-2"
})

StreetTokyo:Button({
    Title = "Rescue Survivor",
    Callback = function()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart", 5)
        if not HRP then return end

        local npcFolder = workspace:FindFirstChild("Section4")
            and workspace.Section4:FindFirstChild("Rescue")
            and workspace.Section4.Rescue:FindFirstChild("NPCs")
        if not npcFolder then return end

        local poses = {}
        for _, obj in ipairs(npcFolder:GetChildren()) do
            if #poses >= 3 then break end
            if obj:IsA("Model") and obj.Name:lower():find("pose") then
                table.insert(poses, obj)
            end
        end

        local function getPrimaryPart(model)
            if not model then return nil end
            if model:IsA("Model") then
                return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            elseif model:IsA("BasePart") then
                return model
            end
            return nil
        end

        for _, pose in ipairs(poses) do
            local targetPart = getPrimaryPart(pose)
            if targetPart then
                HRP.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                for _, obj in ipairs(pose:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        fireproximityprompt(obj)
                    end
                end
                task.wait(0.1)
            end
        end

        local rescuePoint = workspace.Section4.Rescue:FindFirstChild("RescuePoint")
        if rescuePoint and rescuePoint:IsA("BasePart") then
            HRP.CFrame = rescuePoint.CFrame + Vector3.new(0, 3, 0)
        end
    end
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------
local isToggled = false
local mainTask = nil
local floatConnection = nil
local currentHoverCFrame = nil
local activeTween = nil
local isFlightActive = false

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- Calculate mathematically perfect aim direction with drop compensation
local function getPerfectAimDirection(bow, targetPart, fallbackRoot, arrowSpeed)
    if not targetPart then return Vector3.new(0, 1, 0) end
    
    local originPart = bow and (bow:FindFirstChild("Handle") or bow:FindFirstChild("Muzzle"))
    local originPos = originPart and originPart.Position or (fallbackRoot and fallbackRoot.Position)
    if not originPos then return Vector3.new(0, 1, 0) end

    local targetPos = targetPart.Position
    local speed = arrowSpeed or 300
    local distance = (targetPos - originPos).Magnitude
    local flightTime = distance / speed
    local gravity = Workspace.Gravity
    
    local dropCompensation = Vector3.new(0, 0.5 * gravity * (flightTime ^ 2), 0)
    local adjustedTarget = targetPos + dropCompensation

    local camera = Workspace.CurrentCamera
    if camera then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    end

    return (adjustedTarget - originPos).Unit
end

-- Smooth Tween Function
local function tweenTo(rootPart, targetCFrame, duration)
    if not rootPart or not rootPart.Parent then return end
    
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end

    local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    activeTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    activeTween:Play()
end

-- Equip SpiritBow from Backpack or Character
local function equipSpiritBow(character, humanoid)
    local bowInChar = character:FindFirstChild("SpiritBow")
    if bowInChar then return bowInChar end

    local bowInBackpack = LocalPlayer.Backpack:FindFirstChild("SpiritBow")
    if bowInBackpack and humanoid then
        humanoid:EquipTool(bowInBackpack)
        task.wait(0.2)
        return character:FindFirstChild("SpiritBow")
    end
    
    return nil
end

-- Hold position in mid-air
local function enableFloat(rootPart)
    if floatConnection then return end
    floatConnection = RunService.PreRender:Connect(function()
        if not isToggled or not rootPart or not rootPart.Parent then return end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        if currentHoverCFrame and (not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing) then
            rootPart.CFrame = currentHoverCFrame
        end
    end)
end

local function disableFloat()
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    currentHoverCFrame = nil
end

-- Find active weak point model
local function findActiveWeakPoint()
    local section4 = Workspace:FindFirstChild("Section4")
    if not section4 then return nil end

    local weakPointsFolder = section4:FindFirstChild("WeakPoints")
    if not weakPointsFolder then return nil end

    local pointsFolder = weakPointsFolder:FindFirstChild("Points")
    if not pointsFolder then return nil end

    for _, pointModel in ipairs(pointsFolder:GetChildren()) do
        local iconGui = pointModel:FindFirstChild("Icon", true)
        if iconGui and iconGui:IsA("BillboardGui") and iconGui.Enabled then
            local imageLabel = iconGui:FindFirstChildOfClass("ImageLabel")
            if imageLabel and imageLabel.Visible then
                return pointModel, iconGui
            end
        end
    end

    return nil
end

-- Check if specific secondary monsters are near a given position
local function areInterferingMonstersNearby(targetPosition, maxDistance)
    local section4 = Workspace:FindFirstChild("Section4")
    if not section4 then return false end

    local m2 = section4:FindFirstChild("Monster2")
    local m3 = section4:FindFirstChild("Monster3")
    local m4 = section4:FindFirstChild("Monster4")

    local checkList = {
        m2 and m2:FindFirstChild("Rin2"),
        m3 and m3:FindFirstChild("Tenome2"),
        m4 and m4:FindFirstChild("Tsukiya2")
    }

    maxDistance = maxDistance or 50

    for _, monster in ipairs(checkList) do
        if monster then
            local hrp = monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildOfClass("BasePart")
            local humanoid = monster:FindFirstChildOfClass("Humanoid")
            
            if hrp and (not humanoid or humanoid.Health > 0) then
                if (hrp.Position - targetPosition).Magnitude <= maxDistance then
                    return true
                end
            end
        end
    end

    return false
end

-- Fetch Boss references including Plane.009
local function getBossReferences()
    local section4 = Workspace:FindFirstChild("Section4")
    if not section4 then return nil end

    local bossMonster = section4:FindFirstChild("BossMonster")
    if not bossMonster then return nil end

    local enzukaiRyu = bossMonster:FindFirstChild("EnzukaiRyu")
    if not enzukaiRyu then return nil end

    local plane009 = enzukaiRyu:FindFirstChild("Plane.009")
    local hitBox = enzukaiRyu:FindFirstChild("Hitbox") or plane009
    local hitEvent = enzukaiRyu:FindFirstChild("HitEvent")
    local hrp = enzukaiRyu:FindFirstChild("HumanoidRootPart")
    local flightSFX = hrp and hrp:FindFirstChild("FlightSFX")

    return plane009, hitBox, hitEvent, flightSFX
end

--------------------------------------------------------------------------------
-- Sequence Automation Logic
--------------------------------------------------------------------------------

local function runCombinedAutomation()
    local hitEventConnection = nil

    local _, _, hitEvent, _ = getBossReferences()
    if hitEvent and hitEvent:IsA("RemoteEvent") then
        hitEventConnection = hitEvent.OnClientEvent:Connect(function()
            isFlightActive = true
        end)
    end

    while isToggled do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not rootPart or not humanoid then 
            task.wait(0.5)
            continue 
        end

        ------------------------------------------------------------------------
        -- STEP 1: Weak Points Phase
        ------------------------------------------------------------------------
        local activeModel, iconGui = findActiveWeakPoint()
        
        if activeModel and iconGui then
            local modelPos = activeModel:GetPivot().Position
            if areInterferingMonstersNearby(modelPos, 60) then
                task.wait(1)
                continue
            end

            local spiritBow = equipSpiritBow(character, humanoid)
            if spiritBow then
                local remoteEvent = spiritBow:FindFirstChild("RemoteEvent")
                if remoteEvent then
                    enableFloat(rootPart)

                    local eyeNames = {"EyeA", "EyeB", "EyeC", "EyeD", "EyeE"}
                    for _, eyeName in ipairs(eyeNames) do
                        if not isToggled then break end
                        
                        local targetEye = activeModel:FindFirstChild(eyeName)
                        if targetEye and targetEye:IsA("BasePart") then
                            while isToggled and targetEye.Transparency == 0 and iconGui.Enabled do
                                local eyePos = targetEye.Position
                                local standPos = targetEye.CFrame * CFrame.new(0, 30, 25)
                                
                                currentHoverCFrame = CFrame.lookAt(standPos.Position, eyePos)
                                rootPart.CFrame = currentHoverCFrame

                                remoteEvent:FireServer(0, true)
                                task.wait(1.50)

                                if targetEye and targetEye.Parent then
                                    local exactAimDirection = getPerfectAimDirection(spiritBow, targetEye, rootPart, 300)
                                    remoteEvent:FireServer(0, false, exactAimDirection)
                                end

                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end

        ------------------------------------------------------------------------
        -- STEP 2: Boss Phase (Using Plane.009 with underground Y positioning)
        ------------------------------------------------------------------------
        isFlightActive = false
        local plane009, hitBox, _, flightSFX = getBossReferences()

        if plane009 and areInterferingMonstersNearby(plane009.Position, 80) then
            task.wait(1)
            continue
        end

        if plane009 and plane009:IsA("BasePart") and not isFlightActive then
            local spiritBow = equipSpiritBow(character, humanoid)
            if spiritBow then
                local remoteEvent = spiritBow:FindFirstChild("RemoteEvent")
                if remoteEvent then
                    enableFloat(rootPart)

                    while isToggled and not isFlightActive do
                        local currentPlane, currentHitBox, _, currentFlightSFX = getBossReferences()

                        if currentFlightSFX and currentFlightSFX:IsA("Sound") and currentFlightSFX.IsPlaying then
                            isFlightActive = true
                            break
                        end

                        if not currentPlane or not currentPlane:IsA("BasePart") then
                            break
                        end

                        local targetHitBox = currentHitBox or currentPlane
                        local targetPos = targetHitBox.Position
                        
                        -- Position underneath the ground using -100 offset on Y
                        local undergroundPos = currentPlane.Position - Vector3.new(0, 100, 0)
                        local bossCFrame = CFrame.lookAt(undergroundPos, targetPos)
                        currentHoverCFrame = bossCFrame

                        tweenTo(rootPart, bossCFrame, 0.25)

                        remoteEvent:FireServer(0, true)

                        local elapsed = 0
                        while elapsed < 1.50 and isToggled and not isFlightActive do
                            task.wait(0.05)
                            elapsed = elapsed + 0.05

                            if currentPlane and currentPlane:IsA("BasePart") and targetHitBox then
                                local updatedUndergroundPos = currentPlane.Position - Vector3.new(0, 100, 0)
                                local updatedBossCFrame = CFrame.lookAt(updatedUndergroundPos, targetHitBox.Position)
                                currentHoverCFrame = updatedBossCFrame
                                tweenTo(rootPart, updatedBossCFrame, 0.1)
                            end

                            if currentFlightSFX and currentFlightSFX.IsPlaying then
                                isFlightActive = true
                                break
                            end
                        end

                        if not isToggled or isFlightActive then break end

                        if targetHitBox then
                            local exactAimDirection = getPerfectAimDirection(spiritBow, targetHitBox, rootPart, 300)
                            remoteEvent:FireServer(0, false, exactAimDirection)
                        end

                        task.wait(0.2)
                    end
                end
            end
        end

        ------------------------------------------------------------------------
        -- STEP 3: Safe Wait Position (30, 126, -2868) & Idle
        ------------------------------------------------------------------------
        disableFloat()

        if isToggled then
            local waitCFrame = CFrame.new(30, 126, -2868)
            rootPart.CFrame = waitCFrame

            repeat
                task.wait(0.5)
                if rootPart and rootPart.Parent then
                    rootPart.CFrame = waitCFrame
                end
                local nextModel, _ = findActiveWeakPoint()
            until not isToggled or nextModel ~= nil
        end
    end

    if hitEventConnection then
        hitEventConnection:Disconnect()
    end
    disableFloat()
end

--------------------------------------------------------------------------------
-- UI Binding
--------------------------------------------------------------------------------

local success, err = pcall(function()
    if type(StreetTokyo) == "table" and type(StreetTokyo.Toggle) == "function" then
        StreetTokyo:Toggle({
            Title = "Auto Enzukai",
            Locked = false,
            Description = "",
            Default = false,
            Callback = function(state)
                isToggled = state
                isFlightActive = false

                if isToggled then
                    mainTask = task.spawn(runCombinedAutomation)
                else
                    disableFloat()
                    if mainTask then
                        task.cancel(mainTask)
                        mainTask = nil
                    end
                end
            end
        })
    elseif type(StreetTokyo) == "function" then
        StreetTokyo({
            Title = "Auto Enzukai",
            Locked = false,
            Description = "",
            Default = false,
            Callback = function(state)
                isToggled = state
                isFlightActive = false

                if isToggled then
                    mainTask = task.spawn(runCombinedAutomation)
                else
                    disableFloat()
                    if mainTask then
                        task.cancel(mainTask)
                        mainTask = nil
                    end
                end
            end
        })
    end
end)

if not success then
    warn("UI Load Warning: " .. tostring(err))
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------
local isToggled = false
local mainTask = nil
local floatConnection = nil
local currentHoverCFrame = nil
local activeTween = nil

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- Smooth Tween Function
local function tweenTo(rootPart, targetCFrame, duration)
    if not rootPart or not rootPart.Parent then return end
    
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end

    local tweenInfo = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    activeTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    activeTween:Play()
end

-- Equip SpiritBow
local function equipSpiritBow(character, humanoid)
    local bowInChar = character:FindFirstChild("SpiritBow")
    if bowInChar then return bowInChar end

    local bowInBackpack = LocalPlayer.Backpack:FindFirstChild("SpiritBow")
    if bowInBackpack and humanoid then
        humanoid:EquipTool(bowInBackpack)
        task.wait(0.2)
        return character:FindFirstChild("SpiritBow")
    end
    
    return nil
end

-- Hold position & zero out physical momentum
local function enableFloat(rootPart)
    if floatConnection then return end
    floatConnection = RunService.PreRender:Connect(function()
        if not isToggled or not rootPart or not rootPart.Parent then return end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        if currentHoverCFrame and (not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing) then
            rootPart.CFrame = currentHoverCFrame
        end
    end)
end

local function disableFloat()
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    currentHoverCFrame = nil
end

-- Safely trigger ProximityPrompt
local function triggerPrompt(prompt)
    if not prompt or not prompt.Enabled then return false end

    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end
    return true
end

-- Check if ProximityPrompt exists and is enabled
local function checkPrompt(monsterModel, hrp)
    if hrp then
        local foundPrompt = hrp:FindFirstChildOfClass("ProximityPrompt") or monsterModel:FindFirstChildOfClass("ProximityPrompt", true)
        if foundPrompt and foundPrompt.Enabled and foundPrompt.Parent then
            return foundPrompt
        end
    end
    return nil
end

-- Check UI Boss Health AbsoluteSize (Triggered when width <= 0)
local function isBossHealthZero()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end

    local s4 = playerGui:FindFirstChild("S4")
    if not s4 then return false end

    local health = s4:FindFirstChild("Health")
    if not health then return false end

    local front = health:FindFirstChild("Front")
    if not front then return false end

    return front.AbsoluteSize.X <= 0
end

--------------------------------------------------------------------------------
-- Target Monster List
--------------------------------------------------------------------------------
local monsterTargets = {
    { folder = "Monster2", name = "Rin2" },
    { folder = "Monster3", name = "Tenome2" },
    { folder = "Monster4", name = "Tsukiya2" }
}

local function getMonsterReferences(targetInfo)
    local section4 = Workspace:FindFirstChild("Section4")
    if not section4 then return nil, nil, nil end

    local monsterFolder = section4:FindFirstChild(targetInfo.folder)
    if not monsterFolder then return nil, nil, nil end

    local model = monsterFolder:FindFirstChild(targetInfo.name)
    if not model then return nil, nil, nil end

    local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    local hitBox = model:FindFirstChild("Hitbox") or hrp

    return model, hrp, hitBox
end

--------------------------------------------------------------------------------
-- Continuous Attack & Sequence Logic
--------------------------------------------------------------------------------

local function runTripleMonsterSequence()
    while isToggled do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not rootPart or not humanoid then 
            task.wait(0.5)
            continue 
        end

        ------------------------------------------------------------------------
        -- STEP 1: Wait at Safe Position (30, 126, -2868) until Boss Health == 0
        ------------------------------------------------------------------------
        enableFloat(rootPart)
        local waitCFrame = CFrame.new(30, 126, -2868)

        while isToggled and not isBossHealthZero() do
            currentHoverCFrame = waitCFrame
            rootPart.CFrame = waitCFrame
            task.wait(0.3)
        end

        if not isToggled then break end

        ------------------------------------------------------------------------
        -- STEP 2: Fire Notification when condition is met
        ------------------------------------------------------------------------
        if Window and Window.Notify then
            Window:Notify({
                Title = "Kill Enzukai Ryu",
                Content = "Enzukai-Ryu defeated! Starting 3 Monsters sequence...",
                Duration = 5
            })
        end

        task.wait(0.5)

        ------------------------------------------------------------------------
        -- STEP 3: Sequence through 3 Monsters
        ------------------------------------------------------------------------
        for _, targetInfo in ipairs(monsterTargets) do
            if not isToggled then break end

            local monsterModel, hrp, hitBox = getMonsterReferences(targetInfo)

            if monsterModel and hrp and hitBox then
                -- Initial position 15 studs behind monster looking at Hitbox
                local standPos = (hrp.CFrame * CFrame.new(0, 0, 15)).Position
                local targetCFrame = CFrame.lookAt(standPos, hitBox.Position)
                rootPart.CFrame = targetCFrame
                currentHoverCFrame = targetCFrame
                tweenTo(rootPart, targetCFrame, 0.2)

                local promptInstance = nil
                local spiritBow = equipSpiritBow(character, humanoid)
                local remoteEvent = spiritBow and spiritBow:FindFirstChild("RemoteEvent")

                ----------------------------------------------------------------
                -- Continuous Attack Loop until ProximityPrompt appears
                ----------------------------------------------------------------
                local startTime = tick()

                while isToggled and not promptInstance and (tick() - startTime) < 25 do
                    promptInstance = checkPrompt(monsterModel, hrp)
                    if promptInstance then break end

                    if remoteEvent then
                        remoteEvent:FireServer(0, true)

                        local elapsed = 0
                        while elapsed < 1.50 and isToggled do
                            task.wait(0.05)
                            elapsed = elapsed + 0.05

                            if hrp and hrp:IsA("BasePart") and hitBox then
                                local updatedStandPos = (hrp.CFrame * CFrame.new(0, 0, 15)).Position
                                local updatedBackCFrame = CFrame.lookAt(updatedStandPos, hitBox.Position)
                                currentHoverCFrame = updatedBackCFrame
                                tweenTo(rootPart, updatedBackCFrame, 0.1)
                            end

                            promptInstance = checkPrompt(monsterModel, hrp)
                            if promptInstance then break end
                        end

                        if not isToggled or promptInstance then break end

                        local exactAimDirection = (hitBox.Position - rootPart.Position).Unit
                        remoteEvent:FireServer(0, false, exactAimDirection)

                        task.wait(0.2)
                    else
                        if hrp and hrp:IsA("BasePart") and hitBox then
                            local updatedStandPos = (hrp.CFrame * CFrame.new(0, 0, 20)).Position
                            local updatedBackCFrame = CFrame.lookAt(updatedStandPos, hitBox.Position)
                            currentHoverCFrame = updatedBackCFrame
                            tweenTo(rootPart, updatedBackCFrame, 0.1)
                        end
                        task.wait(0.1)
                    end

                    promptInstance = checkPrompt(monsterModel, hrp)
                end

                ----------------------------------------------------------------
                -- ProximityPrompt Trigger Loop
                ----------------------------------------------------------------
                if isToggled and promptInstance then
                    local promptStartTime = tick()

                    while isToggled and (tick() - promptStartTime) < 5 do
                        if not promptInstance or not promptInstance.Parent or not promptInstance.Enabled then
                            break -- Prompt activated/consumed!
                        end

                        if hrp and hrp:IsA("BasePart") then
                            rootPart.CFrame = hrp.CFrame
                            currentHoverCFrame = hrp.CFrame
                        end

                        triggerPrompt(promptInstance)
                        task.wait(0.15)
                    end
                end

                ----------------------------------------------------------------
                -- WAIT FOR TARGET TO BE DELETED / DESPAWNED FROM WORKSPACE
                ----------------------------------------------------------------
                local waitStart = tick()
                while isToggled and monsterModel and monsterModel.Parent and (tick() - waitStart) < 10 do
                    -- Keep player floating at the current spot while waiting for despawn
                    if hrp and hrp:IsA("BasePart") then
                        rootPart.CFrame = hrp.CFrame
                        currentHoverCFrame = hrp.CFrame
                    end
                    task.wait(0.2)
                end

                task.wait(0.3)
            end
        end

        break
    end

    disableFloat()
    isToggled = false
end

--------------------------------------------------------------------------------
-- UI Binding
--------------------------------------------------------------------------------

StreetTokyo:Toggle({
    Title = "Auto 3 Monsters",
    Locked = false,
    Description = "",
    Default = false,
    Callback = function(state)
        isToggled = state

        if isToggled then
            mainTask = task.spawn(runTripleMonsterSequence)
        else
            disableFloat()
            if mainTask then
                task.cancel(mainTask)
                mainTask = nil
            end
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- Settings & State Management
--------------------------------------------------------------------------------
local DODGE_WAIT_TIME = 4.5 -- Tagal ng stay sa safe spawn zone

local isToggled = false
local mainTask = nil
local floatConnection = nil
local positionTrackerConnection = nil
local currentHoverCFrame = nil
local activeTween = nil
local isDodging = false

--------------------------------------------------------------------------------
-- Object Caching System
--------------------------------------------------------------------------------
local cachedSection5 = nil
local cachedFinalForm = nil
local cachedRyujin = nil
local cachedHeadHitBox = nil
local cachedSpawnPoint = nil

local function updateCachedObjects()
	if not cachedSection5 or not cachedSection5.Parent then
		cachedSection5 = Workspace:FindFirstChild("Section5")
	end
	if not cachedSection5 then return end

	if not cachedSpawnPoint or not cachedSpawnPoint.Parent then
		cachedSpawnPoint = cachedSection5:FindFirstChild("TeleportAndSetSpawn")
	end

	if not cachedFinalForm or not cachedFinalForm.Parent then
		cachedFinalForm = cachedSection5:FindFirstChild("FinalForm")
	end
	if not cachedFinalForm then return end

	if not cachedRyujin or not cachedRyujin.Parent then
		cachedRyujin = cachedFinalForm:FindFirstChild("EnzukaiRyujin")
	end
	if not cachedRyujin then return end

	if not cachedHeadHitBox or not cachedHeadHitBox.Parent then
		local foundPart = cachedRyujin:FindFirstChild("HeadHitBox") 
			or cachedRyujin:FindFirstChild("Hitbox") 
			or cachedRyujin.PrimaryPart
		
		if foundPart and (foundPart:IsA("Part") or foundPart:IsA("BasePart")) then
			cachedHeadHitBox = foundPart
		end
	end
end

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

local function safeFireServer(remoteEvent, ...)
	if not remoteEvent or not remoteEvent.Parent then return end
	local success, err = pcall(function(...)
		remoteEvent:FireServer(...)
	end, ...)
	if not success then
		warn("Remote Error: " .. tostring(err))
	end
end

--------------------------------------------------------------------------------
-- Proper Aim Prediction Function (Velocity + Gravity Compensation)
--------------------------------------------------------------------------------
local function getPerfectAimDirection(bow, targetPart, fallbackRoot, arrowSpeed)
	if not targetPart or not targetPart.Parent then return Vector3.new(0, 1, 0) end
	
	local originPart = bow and (bow:FindFirstChild("Handle") or bow:FindFirstChild("Muzzle"))
	local originPos = originPart and originPart.Position or (fallbackRoot and fallbackRoot.Position)
	if not originPos then return Vector3.new(0, 1, 0) end

	local targetPos = targetPart.Position
	local speed = arrowSpeed or 300
	
	-- Kunin ang velocity ng target para mahulaan kung saan ito lilipat (Lead Shot)
	local targetVelocity = Vector3.zero
	if targetPart:IsA("BasePart") then
		targetVelocity = targetPart.AssemblyLinearVelocity
	end

	local distance = (targetPos - originPos).Magnitude
	local flightTime = distance / speed
	
	-- I-predict ang posisyon gamit ang velocity at travel time
	local predictedPosition = targetPos + (targetVelocity * flightTime)

	-- Gravity drop compensation
	local gravity = Workspace.Gravity
	local dropCompensation = Vector3.new(0, 0.5 * gravity * (flightTime ^ 2), 0)
	local adjustedTarget = predictedPosition + dropCompensation

	local camera = Workspace.CurrentCamera
	if camera then
		camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
	end

	return (adjustedTarget - originPos).Unit
end

local function tweenTo(rootPart, targetCFrame, duration)
	if not rootPart or not rootPart.Parent then return end
	
	if activeTween then
		activeTween:Cancel()
		activeTween = nil
	end

	local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	activeTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
	activeTween:Play()
end

local function equipSpiritBow(character, humanoid)
	local bowInChar = character:FindFirstChild("SpiritBow")
	if bowInChar then return bowInChar end

	local bowInBackpack = LocalPlayer.Backpack:FindFirstChild("SpiritBow")
	if bowInBackpack and humanoid then
		humanoid:EquipTool(bowInBackpack)
		task.wait(0.2)
		return character:FindFirstChild("SpiritBow")
	end
	
	return nil
end

local function enableFloat(rootPart)
	if floatConnection then return end
	floatConnection = RunService.PreRender:Connect(function()
		if not isToggled or not rootPart or not rootPart.Parent then return end

		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero

		if currentHoverCFrame and (not activeTween or activeTween.PlaybackState ~= Enum.PlaybackState.Playing) then
			rootPart.CFrame = currentHoverCFrame
		end
	end)
end

local function disableFloat()
	if floatConnection then
		floatConnection:Disconnect()
		floatConnection = nil
	end
	if activeTween then
		activeTween:Cancel()
		activeTween = nil
	end
	currentHoverCFrame = nil
end

local function findActiveWeakPoint()
	updateCachedObjects()
	if not cachedSection5 then return nil end

	local weakPointsFolder = cachedSection5:FindFirstChild("WeakPoints")
	if not weakPointsFolder then return nil end

	local pointsFolder = weakPointsFolder:FindFirstChild("Points")
	if not pointsFolder then return nil end

	for _, pointModel in ipairs(pointsFolder:GetChildren()) do
		local iconGui = pointModel:FindFirstChild("Icon", true)
		if iconGui and iconGui:IsA("BillboardGui") and iconGui.Enabled then
			local imageLabel = iconGui:FindFirstChildOfClass("ImageLabel")
			if imageLabel and imageLabel.Visible then
				return pointModel, iconGui
			end
		end
	end

	return nil
end

local function getTeleportSpawnCFrame()
	updateCachedObjects()
	if not cachedSpawnPoint then return nil end

	if cachedSpawnPoint:IsA("Part") or cachedSpawnPoint:IsA("BasePart") then
		return cachedSpawnPoint.CFrame
	elseif cachedSpawnPoint:IsA("Model") then
		return cachedSpawnPoint:GetPivot()
	end

	return nil
end

--------------------------------------------------------------------------------
-- X-Position Tracker (Triggers when X <= -200 or lower)
--------------------------------------------------------------------------------

local function startPositionTracker()
	if positionTrackerConnection then 
		positionTrackerConnection:Disconnect() 
		positionTrackerConnection = nil
	end

	positionTrackerConnection = RunService.Heartbeat:Connect(function()
		if not isToggled or isDodging then return end

		updateCachedObjects()
		if cachedHeadHitBox and (cachedHeadHitBox:IsA("Part") or cachedHeadHitBox:IsA("BasePart")) then
			local currentX = cachedHeadHitBox.Position.X
			
			if currentX <= -200 then
				isDodging = true

				local character = LocalPlayer.Character
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")
				local spawnCFrame = getTeleportSpawnCFrame()

				if rootPart and spawnCFrame then
					currentHoverCFrame = spawnCFrame
					rootPart.CFrame = spawnCFrame

					task.spawn(function()
						task.wait(DODGE_WAIT_TIME)
						isDodging = false
					end)
				else
					isDodging = false
				end
			end
		end
	end)
end

local function stopPositionTracker()
	if positionTrackerConnection then
		positionTrackerConnection:Disconnect()
		positionTrackerConnection = nil
	end
end

--------------------------------------------------------------------------------
-- Main Section 5 Loop
--------------------------------------------------------------------------------

local function runSection5Automation()
	startPositionTracker()

	while isToggled do
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if not rootPart or not humanoid then 
			task.wait(0.5)
			continue 
		end

		if isDodging then
			task.wait(0.1)
			continue
		end

		------------------------------------------------------------------------
		-- STEP 1: Weak Points Phase
		------------------------------------------------------------------------
		local activeModel, iconGui = findActiveWeakPoint()
		
		if activeModel and iconGui then
			local spiritBow = equipSpiritBow(character, humanoid)
			if spiritBow then
				local remoteEvent = spiritBow:FindFirstChild("RemoteEvent")
				if remoteEvent then
					enableFloat(rootPart)

					local eyeNames = {"EyeA", "EyeB", "EyeC", "EyeD", "EyeE"}
					local angleOffsets = {
						CFrame.new(0, 30, 25),
						CFrame.new(25, 30, 0),
						CFrame.new(-25, 30, 0),
						CFrame.new(0, 30, -25)
					}

					for _, eyeName in ipairs(eyeNames) do
						if not isToggled or isDodging then break end
						
						local targetEye = activeModel:FindFirstChild(eyeName)
						if targetEye and (targetEye:IsA("Part") or targetEye:IsA("BasePart")) then
							local offsetIndex = 1

							while isToggled and not isDodging and targetEye.Transparency == 0 and iconGui.Enabled do
								local eyePos = targetEye.Position
								local currentOffset = angleOffsets[offsetIndex]
								local standPos = targetEye.CFrame * currentOffset
								
								currentHoverCFrame = CFrame.lookAt(standPos.Position, eyePos)
								rootPart.CFrame = currentHoverCFrame

								safeFireServer(remoteEvent, 0, true)
								
								local elapsed = 0
								while elapsed < 1.50 and isToggled and not isDodging and targetEye.Transparency == 0 do
									task.wait(0.05)
									elapsed = elapsed + 0.05

									if targetEye and (targetEye:IsA("Part") or targetEye:IsA("BasePart")) then
										local updatedStand = targetEye.CFrame * currentOffset
										currentHoverCFrame = CFrame.lookAt(updatedStand.Position, targetEye.Position)
										rootPart.CFrame = currentHoverCFrame
									end
								end

								if not isToggled or isDodging then break end

								if targetEye and targetEye.Parent and targetEye.Transparency == 0 then
									local exactAimDirection = getPerfectAimDirection(spiritBow, targetEye, rootPart, 300)
									safeFireServer(remoteEvent, 0, false, exactAimDirection)
								end

								task.wait(0.2)

								if targetEye and targetEye.Transparency == 0 then
									offsetIndex = (offsetIndex % #angleOffsets) + 1
								end
							end
						end
					end
				end
			end
		else
			--------------------------------------------------------------------
			-- STEP 2: Boss HeadHitBox Phase
			--------------------------------------------------------------------
			updateCachedObjects()
			local headHitBox = cachedHeadHitBox

			if headHitBox and (headHitBox:IsA("Part") or headHitBox:IsA("BasePart")) then
				local spiritBow = equipSpiritBow(character, humanoid)
				if spiritBow then
					local remoteEvent = spiritBow:FindFirstChild("RemoteEvent")
					if remoteEvent then
						enableFloat(rootPart)

						while isToggled and not isDodging and not findActiveWeakPoint() and headHitBox and headHitBox.Parent do
							local rightSidePos = (headHitBox.CFrame * CFrame.new(15, 0, 0)).Position
							local rightSideCFrame = CFrame.lookAt(rightSidePos, headHitBox.Position)

							currentHoverCFrame = rightSideCFrame
							tweenTo(rootPart, rightSideCFrame, 0.25)

							safeFireServer(remoteEvent, 0, true)

							local elapsed = 0
							while elapsed < 1.50 and isToggled and not isDodging and not findActiveWeakPoint() do
								task.wait(0.05)
								elapsed = elapsed + 0.05

								if headHitBox and headHitBox.Parent then
									local updatedRightPos = (headHitBox.CFrame * CFrame.new(15, 0, 0)).Position
									local updatedCFrame = CFrame.lookAt(updatedRightPos, headHitBox.Position)
									currentHoverCFrame = updatedCFrame
									tweenTo(rootPart, updatedCFrame, 0.1)
								end
							end

							if not isToggled or isDodging or findActiveWeakPoint() then break end

							if headHitBox and headHitBox.Parent then
								local exactAimDirection = getPerfectAimDirection(spiritBow, headHitBox, rootPart, 300)
								safeFireServer(remoteEvent, 0, false, exactAimDirection)
							end

							task.wait(0.2)
						end
					end
				end
			else
				task.wait(0.5)
			end
		end

		task.wait(0.2)
	end

	stopPositionTracker()
	disableFloat()
end

--------------------------------------------------------------------------------
-- UI Binding
--------------------------------------------------------------------------------

local success, err = pcall(function()
	if type(StreetTokyo) == "table" and type(StreetTokyo.Toggle) == "function" then
		StreetTokyo:Toggle({
			Title = "Auto Enzukai Ryujin",
			Locked = false,
			Description = "Final Form",
			Default = false,
			Callback = function(state)
				isToggled = state
				isDodging = false

				if isToggled then
					mainTask = task.spawn(runSection5Automation)
				else
					stopPositionTracker()
					disableFloat()
					if mainTask then
						task.cancel(mainTask)
						mainTask = nil
					end
				end
			end
		})
	elseif type(StreetTokyo) == "function" then
		StreetTokyo({
			Title = "Auto Enzukai Ryujin",
			Locked = false,
			Description = "Final Form",
			Default = false,
			Callback = function(state)
				isToggled = state
				isDodging = false

				if isToggled then
					mainTask = task.spawn(runSection5Automation)
				else
					stopPositionTracker()
					disableFloat()
					if mainTask then
						task.cancel(mainTask)
						mainTask = nil
					end
				end
			end
		})
	end
end)

if not success then
	warn("UI Load Warning: " .. tostring(err))
end
