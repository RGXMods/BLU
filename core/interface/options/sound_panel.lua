--=====================================================================================
-- BLU - interface/options/sound_panel.lua
-- Sound selection panel for events
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local BLU = _G["BLU"]

local SoundPanel = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sound_panel"] = SoundPanel

local EVENT_MODULE_MAP = {
	honorrank = "honor",
	renownrank = "renown",
	delvecompanion = "delve",
	questaccept = "quest",
	questturnin = "quest",
	questprogress = "quest",
	achievementprogress = "achievement",
	petcapture = "battlepet",
	delvelifelost = "delve",
	delvelifegained = "delve",
	housingxpgained = "housing",
	housingleveledup = "housing",
	housingrewardsreceived = "housing",
	housingdecorcollected = "housing",
}

local function CreateSoundDropdown(parent, eventType, label, yOffset, soundType)
	local actualEventType = soundType or eventType
	BLU:PrintDebug("[Options/SoundPanel] Creating sound dropdown for '" .. tostring(actualEventType) .. "'")

	local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
	container:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
	container:SetHeight(68)
	container:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
	container:SetBackdropColor(0.08, 0.11, 0.15, 0.92)
	container:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

	local dropdownLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dropdownLabel:SetPoint("TOPLEFT", 10, -6)
	dropdownLabel:SetPoint("RIGHT", -10, 0)
	dropdownLabel:SetJustifyH("LEFT")
	dropdownLabel:SetTextColor(1.0, 0.82, 0.18)
	dropdownLabel:SetText(label)

	local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	currentSound:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -2)
	currentSound:SetPoint("RIGHT", -10, 0)
	currentSound:SetJustifyH("LEFT")
	currentSound:SetTextColor(0.02, 0.87, 0.98)
	currentSound:SetWordWrap(false)
	if currentSound.SetMaxLines then
		currentSound:SetMaxLines(1)
	end

	local function getVolume()
		return (BLU.db and BLU.db.soundVolumes and BLU.db.soundVolumes[actualEventType]) or "medium"
	end

	local function setVolume(volume)
		if not BLU.db then return end
		BLU.db.soundVolumes = BLU.db.soundVolumes or {}
		BLU.db.soundVolumes[actualEventType] = volume
		BLU:PrintDebug("[Options/SoundPanel] Set volume for '" .. tostring(actualEventType) .. "' to '" .. tostring(volume) .. "'")
	end

	local volumeControl = CreateFrame("Frame", nil, container)
	volumeControl:SetHeight(18)

	local volButton = CreateFrame("Button", nil, volumeControl)
	volButton:SetAllPoints(volumeControl)
	volButton:SetHeight(18)

	local volLabel = volumeControl:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	volLabel:SetTextColor(0.70, 0.78, 0.86)
	volLabel:SetPoint("TOP", volButton, "BOTTOM", 0, 2)
	volLabel:Hide()

	volButton:SetScript("OnEnter", function() volLabel:Show() end)
	volButton:SetScript("OnLeave", function() volLabel:Hide() end)

	local volTrack = volumeControl:CreateTexture(nil, "ARTWORK")
	volTrack:SetHeight(4)
	volTrack:SetPoint("LEFT", volButton, "LEFT", 0, 0)
	volTrack:SetPoint("RIGHT", volButton, "RIGHT", 0, 0)
	volTrack:SetPoint("CENTER", volButton, "CENTER", 0, 0)
	volTrack:SetColorTexture(0.14, 0.20, 0.28, 1)

	local volFill = volumeControl:CreateTexture(nil, "ARTWORK")
	volFill:SetHeight(4)
	volFill:SetPoint("LEFT", volTrack, "LEFT", 0, 0)
	volFill:SetColorTexture(unpack(BLU.Modules.design.Colors.Primary))

	local volThumb = volumeControl:CreateTexture(nil, "ARTWORK")
	volThumb:SetSize(8, 8)
	volThumb:SetTexture("Interface\\Buttons\\WHITE8x8")
	volThumb:SetVertexColor(1, 1, 1, 1)

	local function applyVolume(volume)
		if volume == "low" then
			-- nothing
		elseif volume == "high" then
			-- nothing
		else
			volume = "medium"
		end
		setVolume(volume)

		local function updateVisuals()
			local trackWidth = volTrack:GetWidth()
			if trackWidth < 1 then return false end
			local pct = 0.50
			if volume == "low" then
				pct = 0.15
			elseif volume == "high" then
				pct = 0.85
			end
			local fillW = math.max(4, trackWidth * pct)
			volFill:SetWidth(fillW)
			volThumb:ClearAllPoints()
			volThumb:SetPoint("CENTER", volTrack, "LEFT", fillW, 0)
			volLabel:SetText(volume:gsub("^%l", string.upper))
			return true
		end

		if not updateVisuals() then
			volumeControl:SetScript("OnUpdate", function()
				if updateVisuals() then
					volumeControl:SetScript("OnUpdate", nil)
				end
			end)
		end
	end

	volButton:SetScript("OnMouseDown", function(self)
		local cursorX = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		local left = self:GetLeft() and (self:GetLeft() * scale) or 0
		local width = math.max(1, (self:GetWidth() or 1) * scale)
		local percent = math.max(0, math.min(1, (cursorX - left) / width))
		if percent < 0.34 then
			applyVolume("low")
		elseif percent > 0.66 then
			applyVolume("high")
		else
			applyVolume("medium")
		end
	end)

	volButton:SetScript("OnMouseWheel", function()
		local current = getVolume()
		if current == "low" then
			applyVolume("medium")
		elseif current == "medium" then
			applyVolume("high")
		else
			applyVolume("low")
		end
	end)
	volButton:EnableMouseWheel(true)

	applyVolume(getVolume())
	volumeControl:Hide()

	local function isBluVolumeSelection(selectionValue)
		if selectionValue == "random" then
			return false -- random always plays at medium; no volume slider needed
		end
		if selectionValue == "None" then
			return false
		end
		if not selectionValue or selectionValue == "default" then
			return true
		end
		if type(selectionValue) ~= "string" or selectionValue:match("^external:") then
			return false
		end
		if not (BLU.SoundRegistry and BLU.SoundRegistry.GetSound) then
			return false
		end
		local soundInfo = BLU.SoundRegistry:GetSound(selectionValue)
		if not soundInfo then
			return false
		end
		return soundInfo.hasVolumeVariants == true
	end

	local function updateSoundControlMode(selectionValue)
		local showVolume = isBluVolumeSelection(selectionValue)

		if showVolume then
			applyVolume(getVolume())
			volumeControl:Show()
		else
			volumeControl:Hide()
		end

		return showVolume
	end

	local testBtn = BLU.Modules.design:CreateButton(container, "Test", 60, 22)
	testBtn:SetScript("OnClick", function(self)
		BLU:PrintDebug("Test button clicked for event: " .. actualEventType)
		local selectedSound = BLU.db and BLU.db.selectedSounds and BLU.db.selectedSounds[actualEventType]
		BLU:PrintDebug("Selected sound is: " .. tostring(selectedSound))

		self:SetText("Playing...")
		self:Disable()

		if BLU.PlayCategorySound then
			BLU:PlayCategorySound(actualEventType)
		elseif BLU.Modules.registry and BLU.Modules.registry.PlayCategorySound then
			BLU.Modules.registry:PlayCategorySound(actualEventType)
		end

		C_Timer.After(2, function()
			self:SetText("Test")
			self:Enable()
		end)
	end)

	local dropdown = CreateFrame("Frame", "BLUDropdown_" .. actualEventType, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", currentSound, "BOTTOMLEFT", -16, -5)
	UIDropDownMenu_SetWidth(dropdown, 220)
	dropdown:SetAlpha(0)
	dropdown:SetScale(0.01)

	local dropdownButton = CreateFrame("Button", nil, container, "BackdropTemplate")
	dropdownButton:SetPoint("TOPLEFT", currentSound, "BOTTOMLEFT", 0, -5)
	dropdownButton:SetHeight(22)
	dropdownButton:SetWidth(220)
	dropdownButton:SetBackdrop(BLU.Modules.design.Backdrops.Button)
	dropdownButton:SetBackdropColor(0.10, 0.14, 0.19, 0.96)
	dropdownButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
	dropdownButton:RegisterForClicks("LeftButtonUp")

	local dropdownButtonLabel = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	dropdownButtonLabel:SetPoint("LEFT", 8, 0)
	dropdownButtonLabel:SetPoint("RIGHT", -18, 0)
	dropdownButtonLabel:SetJustifyH("LEFT")
	dropdownButtonLabel:SetTextColor(0.84, 0.84, 0.84, 1)

	local dropdownArrow = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	dropdownArrow:SetPoint("RIGHT", -6, 0)
	dropdownArrow:SetText("v")
	dropdownArrow:SetTextColor(0.70, 0.78, 0.86, 1)

	dropdownButton:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
	end)
	dropdownButton:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
	end)
	dropdownButton:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
	end)

	local function LayoutControls(showVolume)
		dropdownButton:ClearAllPoints()
		volumeControl:ClearAllPoints()
		testBtn:ClearAllPoints()

		dropdownButton:SetPoint("LEFT", container, "LEFT", 10, 0)
		dropdownButton:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)
		dropdownButton:SetWidth(220)

		testBtn:SetPoint("RIGHT", container, "RIGHT", -10, 0)
		testBtn:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)

	if showVolume then
		volumeControl:SetPoint("CENTER", dropdownButton, "CENTER", 0, 0)
		volumeControl:SetPoint("LEFT", dropdownButton, "RIGHT", 12, 0)
		volumeControl:SetPoint("RIGHT", testBtn, "LEFT", -12, 0)
		volumeControl:Show()
		applyVolume(getVolume())
		else
			volumeControl:Hide()
		end

		UIDropDownMenu_SetWidth(dropdown, 220)
	end

	dropdown.currentSound = currentSound
	dropdown.currentButtonLabel = dropdownButtonLabel
	dropdown.eventId = actualEventType

	UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
		local MAX_SOUNDS_PER_MENU_PAGE = 24
		local MENU_LIST_MIN_WIDTH = 140
		local MENU_LIST_MAX_WIDTH = 460
		local MENU_TEXT_PADDING = 42
		local MENU_ARROW_PADDING = 18
		local MENU_PREVIEW_PADDING = 42
		local MENU_RIGHT_PADDING = 8
		level = level or 1

		if not BLU.db then return end
		BLU.db.selectedSounds = BLU.db.selectedSounds or {}

		local dd = BLU.Modules.dropdown

		local function getDropDownListFrame(levelToUse)
			return dd:GetListFrame(levelToUse)
		end

		local function shortenLabel(text, maxChars)
			return dd:ShortenLabel(text, maxChars)
		end

		local function trimSoundNameForSubmenu(soundName, parentLabel)
			if type(soundName) ~= "string" then
				return ""
			end

			if type(parentLabel) ~= "string" or parentLabel == "" then
				return soundName
			end

			local escapedParent = string.gsub(parentLabel, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
			local withoutDashPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*%-%s*", "")
			if withoutDashPrefix ~= soundName then
				return withoutDashPrefix
			end

			local withoutColonPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*:%s*", "")
			if withoutColonPrefix ~= soundName then
				return withoutColonPrefix
			end

			return soundName
		end

		-- Keep level 1 aligned with the parent dropdown, but let nested menus
		-- size closer to their actual content width.
		local BASE_MIN_WIDTH = math.floor(dropdown:GetWidth())
		if BASE_MIN_WIDTH < 100 then BASE_MIN_WIDTH = 260 end

		local function getMinWidthForLevel(levelToUse)
			if (levelToUse or 1) <= 1 then
				return BASE_MIN_WIDTH
			end

			return math.max(150, math.floor(BASE_MIN_WIDTH * 0.58))
		end

		local function getLeftInsetForLevel(levelToUse)
			if (levelToUse or 1) == 1 then
				return 24
			end

			if (levelToUse or 1) >= 3 then
				return 24
			end

			return 10
		end

		local function shouldCompactRightControl(levelToUse)
			return (levelToUse or 1) < 3
		end

		local function forceListFrameWidth(levelToUse)
			dd:ForceWidth(levelToUse, getMinWidthForLevel(levelToUse), getLeftInsetForLevel(levelToUse), {
				countKey = "bluCountLabel",
				previewKey = "bluPreviewButton",
				compactRightControl = shouldCompactRightControl(levelToUse),
			})
		end

		local function styleLastAddedButton(levelToUse, options)
			if dd and dd.StyleLastAddedButton then
				dd:StyleLastAddedButton(levelToUse, options)
			end
		end

		local function resetDropDownListFrame(levelToUse)
			if dd and dd.ResetLevel then
				dd:ResetLevel(levelToUse)
			end
		end

		local function hideInlinePreviewButtons(levelToUse)
			local listFrame = getDropDownListFrame(levelToUse)
			if not listFrame then
				return
			end

			local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
			for i = 1, maxButtons do
				local button = _G[listFrame:GetName() .. "Button" .. i]
				if button then
					if button.bluPreviewButton then
						button.bluPreviewButton:Hide()
					end
					if button.bluDeleteButton then
						button.bluDeleteButton:Hide()
					end
					if button.bluCountLabel then
						button.bluCountLabel:Hide()
					end
				end
			end
		end

		local function attachInlinePreviewButton(levelToUse, soundId)
			local listFrame = getDropDownListFrame(levelToUse)
			if not listFrame or not listFrame.numButtons then
				return
			end

			local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
			if not button then
				return
			end

			local previewButton = button.bluPreviewButton
			if not previewButton then
				previewButton = CreateFrame("Button", nil, button, "BackdropTemplate")
				previewButton:SetSize(34, 16)
				previewButton:SetBackdrop(BLU.Modules.design.Backdrops.Button)
				previewButton:SetBackdropColor(0.08, 0.10, 0.13, 0.95)
				previewButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
				previewButton:RegisterForClicks("LeftButtonUp")
				previewButton:SetScript("OnClick", function(btn)
					if btn.soundId and BLU.SoundRegistry and BLU.SoundRegistry.PlaySound then
						BLU.SoundRegistry:PlaySound(btn.soundId)
					end
				end)
				previewButton:SetScript("OnEnter", function(btn)
					btn:SetBackdropColor(0.12, 0.16, 0.22, 1)
					btn:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
					GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
					GameTooltip:SetText("Play")
					GameTooltip:AddLine("Click to play this sound.", 0.7, 0.7, 0.7, true)
					GameTooltip:Show()
				end)
				previewButton:SetScript("OnLeave", function(btn)
					btn:SetBackdropColor(0.08, 0.10, 0.13, 0.95)
					btn:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
					GameTooltip:Hide()
				end)

				local label = previewButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				label:SetPoint("CENTER", 0, 0)
				label:SetText("Play")
				label:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
				previewButton.label = label
				button.bluPreviewButton = previewButton
			end

			previewButton.soundId = soundId
			previewButton:Show()

			local normalText = _G[button:GetName() .. "NormalText"]
			previewButton:ClearAllPoints()
			previewButton:SetPoint("RIGHT", button, "RIGHT", -8, 0)

			if normalText then
				normalText:ClearAllPoints()
				normalText:SetPoint("LEFT", button, "LEFT", 10, 0)
				normalText:SetPoint("RIGHT", previewButton, "LEFT", -6, 0)
				normalText:SetJustifyH("LEFT")
			end
		end

		local function attachInlineCountLabel(levelToUse, text)
			local listFrame = getDropDownListFrame(levelToUse)
			if not listFrame or not listFrame.numButtons then
				return
			end

			local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
			if not button then
				return
			end

			local countLabel = button.bluCountLabel
			if not countLabel then
				countLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				countLabel:SetJustifyH("RIGHT")
				countLabel:SetTextColor(0.72, 0.72, 0.72)
				button.bluCountLabel = countLabel
			end

			countLabel:SetText(text or "")
			countLabel:Show()
		end

		resetDropDownListFrame(level)
		hideInlinePreviewButtons(level)

		local function hasEntries(groupData)
			if type(groupData) ~= "table" then
				return false
			end

			if #groupData > 0 then
				return true
			end

			for _, value in pairs(groupData) do
				if type(value) == "table" and #value > 0 then
					return true
				end
			end

			return false
		end

		local function formatTopLevelGroupLabel(groupKey, count)
			local text = tostring(groupKey or "")
			if groupKey == "BLU Other Game Sounds" or groupKey == "Shared Media" then
				text = "|cffffff00" .. text .. "|r"
			end

			return text .. " (" .. tostring(count or 0) .. ")"
		end

		local function onSoundSelected(value, text)
			BLU.db.selectedSounds[self.eventId] = value
			UIDropDownMenu_SetText(self, text)
			self.currentSound:SetText(text)
			if self.currentButtonLabel then
				self.currentButtonLabel:SetText(text)
			end
			LayoutControls(updateSoundControlMode(value))
			BLU:PrintDebug("[Options/SoundPanel] Selected sound '" .. tostring(value) .. "' for '" .. tostring(self.eventId) .. "'")
			CloseDropDownMenus()
		end

		local function addSoundSelectEntry(levelToUse, soundId, soundName, parentLabel)
			local trimmedSoundName = trimSoundNameForSubmenu(soundName, parentLabel)
			local maxChars = 46
			if levelToUse >= 3 then
				maxChars = 120
			elseif levelToUse >= 2 then
				maxChars = 60
			end
			local displayText, wasTruncated = shortenLabel(trimmedSoundName, maxChars)
			local selectInfo = UIDropDownMenu_CreateInfo()
			selectInfo.text = displayText
			selectInfo.value = soundId
			selectInfo.func = function()
				onSoundSelected(soundId, trimmedSoundName)
			end
			selectInfo.checked = BLU.db.selectedSounds[dropdown.eventId] == soundId
			if wasTruncated or trimmedSoundName ~= soundName then
				selectInfo.tooltipTitle = soundName
			end
			UIDropDownMenu_AddButton(selectInfo, levelToUse)
			styleLastAddedButton(levelToUse, {hasPreview = true, minWidth = (levelToUse >= 3 and 220 or nil)})
			attachInlinePreviewButton(levelToUse, soundId)
		end

		local function renderPagedSoundList(levelToUse, sounds, page, parentLabel)
			table.sort(sounds, function(a, b) return a.name < b.name end)

			local totalSounds = #sounds
			local totalPages = math.max(1, math.ceil(totalSounds / MAX_SOUNDS_PER_MENU_PAGE))
			local safePage = math.max(1, math.min(page or 1, totalPages))
			local startIndex = ((safePage - 1) * MAX_SOUNDS_PER_MENU_PAGE) + 1
			local endIndex = math.min(totalSounds, startIndex + MAX_SOUNDS_PER_MENU_PAGE - 1)

			if totalPages > 1 then
				local pageInfo = UIDropDownMenu_CreateInfo()
				pageInfo.text = string.format("|cff7fd0ffPage %d/%d|r", safePage, totalPages)
				pageInfo.isTitle = true
				pageInfo.notCheckable = true
				UIDropDownMenu_AddButton(pageInfo, levelToUse)
				styleLastAddedButton(levelToUse, {minWidth = 120})
			end

			for i = startIndex, endIndex do
				local sound = sounds[i]
				addSoundSelectEntry(levelToUse, sound.id, sound.name, parentLabel)
			end
		end
		local customHierarchy = {
			["BLU WoW Defaults"] = {},
			["BLU Other Game Sounds"] = {},
			["User Custom Sounds"] = {},
			["Shared Media"] = {},
		}
		if BLU.SoundRegistry and BLU.SoundRegistry.GetSoundsGroupedForUI then
			customHierarchy = BLU.SoundRegistry:GetSoundsGroupedForUI(self.eventId) or customHierarchy
		end

		if level == 1 then
			local specialOptions = {
				{text = "|cffff4444None|r", value = "None"},
				{text = "|cff00ff00Random|r", value = "random"},
				{text = "Default Sound", value = "default"},
			}
			for _, info in ipairs(specialOptions) do
				local dInfo = UIDropDownMenu_CreateInfo()
				dInfo.text = info.text
				dInfo.value = info.value
				dInfo.func = function() onSoundSelected(info.value, info.text) end
				dInfo.checked = BLU.db.selectedSounds[self.eventId] == info.value
				UIDropDownMenu_AddButton(dInfo, level)
				styleLastAddedButton(level, {minWidth = 150})
			end

			local sep = UIDropDownMenu_CreateInfo()
			sep.notClickable = true
			sep.notCheckable = true
			UIDropDownMenu_AddButton(sep, level)
			styleLastAddedButton(level, {minWidth = 150})

			local sortedTopLevelKeys = {"BLU WoW Defaults", "BLU Other Game Sounds", "User Custom Sounds", "Shared Media"}

			for _, groupKey in ipairs(sortedTopLevelKeys) do
				if hasEntries(customHierarchy[groupKey]) then
					local count = 0
					if groupKey == "BLU WoW Defaults" then
						count = #customHierarchy[groupKey]
						-- Avoid duplicating "Default Sound" with a one-item defaults submenu.
						if count <= 1 then
							count = 0
						end
					elseif groupKey == "User Custom Sounds" then
						count = #customHierarchy[groupKey]
					else
						for _, packSounds in pairs(customHierarchy[groupKey]) do
							count = count + #packSounds
						end
					end

					if count > 0 then
						local info = UIDropDownMenu_CreateInfo()
						info.text = formatTopLevelGroupLabel(groupKey, count)
						info.value = groupKey
						info.hasArrow = true
						info.menuList = groupKey
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)
						styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
					end
				end
			end
		elseif level == 2 then
			local groupKey = menuList
			local subgroups = customHierarchy[groupKey]
			if type(subgroups) ~= "table" then
				return
			end

			if groupKey == "BLU WoW Defaults" or groupKey == "User Custom Sounds" then
				table.sort(subgroups, function(a, b) return a.name < b.name end)
				for _, sound in ipairs(subgroups) do
					addSoundSelectEntry(level, sound.id, sound.name)
				end
			else
				local sortedSubKeys = {}
				for subKey in pairs(subgroups) do
					table.insert(sortedSubKeys, subKey)
				end
				table.sort(sortedSubKeys)

				for _, subKey in ipairs(sortedSubKeys) do
					local sounds = subgroups[subKey]
					local pageCount = math.max(1, math.ceil(#sounds / MAX_SOUNDS_PER_MENU_PAGE))
					local displaySubKey, subKeyTruncated = shortenLabel(subKey, 60)
					local info = UIDropDownMenu_CreateInfo()
					info.value = subKey
					info.notCheckable = true
					info.hasArrow = true
					if pageCount > 1 then
						info.menuList = {group = groupKey, sub = subKey, type = "pack_pages", pageCount = pageCount}
					else
						info.menuList = {group = groupKey, sub = subKey, type = "pack", page = 1}
					end
					info.text = displaySubKey
					if subKeyTruncated then
						info.tooltipTitle = subKey
					end
					UIDropDownMenu_AddButton(info, level)
					attachInlineCountLabel(level, "(" .. #sounds .. ")")
					styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
				end
			end
		elseif level == 3 then
			if type(menuList) ~= "table" then
				return
			end

			local groupKey = menuList.group
			local subKey = menuList.sub
			local groupData = customHierarchy[groupKey]
			local soundsToDisplay = groupData and groupData[subKey]

			if type(soundsToDisplay) == "table" then
				if menuList.type == "pack_pages" then
					table.sort(soundsToDisplay, function(a, b) return a.name < b.name end)
					local pageCount = math.max(1, math.ceil(#soundsToDisplay / MAX_SOUNDS_PER_MENU_PAGE))
					for pageIndex = 1, pageCount do
						local firstEntry = ((pageIndex - 1) * MAX_SOUNDS_PER_MENU_PAGE) + 1
						local lastEntry = math.min(#soundsToDisplay, firstEntry + MAX_SOUNDS_PER_MENU_PAGE - 1)
						local pageInfo = UIDropDownMenu_CreateInfo()
						pageInfo.notCheckable = true
						pageInfo.hasArrow = true
						pageInfo.menuList = {group = groupKey, sub = subKey, type = "pack", page = pageIndex}
						pageInfo.text = string.format("Page %d (%d-%d)", pageIndex, firstEntry, lastEntry)
						UIDropDownMenu_AddButton(pageInfo, level)
						styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
					end
				else
					renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
				end
			end
		elseif level == 4 then
			if type(menuList) ~= "table" or menuList.type ~= "pack" then
				return
			end

			local groupKey = menuList.group
			local subKey = menuList.sub
			local groupData = customHierarchy[groupKey]
			local soundsToDisplay = groupData and groupData[subKey]
			if type(soundsToDisplay) == "table" then
				renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
			end
		end

		-- Force all levels to the same width after WoW finishes its own layout
		forceListFrameWidth(level)
	end)

	local selectedValue = BLU.db and BLU.db.selectedSounds and BLU.db.selectedSounds[actualEventType] or "default"

	local selectedText = selectedValue
	if selectedValue == "None" then
		selectedText = "None"
	elseif selectedValue == "default" then
		selectedText = "Default Sound"
	elseif selectedValue == "random" then
		selectedText = "Random"
	else
		local soundInfo = BLU.SoundRegistry and BLU.SoundRegistry.GetSound and BLU.SoundRegistry:GetSound(selectedValue)
		if soundInfo then
			selectedText = soundInfo.name
		end
	end
	UIDropDownMenu_SetText(dropdown, selectedText)
	dropdown.currentSound:SetText(selectedText)
	if dropdown.currentButtonLabel then
		dropdown.currentButtonLabel:SetText(selectedText)
	end
	LayoutControls(updateSoundControlMode(selectedValue))

	return container
end

function BLU.CreateEventSoundPanel(panel, eventType, eventName)
	BLU:PrintDebug("[Options/SoundPanel] Creating event sound panel for '" .. tostring(eventType) .. "'")
	local content = CreateFrame("Frame", nil, panel)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 10)

	local icons = {
		levelup = "Interface\\Icons\\Achievement_Level_100",
		achievement = "Interface\\Icons\\Achievement_Quests_Completed_08",
		quest = "Interface\\Icons\\INV_Misc_Note_01",
		reputation = "Interface\\Icons\\Achievement_Reputation_01",
		battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
		honorrank = "Interface\\Icons\\PVPCurrency-Honor-Horde",
		renownrank = "Interface\\Icons\\UI_MajorFaction_Centaur",
		tradingpost = "Interface\\Icons\\INV_Misc_Coin_02",
		delvecompanion = "Interface\\Icons\\INV_Misc_Map_01",
	}

	-- Single titlebar: icon + title + module toggle
	local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("RIGHT", 0, 0)
	titleBar:SetHeight(44)
	titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
	titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
	titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

	local icon = titleBar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(24, 24)
	icon:SetPoint("LEFT", 10, 0)
	icon:SetTexture(icons[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

	local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

	local switchFrame = CreateFrame("Frame", nil, titleBar)
	switchFrame:SetSize(44, 20)
	switchFrame:SetPoint("RIGHT", -10, 0)

	local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
	switchBg:SetAllPoints()
	switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

	local toggle = CreateFrame("Button", nil, switchFrame)
	toggle:SetSize(18, 18)
	toggle:EnableMouse(true)

	local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
	toggleBg:SetAllPoints()
	toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
	toggleBg:SetVertexColor(1, 1, 1, 1)

	local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

	local moduleToggleKey = eventType
	local moduleLoadName = EVENT_MODULE_MAP[eventType] or eventType

	local function UpdateToggleState(enabled)
		toggle:ClearAllPoints()
		if enabled then
			toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
			switchBg:SetVertexColor(unpack(BLU.Modules.design.Colors.Primary))
			status:SetText("|cff00ff00ON|r")
		else
			toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
			switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
			status:SetText("|cffff0000OFF|r")
		end
	end

	local function IsModuleEnabled()
		if not BLU.db then return true end
		local modules = BLU.db.modules
		if not modules then return true end
		if modules[moduleToggleKey] ~= nil then return modules[moduleToggleKey] ~= false end
		if moduleLoadName ~= moduleToggleKey and modules[moduleLoadName] ~= nil then
			return modules[moduleLoadName] ~= false
		end
		return true
	end

	local function SetModuleEnabledState(enabled)
		BLU.db.modules[moduleToggleKey] = enabled
		if moduleLoadName ~= moduleToggleKey then
			BLU.db.modules[moduleLoadName] = enabled
		end
	end

	UpdateToggleState(IsModuleEnabled())

	toggle:SetScript("OnClick", function()
		if not BLU.db then return end
		BLU.db.modules = BLU.db.modules or {}
		local newState = not IsModuleEnabled()
		SetModuleEnabledState(newState)
		BLU:PrintDebug("[Options/SoundPanel] Toggled event module '" .. tostring(moduleLoadName) .. "' to " .. tostring(newState))
		UpdateToggleState(newState)
		if newState then
			if BLU.LoadModule then BLU:LoadModule("features", moduleLoadName) end
		else
			if BLU.UnloadModule then BLU:UnloadModule(moduleLoadName) end
		end
		C_Timer.After(0, function()
			if toggle and toggle:IsVisible() then UpdateToggleState(IsModuleEnabled()) end
		end)
	end)

	-- Sound dropdowns directly below titleBar
	local dropY = -54
	if eventType == "quest" then
		CreateSoundDropdown(content, "quest", "Quest Turn-In Sound", dropY, "questturnin")
		CreateSoundDropdown(content, "quest", "Quest Accept Sound", dropY - 70, "questaccept")
		CreateSoundDropdown(content, "quest", "Quest Complete Sound", dropY - 140, "questcomplete")
		CreateSoundDropdown(content, "quest", "Quest Progress Sound", dropY - 210, "questprogress")
	elseif eventType == "delvecompanion" then
		CreateSoundDropdown(content, eventType, "Companion Level-Up Sound", dropY)
		CreateSoundDropdown(content, eventType, "Delve Life Lost Sound", dropY - 70, "delvelifelost")
		CreateSoundDropdown(content, eventType, "Delve Life Gained Sound", dropY - 140, "delvelifegained")
	elseif eventType == "achievement" then
		CreateSoundDropdown(content, eventType, eventName .. " Sound", dropY)
		CreateSoundDropdown(content, eventType, "Achievement Progress Sound", dropY - 70, "achievementprogress")
	elseif eventType == "battlepet" then
		CreateSoundDropdown(content, eventType, eventName .. " Level-Up Sound", dropY)
		CreateSoundDropdown(content, eventType, "Pet Capture Sound", dropY - 70, "petcapture")
	else
		CreateSoundDropdown(content, eventType, eventName .. " Sound", dropY)
	end
end

function BLU.CreateHousingPanel(panel)
	BLU:PrintDebug("[Options/SoundPanel] Creating Housing sound panel")
	local content = CreateFrame("Frame", nil, panel)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 10)

	-- Titlebar: icon + title + module toggle
	local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("RIGHT", 0, 0)
	titleBar:SetHeight(44)
	titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
	titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
	titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

	local icon = titleBar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(24, 24)
	icon:SetPoint("LEFT", 10, 0)
	icon:SetTexture("Interface\\Icons\\Trade_Blacksmithing")

	local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	title:SetText("|cff05dffaHousing Sounds|r")

	local switchFrame = CreateFrame("Frame", nil, titleBar)
	switchFrame:SetSize(44, 20)
	switchFrame:SetPoint("RIGHT", -10, 0)

	local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
	switchBg:SetAllPoints()
	switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

	local toggle = CreateFrame("Button", nil, switchFrame)
	toggle:SetSize(18, 18)
	toggle:EnableMouse(true)

	local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
	toggleBg:SetAllPoints()
	toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
	toggleBg:SetVertexColor(1, 1, 1, 1)

	local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

	local function UpdateToggleState(enabled)
		toggle:ClearAllPoints()
		if enabled then
			toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
			switchBg:SetVertexColor(unpack(BLU.Modules.design.Colors.Primary))
			status:SetText("|cff00ff00ON|r")
		else
			toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
			switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
			status:SetText("|cffff0000OFF|r")
		end
	end

	local function IsModuleEnabled()
		if not (BLU.db) then return true end
		local modules = BLU.db.modules
		if modules and modules.housing ~= nil then return modules.housing ~= false end
		if BLU.db.enableHousing ~= nil then return BLU.db.enableHousing ~= false end
		return true
	end

	local function SetModuleEnabledState(enabled)
		BLU.db.modules = BLU.db.modules or {}
		BLU.db.modules.housing = enabled
		BLU.db.enableHousing = enabled
	end

	UpdateToggleState(IsModuleEnabled())

	toggle:SetScript("OnClick", function()
		if not (BLU.db) then return end
		local newState = not IsModuleEnabled()
		SetModuleEnabledState(newState)
		BLU:PrintDebug("[Options/SoundPanel] Toggled Housing module to " .. tostring(newState))
		UpdateToggleState(newState)
		if newState then
			if BLU.LoadModule then BLU:LoadModule("features", "housing") end
		else
			if BLU.UnloadModule then BLU:UnloadModule("housing") end
		end
		C_Timer.After(0, function()
			if toggle and toggle:IsVisible() then UpdateToggleState(IsModuleEnabled()) end
		end)
	end)

	-- Sound dropdowns directly below titleBar
	CreateSoundDropdown(content, "housing", "House XP Gained Sound", -54, "housingxpgained")
	CreateSoundDropdown(content, "housing", "House Leveled Up Sound", -124, "housingleveledup")
	CreateSoundDropdown(content, "housing", "House Rewards Received Sound", -194, "housingrewardsreceived")
	CreateSoundDropdown(content, "housing", "New Decor Collected Sound", -264, "housingdecorcollected")
end


function SoundPanel:Init()
	BLU:PrintDebug("[SoundPanel] Sound panel module initialized")
end

BLU.CreateSoundDropdown = CreateSoundDropdown

if BLU.RegisterModule then
	BLU:RegisterModule(SoundPanel, "sound_panel", "Sound Panel")
end