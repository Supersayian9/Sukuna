

--// BUILD March 12, 2024 8:09 PM GMT+8 by i.am.an.agent

--// Settings
getgenv().MovesetSettings = {
	UltimateBar = {
		Enabled = true,
		Style = 3,
	}, -- Changes the appearance of your ultimate bar

	UltimateBarFont = {
		Enabled = true,
		Font = "Merriweather",
		Weight = "Regular",
		Style = "Normal",
	}, -- Changes the font of the text in your ultimate bar

	HotbarNumberFont = {
		Enabled = true,
		Font = "Arimo",
		Weight = "Regular",
		Style = "Normal",
	}, -- Changes the font of the numbering in your hotbar

	MoveNameFont = {
		Enabled = true,
		Font = "Sarpanch",
		Weight = "Thin",
		Style = "Normal",
	}, -- Changes the font of the move names in your hotbar

	MoveNames =	{
		["Normal Punch"] = "Strong Dismantle",
		["Consecutive Punches"] = "A Thousand Slashes",
		["Shove"] = "N/A",
		["Uppercut"] = "N/A",
	}
}

--// Services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

--// Paths
local localPlayer = players.LocalPlayer
local localChar = localPlayer.Character
local renderStepped = runService.RenderStepped
local stepped = runService.Stepped
local heartBeat = runService.Heartbeat

local kocAssets = repStorage.Resources:FindFirstChild("Sukuna") or game:GetObjects("rbxassetid://86452577533201")[1]
kocAssets.Parent = repStorage
kocAssets.Name = "Sukuna"
local heianAssets = kocAssets and kocAssets:FindFirstChild("Heian")
local particles = kocAssets and kocAssets:FindFirstChild("Particles")

spawn(function()
    local directory = "SlashyBoy"
    local foldername = "SlashyBoy"
    makefolder(foldername)
    local files = {
        "Chant1",
        "Chant2",
        "Chant3Slash",
        "DismantleFire",
        "DismantleFire2",
        "DismantleM1Hit",
        "DismantleM1Swing",
        "DismantleSwing",
        "Fuga",
        "GetLost",
        "Kai",
        "M1Hit1",
        "M1Hit2",
        "M1Hit4",
        "M1Swing1",
        "M1Swing2",
        "M1Swing4",
        "MalevolentShrineChime",
        "RightThere",
        "RyoikiTenkai",
        "Slashes",
        "WCSCast",
        "WCSCharge",
    }
    for i,v in pairs(files) do
        if not isfile(foldername .. "/" .. v .. ".mp3") then
            local Time = tick()
            local Interlude = request({
                Url = "https://github.com/skibiditoiletfan2007/" .. directory .. "/raw/main/" .. v .. ".mp3",
                Method = "GET"
            }).Body

            if Interlude then
                print("'" .. v .. "' Downloaded in "..string.format("%.2f", tick() - Time).."s.")
                writefile(foldername .. "/" .. v .. ".mp3", Interlude)
            else
                warn("'" .. v .. "' failed to load.")
            end
        end
    end
end)

--// Other
local settings = getgenv().MovesetSettings
local ultimateBar = settings and settings.UltimateBar
local moveNames = settings and settings.MoveNames or {
	["Normal Punch"] = "Strong DISMANTLE",
	["Consecutive Punches"] = "A Thousand Slashes",
	["Shove"] = "Gut Strike",
	["Uppercut"] = "Axe Kick",
}
local ultBarFont = settings and settings.UltimateBarFont
local hotbarNumFont = settings and settings.HotbarNumberFont
local moveNameFont = settings and settings.MoveNameFont

--// Functions
local function DestroySignals()
	for i,v in pairs(getgenv().Connections) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		end
	end
end

local function SetupSignals()
	if getgenv().Connections then
		DestroySignals()
	else
		getgenv().Connections = {}
	end
end

