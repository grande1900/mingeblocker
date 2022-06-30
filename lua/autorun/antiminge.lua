local Enabled = CreateConVar("minge_blocker_enabled",1,"Enables the mingeblocker")
local VoxEnabled = CreateConVar("minge_blocker_vox_enabled",1,"Enables the mingeblocker's announcements")
if not GM13 then
	include("autorun/gm13_init.lua")
end
local curstate = nil
function VoxSay(input)
	if not VoxEnabled:GetBool() then return end
	local words = {"lt"..GM13.Lobby.selectedServerDB,input}
	local s = 0
	for _, i in pairs(words) do
		local path = "mingeblocker/"..i..".wav"
		local duration = SoundDuration(path)
		timer.Simple(s == 0 and s or s+duration,function()
			local sound = CreateSound(Entity(0), path)
			sound:SetSoundLevel(0)
			sound:Play()
		end)
		s=s+duration
	end
end
hook.Add( "AddToolMenuCategories", "GRANDES_SETTINGS", function()
	spawnmenu.AddToolCategory( "Utilities", "GrandesSettings", "#Grande's Settings" )
end )
hook.Add( "PopulateToolMenu", "MINGE_BLOCKER_SETTINGS", function()
	spawnmenu.AddToolMenuOption( "Utilities", "GrandesSettings", "MINGEBLOCKERSETTINGS", "#Minge Blocker Settings", "", "", function( panel )
		panel:CheckBox( "Enabled", "minge_blocker_enabled" )
		panel:CheckBox( "Vox Enabled", "minge_blocker_vox_enabled" )
		panel:Button( "Toggle Devmode", "devmode_gm13_toggle" )
		-- Add stuff here
	end )
end )
hook.Add("gm13_lobby_play","MINGEBLOCKERMAINFUNCTION",function()
	if Enabled:GetBool() then
		curstate = "play"
		GM13.Lobby:Exit()
	else
		VoxSay("accepted")
	end
	curstate = "play"
end)
hook.Add("gm13_lobby_check","MINGEBLOCKERPREPARE",function()
	curstate = "check"
end)
hook.Add("gm13_lobby_getinfo","MINGEBLOCKERGETINFO",function()
	if curstate == "check" then
		VoxSay("unauthorized")
	end
	curstate = "getinfo"
end)
hook.Add("gm13_lobby_exit","MINGEBLOCKERADIOS",function()
	if curstate == "play" and Enabled:GetBool() then
		VoxSay("terminated")	
	elseif curstate ~= "play" then
		VoxSay("error")
	end
	curstate = "exit"
end)
hook.Add("gm13_lobby_select_server","MINGEBLOCKERLE",function()
	VoxSay("search","SelectVox")
	curstate = "select"
end)