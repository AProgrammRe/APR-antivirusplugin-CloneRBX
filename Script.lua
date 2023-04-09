local toolbar = plugin:CreateToolbar("APr's AntiVirus")
local button = toolbar:CreateButton("Turn On/Off","Switch","")
local button2 = toolbar:CreateButton("Blacklisted script source.","","")

local on = false
button:SetActive(on)

local ui = script.Parent.ScreenGui
ui.Parent = game.CoreGui

local selectionservice = game:GetService('Selection')
local trustedscripts = {
	
}
local allservices = {
	'Workspace',
	'ReplicatedStorage',
	'ServerScriptService',
	'ServerStorage',
	'StarterGui',
	'StarterPack',
	'StarterPlayer',
	'ReplicatedFirst',
	'Lighting',
	'Teams',
	'SoundService',
	'Chat',
	'LocalizationService'
}
local foldforbl = nil
-- Functions

local function esc(x)
	return (x:gsub('%%', '%%%%')
		:gsub('^%^', '%%^')
		:gsub('%$$', '%%$')
		:gsub('%(', '%%(')
		:gsub('%)', '%%)')
		:gsub('%.', '%%.')
		:gsub('%[', '%%[')
		:gsub('%]', '%%]')
		:gsub('%*', '%%*')
		:gsub('%+', '%%+')
		:gsub('%-', '%%-')
		:gsub('%?', '%%?'))
end
local function scanobj(v) 
	if v:IsA('Script') then
		local source = v.Source:lower()
		if table.find(trustedscripts,v) or source:find('ignore for Antivirus') then
			warn("(Trusted) Skipping",v.Name)

		else

			warn("Scanning",v.Name)
			if v.ClassName ~= 'LocalScript' then
				local source = v.Source
				local newtextbutton = ui.Frame.Results.TextButton:Clone()
				newtextbutton.Name = 'ThreatText'
				if source:find('getfenv') then

					newtextbutton.Text = 'FOUND THREAT. getfenv() '..v.Name..' Click to select'
				elseif source:find('webhook') or string.find(source,'HttpService') or string.find(source,'PostAsync') then
					newtextbutton.Text = 'FOUND THREAT. Chance of a backdoor (http) '..v.Name..' Click to select'
				elseif source:find('require'..esc('(')) or string.find(source,"require"..esc('(')) then
					newtextbutton.Text = 'FOUND THREAT. require() '..v.Name
				elseif v.Name:lower():find('virus') then
					newtextbutton.Text = 'FOUND THREAT. Chance of a actual virus '..v.Name..' Click to select'
				elseif string.find(source,'RotateP') or string.find(source,'RotateV') then
					newtextbutton.Text = 'RotateV or RotateP. (Ruins the game)'
				elseif foldforbl then

					for i, v3 in pairs(foldforbl:GetChildren()) do
						if v3:IsA('Script') then
							if string.find(source,v.Source) and v ~= v3 then
								newtextbutton.Text = 'Found Blacklisted source '..v.Name

							end

						end

					end

				end
				newtextbutton.MouseButton1Click:Connect(function()
					selectionservice:Set({v})
				end)
				if newtextbutton.Text ~= 'Scanning...' then
					newtextbutton.Parent = ui.Frame.Results

				end
			elseif v:IsA('RotateP') then
				local newtextbutton = ui.Frame.Results.TextButton:Clone()
				newtextbutton.Name = 'ThreatText'
				newtextbutton.Parent = ui.Frame.Results
				newtextbutton.Text = 'RotateV or RotateP. (Ruins the game)'
				newtextbutton.MouseButton1Click:Connect(function()
					selectionservice:Set({v})
				end)


			end
		end
	elseif v:IsA('RotateP') then
		local newtextbutton = ui.Frame.Results.TextButton:Clone()
		newtextbutton.Name = 'ThreatText'
		newtextbutton.Parent = ui.Frame.Results
		newtextbutton.Text = 'RotateV or RotateP. (Ruins the game)'
		newtextbutton.MouseButton1Click:Connect(function()
			selectionservice:Set({v})
		end)

	end