local function AddSignal(connection, name)
    print(name)
	if getgenv().Connections then
		getgenv().Connections[name or #getgenv().Connections + 1] = connection
		return connection
	end
end

local function getAsset(asset, properties)
	local special = {
		["CFrame"] = function(object, value)
			if object:IsA("BasePart") then
				object.CFrame = value
			elseif object:IsA("Model") and object.PrimaryPart then
				object:SetPrimaryPartCFrame(value)
			end
		end
	}
	local clonedAsset = asset:Clone()
	for i,v in pairs(properties) do
		if special[i] then
			special[i](clonedAsset, v)
		else
			clonedAsset[i] = v
		end
	end
	return clonedAsset
end

function emitAll(inst, amt, override)
	if not inst:IsA("ParticleEmitter") then
		for i,v in pairs(inst:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local finalamt = amt or 1
				local emitcount = override and finalamt or v:GetAttribute("EmitCount") or finalamt
				spawn(function()
					v:Emit(emitcount)
				end)
			end
		end
	else
		local finalamt = amt or 1
		local emitcount = override and finalamt or inst:GetAttribute("EmitCount") or finalamt
		spawn(function()
			inst:Emit(emitcount)
		end)
	end
end

local function changeName(tool)
	if moveNames[tool.Name] then
		tool:SetAttribute("FakeName", moveNames[tool.Name])
	end
end

function loadSound(instance, id)
    if instance and id then
        local SoundID = id
    
        local Sound = Instance.new("Sound")
        Sound.Parent = instance
        if table.find({"string", "number"}, typeof(id)) then
            Sound.SoundId = SoundID
        else
            for _,v in pairs(id) do
                Sound[_] = v
            end
        end
    
        local EndCon = nil
        EndCon = Sound.Ended:connect(function()
            if Sound and Sound.Parent ~= nil then
                Sound:Destroy()
            end
            return EndCon:Disconnect()
        end)
    
        return Sound
    end
    return nil
end

function loadAnim(animator, id, animType)
	if animator and id then
		local RawID = tostring(id):match("%d+")
		local AnimID = "rbxassetid://"..RawID
		local Anim = Instance.new("Animation")
		local LoadedAnim

		if animType then
			if animType == "Server" then
				Anim.AnimationId = "rbxassetid://0"
				LoadedAnim = animator:LoadAnimation(Anim)
				Anim.AnimationId = AnimID
			elseif animType == "Client" then
				Anim.AnimationId = AnimID
				LoadedAnim = animator:LoadAnimation(Anim)
				Anim.AnimationId = "rbxassetid://0"
			end
		else
			Anim.AnimationId = AnimID
			LoadedAnim = animator:LoadAnimation(Anim)
		end

		return LoadedAnim
	end
	return nil
end


function IsAnimPlaying(animator, id)
    for i,v in pairs(animator:GetPlayingAnimationTracks()) do
        if v.Animation.AnimationId:match(id) then
            return v
        end
    end
end

local function kingOfCurses(char)
	local parentPlayer = players:GetPlayerFromCharacter(char)
	local humanoid = char and char:WaitForChild("Humanoid", 1)
	local rootPart = char and char:WaitForChild("HumanoidRootPart", 1)
	local animator = humanoid and humanoid:WaitForChild("Animator", 1)
	if parentPlayer and humanoid and rootPart and animator then
		--// Variables
		local barImageIdTable = {
			[1] = getcustomasset("first.png"),
			[2] = getcustomasset("99096574333113.png"),
			[3] = getcustomasset("test.png"),
			[4] = getcustomasset("test2.png"),
		}
		local font = "Merriweather"
		local numberFont = "Arimo"
		local toolFont = "Sarpanch"
		local barImageId = barImageIdTable[ultimateBar.Style]

		--// Paths
		local playerGui = parentPlayer.PlayerGui

		local hotbar
		repeat renderStepped:Wait()
			for i,v in pairs(playerGui:GetDescendants()) do
				if v:IsA("Frame") and v.Name == "Hotbar" and v:FindFirstAncestor("Backpack") then
					hotbar = v
				end
			end
		until hotbar

		local ultBarColor
		repeat renderStepped:Wait()
			for i,v in pairs(playerGui:GetDescendants()) do
				if v:IsA("UIGradient") and v.Name == "Empty" and v:FindFirstAncestor("Bar") then
					ultBarColor = v
				end
			end
		until ultBarColor
		local ultBarFill = ultBarColor.Parent
		local ultBar = ultBarFill.Parent
		local ultBarGlow = ultBar.Parent.Glow
		local ultBarText = ultBarColor.Parent.Parent.Parent.Parent.TextLabel
		local ultBarText2 = ultBarColor.Parent.Parent.Parent.Parent.Ult

		--// Functions
		local function Windup()
		    local windup = particles and particles:FindFirstChild("Windup") and particles.Windup:Clone()
            windup.Parent = workspace.Thrown
            local weld = Instance.new("Weld", windup)
            weld.Part0 = windup
            weld.Part1 = rootPart
            emitAll(windup)
            game.Debris:AddItem(windup, 3)
		end
		
		local function Aura()
		    local windup = particles and particles:FindFirstChild("Aura") and particles.Aura:Clone()
            windup.Parent = workspace.Thrown
            local weld = Instance.new("Weld", windup)
            weld.Part0 = windup
            weld.Part1 = rootPart
            emitAll(windup)
            game.Debris:AddItem(windup, 3)
		end
		
		local function changeImageId(imageObjects, assetId)
			for i,v in pairs(imageObjects) do
				v.Image = assetId
			end
		end

		local function toFontEnum(variable, enum)
			if typeof(variable) == "string" then
				return enum[variable]
			elseif typeof(variable) == "EnumItem" then
				return variable
			end
		end

		local function changeFontFace(textObjects: {Instance}, fontSettings)
			local font = fontSettings.Font
			local weight = toFontEnum(fontSettings.Weight, Enum.FontWeight)
			local style = toFontEnum(fontSettings.Style, Enum.FontStyle)
			for i,v in pairs(textObjects) do
				v.FontFace = Font.fromName(font, weight, style)
			end
		end

		local function disableHeianArms()
			local check = workspace.Thrown:FindFirstChild("HeianArmsModel")
			if check then
				check:Destroy()
			end
		end

		local function enableHeianArms()
			disableHeianArms()
			local torso = char:FindFirstChild("Torso")
			if torso then
				local armTable = {
					["Left Arm"] = {
						Color = char:FindFirstChild("Left Arm") and char:FindFirstChild("Left Arm").Color or Color3.new(1,1,1),
						Mesh = nil,
					},
					["Right Arm"] = {
						Color = char:FindFirstChild("Right Arm") and char:FindFirstChild("Right Arm").Color or Color3.new(1,1,1),
						Mesh = nil,
					}
				}
				for i,v in pairs(char:GetChildren()) do
					if v:IsA("CharacterMesh") then
						local bodypart = v.BodyPart == Enum.BodyPart.RightArm and "Right Arm" or v.BodyPart == Enum.BodyPart.LeftArm and "Left Arm"
						if bodypart then
							if armTable[bodypart] then
								armTable[bodypart].Mesh = v
							end
						end
					elseif v:IsA("Shirt") then
						for _, bodypart in {"Left Arm", "Right Arm"} do
							if armTable[bodypart] then
								armTable[bodypart][v.ClassName] = v
							end
						end
					end
				end
				local arms = heianAssets.HeianArmsModel:Clone()
				arms.Parent = workspace.Thrown
				arms:ScaleTo(1.2)
				for i,v in pairs(arms:GetChildren()) do
					if armTable[v.Name] then
						v.Color = armTable[v.Name].Color
						if armTable[v.Name].Mesh then
							armTable[v.Name].Mesh:Clone().Parent = arms
						end
						if armTable[v.Name].Shirt then
							armTable[v.Name].Shirt:Clone().Parent = arms
						end
					end
				end
				local torsoWeld = Instance.new("Weld", arms)
				torsoWeld.Part0 = arms.Torso
				torsoWeld.Part1 = torso
			end
		end

        local function HitDetection(hitchar)
            local humanoid = hitchar:WaitForChild("Humanoid", 1)
            local Root = hitchar:WaitForChild("HumanoidRootPart", 1)
            local oldhealth = humanoid.Health
            local LastConsecPunchTick = tick()
            if getgenv().Connections and getgenv().Connections[hitchar.Name] then
                getgenv().Connections[hitchar.Name]:Disconnect()
            end
            AddSignal(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if hitchar:GetAttribute("LastHit") == char.Name then
                    local real = oldhealth - humanoid.Health
                    if humanoid.Health < oldhealth then
                        local IsConsecPunch = IsAnimPlaying(animator, 10466974800)
                        if IsConsecPunch then
                            if not rootPart:FindFirstChild("Slashes") then
                                local Slashes = loadSound(rootPart, getcustomasset("SlashyBoy/Slashes.mp3"))
                                Slashes.Name = "Slashes"
                                Slashes.Volume = 5
                                Slashes:Play()
                                repeat
                                    runService.RenderStepped:Wait()
                                until not IsConsecPunch.IsPlaying or Slashes.TimePosition >= 2.6
                                tweenService:Create(Slashes, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                    Volume = 0
                                }):Play()
                                game.Debris:AddItem(Slashes, 0.3)
                                local DismantleFire = loadSound(rootPart, getcustomasset("SlashyBoy/DismantleFire.mp3"))
                                DismantleFire.Volume = 5
                                DismantleFire:Play()
                            end
                        end 
                    end
                    oldhealth = humanoid.Health
                end
            end), hitchar.Name)
        end

		local animFunctions = {
		    ["10468665991"] = function(track) -- Normal Punch
		        if track then
					track:AdjustWeight(-9999999, 0)
				end
				local CustomTrack = loadAnim(animator, 134494086123052)
        		CustomTrack:Play()
        		CustomTrack:AdjustSpeed(0.6)
        		CustomTrack.TimePosition = 2.7
        		task.delay(1, CustomTrack.Stop, CustomTrack, 0.3)
        		
        		task.delay(0.65, function()
                    spawn(function()
                        local DismantleFire = loadSound(rootPart, getcustomasset("SlashyBoy/DismantleFire.mp3"))
                        DismantleFire.Volume = 5
                        DismantleFire:Play()
                    end)

                    spawn(function()
                        local DismantleFire2 = loadSound(rootPart, getcustomasset("SlashyBoy/DismantleFire2.mp3"))
                        DismantleFire2.Volume = 2
                        DismantleFire2:Play()
                        DismantleFire2.TimePosition = 0.5
                    end)
                    
        		    local dismantle = particles and particles:FindFirstChild("Dismantle")
                    local highlightedSlashes = dismantle and dismantle:FindFirstChild("HighlightedSlashes") and dismantle.HighlightedSlashes:Clone()
                    local dismantleSlash = dismantle and dismantle:FindFirstChild("DismantleProjectile") and dismantle.DismantleProjectile:Clone()
                    
                    highlightedSlashes.Parent = workspace.Thrown
                    highlightedSlashes:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0,1,-15))
                    game.Debris:AddItem(highlightedSlashes, 0.05)
                    
                    dismantleSlash.Parent = workspace.Thrown
                    dismantleSlash.CFrame = rootPart.CFrame * CFrame.new(0,1,-15)
                    tweenService:Create(dismantleSlash, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    	CFrame = dismantleSlash.CFrame * CFrame.new(0,0,-1500)
                    }):Play();
                    game.Debris:AddItem(dismantleSlash, 6)
        		end)
		    end,
			["10466974800"] = function(track) -- Consecutive Punches
			    if track then
					track:AdjustWeight(-9999999, 0)
			    end
				Windup()
				Aura()
				local CustomTrack = loadAnim(animator, 116753755471636)
                CustomTrack:Play()
                CustomTrack.TimePosition = 0.75
                CustomTrack:AdjustSpeed(2)
                task.delay(0.5, function()
                    CustomTrack:Stop(0)
                    local CustomTrack = loadAnim(animator, 116153572280464)
                    CustomTrack:Play()
                    CustomTrack:AdjustSpeed(2)
                    task.delay(1, function()
                        CustomTrack:Stop()
                        local CustomTrack = loadAnim(animator, 114095570398448)
                        CustomTrack:Play()
                    end)
                end)
			end,
        	["12510170988"] = function(track) -- Uppercut
				print('hi')
			end,
			["12447707844"] = function(track) -- Ultimate
				if track then
					track:AdjustWeight(-9999999, 0)
				end
				local CustomTrack = loadAnim(animator, 14498295360)
				CustomTrack:Play()
				CustomTrack:AdjustSpeed(2)

				local kamutoke = getAsset(heianAssets.Kamutoke, {Parent = workspace.Thrown})
				kamutoke.Handle.Weld.Part0 = char["Left Arm"]
				game.Debris:AddItem(kamutoke, 0.6)

				task.delay(0.6, function()
					CustomTrack:AdjustSpeed(0)

					local kamutokeExplosion = getAsset(particles.Kamutoke.Lightning, {Parent = workspace.Thrown, CFrame = rootPart.CFrame * CFrame.new(0, -2.5, 0)})
					emitAll(kamutokeExplosion)
					game.Debris:AddItem(kamutokeExplosion, 2)

					local kamutokeExplosionGround = getAsset(particles.Kamutoke.LightningGround, {Parent = workspace.Thrown, CFrame = rootPart.CFrame * CFrame.new(0, -2.5, 0)})
					emitAll(kamutokeExplosionGround)
					game.Debris:AddItem(kamutokeExplosionGround, 2)

					local CCE = Instance.new("ColorCorrectionEffect", game.Lighting)
					CCE.Brightness = 1
					CCE.Enabled = true

					local Highlight = Instance.new("Highlight", char)
					Highlight.FillTransparency = 0
					Highlight.FillColor = Color3.new(0,0,0)
					Highlight.Enabled = true

					task.wait(0.025)
					CCE.TintColor = Color3.new(0,0,0)
					Highlight.FillColor = Color3.new(1,1,1)

					task.wait(0.025)
					CCE:Destroy()
					Highlight:Destroy()
					CustomTrack:Stop(0)
					local CustomTrack = loadAnim(animator, 131177495882827)
					CustomTrack:Play()
					task.wait(0.7)
					CustomTrack:AdjustSpeed(0)
					task.wait(1.5)
					CustomTrack:Stop(0.5)
				end)
			end,
		}

		--// Init
		SetupSignals()

		char:SetAttribute("UltimateName", "INCARNATION")

		ultBarColor.Rotation = 90
		ultBarColor.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		})

		if ultimateBar.Enabled then
			changeImageId({ultBarFill, ultBar, ultBarGlow}, barImageId)
		else
			changeImageId({ultBarFill, ultBar}, "rbxassetid://7884720727")
			changeImageId({ultBarGlow}, "rbxassetid://7885533165")
		end
		if ultBarFont.Enabled then
			changeFontFace({ultBarText, ultBarText.TextLabel, ultBarText2, ultBarText2.TextLabel}, ultBarFont)
		else
			changeFontFace({ultBarText, ultBarText.TextLabel, ultBarText2, ultBarText2.TextLabel}, {
				Font = "Balthazar",
				Weight = "Bold",
				Style = "Italic",
			})
		end

		for i, v in pairs(hotbar:GetChildren()) do
			local base = v:FindFirstChild("Base")
			local number = base and base:FindFirstChild("Number")
			local toolName = base and base:FindFirstChild("ToolName")
			if number then
				if hotbarNumFont.Enabled then
					number.TextWrapped = false
					number.Number.TextWrapped = false
					changeFontFace({number, number.Number}, hotbarNumFont)
				else
					number.TextWrapped = true
					number.Number.TextWrapped = true
					changeFontFace({number, number.Number}, {
						Font = "SourceSansPro",
						Weight = "Bold",
						Style = "Normal",
					})
				end
			end
			if toolName then
				if moveNameFont.Enabled then
					changeFontFace({toolName}, moveNameFont)
				else
					changeFontFace({toolName}, {
						Font = "SourceSansPro",
						Weight = "Regular",
						Style = "Normal",
					})
				end
			end
		end

		for _, tool in pairs(parentPlayer.Backpack:GetChildren()) do
			changeName(tool)
		end

        for i,v in pairs(workspace.Live:GetChildren()) do
            if v ~= char then
                HitDetection(v)
            end
        end

		--// Connections
        AddSignal(workspace.DescendantAdded:connect(function(obj)
			if obj:IsA("Sound") then
				local deleteID = {
					"10467680476",
                    "7556019578",
                    "10457021115",
				}
				local id = obj.SoundId:match("%d+")
                if not id then
                    repeat
                        id = obj.SoundId:match("%d+")
                        task.wait()
                    until id
                end
				if table.find(deleteID, id) then
					obj.Volume = 0
                    obj:Stop()
                    runService.RenderStepped:Wait()
                    obj:Destroy()
				end
			end
		end))

		AddSignal(char:GetAttributeChangedSignal("Ulted"):connect(function()
			local ulted = char:GetAttribute("Ulted")
			if ulted then
				task.delay(0.625, function()
					char:ScaleTo(1.2)
					enableHeianArms()
                    for i,v in pairs(char:GetDescendants()) do
                        if table.find({"Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}, v.Name) then
                            v.Massless = true
                        end
                    end
				end)
			else
				if char:FindFirstChild("Counter") then
					char.Counter:GetPropertyChangedSignal("Parent"):Wait()
				end
				char:ScaleTo(1)
				disableHeianArms()
                for i,v in pairs(char:GetDescendants()) do
                    if table.find({"Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}, v.Name) then
                        v.Massless = false
                    end
                end
			end
		end))

		AddSignal(parentPlayer.Backpack.ChildAdded:connect(function(tool)
			changeName(tool)
		end))

		AddSignal(char.DescendantAdded:connect(function(obj)
			if obj:IsA("Sound") then
				local deleteID = {
					"14762034452",
				}
				local id = obj.SoundId:match("%d+")
				if table.find(deleteID, id) then
					obj.Volume = 0
				end
            elseif obj:IsA("Accessory") then
                if obj.Name == "BarrageBind" then
                    obj:SetAttribute("Times", nil)
                end
			end
		end))

		AddSignal(animator.AnimationPlayed:connect(function(track)
			local ID = track.Animation.AnimationId:match("%d+")
			if animFunctions[ID] then
				animFunctions[ID](track)
			end
		end))

		--// End
        print('ok')

        for i,v in pairs(char:GetDescendants()) do
			if table.find({"Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}, v.Name) then
                v.Massless = false
			end
        end
	end 
end

--// Init
kingOfCurses(localChar)
