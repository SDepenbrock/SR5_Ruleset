-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local effectson = false;

function onInit()
	-- Set the displays to what should be shown
	setSpacingVisible();
	setEffectsVisible();

	-- Acquire token reference, if any
	linkToken();
	
	-- Set up the PC links
	onLinkChanged();
	
	-- Update the displays
	onFactionChanged();
	
	-- Register the deletion menu item for the host
	registerMenuItem("Delete Item", "delete", 6);
	registerMenuItem("Confirm Delete", "delete", 6, 7);

	-- Track the effects list
	DB.addHandler(getDatabaseNode().getNodeName() .. ".effects", "onChildUpdate", onEffectsChanged);
	onEffectsChanged();
end

function onClose()
	DB.removeHandler(getDatabaseNode().getNodeName() .. ".effects", "onChildUpdate", onEffectsChanged);
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		delete();
	end
end

function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getNodeName();
	
	-- Clear any effects and wounds first, so that saves aren't triggered when initiative advanced
	effects.reset(false);
	
	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- If this is an NPC with a token on the map, then remove the token also
	local sClass, sRecord = link.getValue();
	if sClass ~= "charsheet" then
		token.deleteReference();
	end

	-- Delete the database node and close the window
	node.delete();

	-- Update list information (global subsection toggles)
	windowlist.onVisibilityToggle();
	windowlist.onEntrySectionToggle();
end

function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
end

function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end

function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

function onEffectsChanged()
	local affectedby = EffectManager.getEffectsString(getDatabaseNode());
	effects_str.setValue(affectedby);
	
	if affectedby == "" or effectson then
		effects_label.setVisible(false);
		effects_str.setVisible(false);
	else
		effects_label.setVisible(true);
		effects_str.setVisible(true);
	end
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
	end
end

--
-- SECTION VISIBILITY FUNCTIONS
--

function setSpacingVisible()
	local v = false;
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	
	space.setVisible(v);
	spacelabel.setVisible(v);
	reach.setVisible(v);
	reachlabel.setVisible(v);
	
	frame_spacing.setVisible(v);
end

function setEffectsVisible()
	local v = false;
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effectson = v;
	effecticon.setVisible(v);
	
	effects.setVisible(v);

	frame_effects.setVisible(v);

	onEffectsChanged();
end