end

local NotesWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	200,    -- Default width of the floating window
	300,    -- Default height of the floating window
	150,    -- Minimum width of the floating window (optional)
	150     -- Minimum height of the floating window (optional)
)


local NotesWidget = plugin:CreateDockWidgetPluginGui("Notes", NotesWidgetInfo)
NotesWidget.Title = "Blacklisted script source"
local NotesGui = script.Parent.BLSOURCE
NotesGui.Parent = NotesWidget
local on2 = false

--Events
button.Click:Connect(function()
	warn("WELCOME TO APR'S ANTIVIRUS PLUGIN")
	on = not on
	if on then
		warn('TURNING ON')
	elseif not on then
		warn('TURNING OFF')
	end
	ui.Enabled = on
	button:SetActive(on)
end)

local currentlyscanning = false
ui.Frame.G.MouseButton1Click:Connect(function()
	if currentlyscanning then
		warn('Currently doing a scan. You can only have one scan at a time')
	else
		currentlyscanning = true
		for i, v in pairs(ui.Frame.Results:GetChildren())  do
			if v:IsA('UIListLayout') or v.Name == 'TextButton' then
				if v:IsA('TextButton') then
					v.Text = 'Scanning...'
				end
			else
				
				v:Destroy()
			end
		end
		wait()
		local DELAY = 90
		for i, v2 in pairs(allservices) do
			for i, v in pairs(game:GetService(v2):GetDescendants()) do
				if i == DELAY then
					wait()
					DELAY += 90
				end
				scanobj(v)
			end

		end
		ui.Frame.Results.TextButton.Text = 'Finished'
		currentlyscanning = false
	end
	
	
end)
ui.Frame.TextButton.MouseButton1Click:Connect(function()
	for i, v in pairs(selectionservice:Get()) do
		if v:IsA('Script') or v:IsA('LocalScript') then
			table.insert(trustedscripts,#trustedscripts + 1,v)			
			local newtextbutton = ui.ForClone:Clone()
			newtextbutton.Parent = ui.Frame.Trusted
			newtextbutton.Text = v.Name
			newtextbutton.Active = true
			newtextbutton.Visible = true
			newtextbutton.MouseButton1Click:Connect(function()
				table.remove(trustedscripts,table.find(trustedscripts,v))
				
				newtextbutton:Destroy()
			end)
						
		end
	end
end)
ui.Frame.close.MouseButton1Click:Connect(function()
	ui.Enabled = not ui.Enabled
	button:SetActive(false)

end)
ui.Frame.M.MouseButton1Click:Connect(function()
	if currentlyscanning then
		warn('Currently doing a scan. You can only have one scan at a time')
	else
		currentlyscanning = true
		for i, v in pairs(ui.Frame.Results:GetChildren())  do
			if v:IsA('UIListLayout') or v.Name == 'TextButton' then
				if v:IsA('TextButton') then
					v.Text = 'Scanning...'
				end
			else

				v:Destroy()
			end
		end
		local selections = selectionservice:Get()

		for i, v2 in pairs(selections) do
			if v2:IsA('Model') then
				for i, v in pairs(v2:GetDescendants()) do
					scanobj(v)
				end
			end
		end
		ui.Frame.Results.TextButton.Text = 'Finished'
		currentlyscanning = false
	end
end)
NotesGui.TextButton.MouseButton1Click:Connect(function()
	local textb = NotesGui.TextBox
	if game.ServerStorage:FindFirstChild(textb.Text) then
		foldforbl = game.ServerStorage:FindFirstChild(textb.Text)
		warn('Success! You can add any script, disable it and add any code to find the BlackListed words in a source')
	else
		warn('Failed to find folder, '..textb.Text)
	end


end)
	button2.Click:Connect(function()
		--	on = not on
		--	NotesWidget.Enabled = on
		--	button:SetActive(on)
		warn('This system is still in development')
	end)
