AddCSLuaFile("codhealthsys.lua")

CreateConVar("healthsys", 1, FCVAR_NOTIFY, "")
CreateConVar("healthsys_regen", 1, FCVAR_NOTIFY, "")
CreateConVar("healthsys_visual", 1, FCVAR_NOTIFY, "")
CreateConVar("healthsys_heartbeat", "1", FCVAR_NOTIFY, "") --turn the hearthbeat sound off/on
CreateConVar("healthsys_audio", "1", FCVAR_NOTIFY, "") --turn the pain sounds off/on
CreateConVar("healthsys_delay", "0", FCVAR_NOTIFY, "") --set the delay before your health begins to regenerate
CreateConVar("healthsys_speed", "0", FCVAR_NOTIFY, "") --set how fast the health regenerates
CreateConVar("healthsys_amount", "0", FCVAR_NOTIFY, "") --set how much health you regenerate
CreateConVar("healthsys_maxhealth", "100", FCVAR_NOTIFY, "") --set the maximum health you can regenerate
CreateConVar("healthsys_maxheal", "100", FCVAR_NOTIFY, "") --completion to healthsys_maxhealth. by default you will only regenerate 100 times if you set it and healthsys_maxhealth to 200, you will full heal instead of only getting 100 health points

function HealPlayer(victim, attacker)
	if 	GetConVarNumber("healthsys") == 0 or
		GetConVarNumber("healthsys_regen") == 0 then return end
	timer.Start("insertname"..victim:SteamID())
	timer.Destroy("heal"..victim:SteamID())
	timer.Create("insertname"..victim:SteamID(), GetConVarNumber("healthsys_delay"), 1, function()
		timer.Create("heal"..victim:SteamID(), GetConVarNumber("healthsys_speed"), GetConVarNumber("healthsys_maxheal"), function()
			victim:SetHealth(math.Clamp(victim:Health()+GetConVarNumber("healthsys_amount"), 0, GetConVarNumber("healthsys_maxhealth")))
		end)
	end)
end
hook.Add("PlayerHurt", "Healplayer", HealPlayer)

function Bloomvision() --Huge thanks to Pandaman09 who helped me with this part
	if	GetConVarNumber("healthsys") == 0 or
		GetConVarNumber("healthsys_visual") == 0 then return end
	local hp = LocalPlayer():Health()
	if  hp<=80 then
		DrawToyTown(1, ScrH()/2)
	end	
	if hp <=50 then
		DrawBloom(0.7, 1.7, 8, 7, 1, 1, 0.75, 0, 0)
	end	
	if hp <=35 then
		DrawMotionBlur(0.4, 10, 0.01)
		DrawBloom(0.30, 5, 5, 0, 1, 0.5, 0.5, 0, 0)
		DrawMaterialOverlay("effects/bleed_overlay", 0.01)
	end
	if hp <=25 then
		DrawMaterialOverlay("effects/invuln_overlay_red", 0.01)
	end
end
hook.Add("RenderScreenspaceEffects", "bloomvision", Bloomvision)

function Healthbeat(victim, attacker)
	if GetConVarNumber("healthsys_heartbeat") ==0 then return end
	local lowhealtbeat = CreateSound(victim, "player/heartbeat1.wav")
	if victim:Health() <=30 and victim:Health() >15 then
		lowhealtbeat:PlayEx(0.75, 100)
		timer.Create("lowhealtbeat"..victim:SteamID(), GetConVarNumber("healthsys_delay"), 1, function() lowhealtbeat:FadeOut(1.75) end)
	elseif victim:Health() <=15 then
		lowhealtbeat:Stop()
		lowhealtbeat:PlayEx(0.75, 150)
		timer.Create("lowhealtbeat"..victim:SteamID(), GetConVarNumber("healthsys_delay"), 1, function() lowhealtbeat:FadeOut(1.75) end)
	end
	if victim:Health() <=0 then
		lowhealtbeat:Stop()
	end
end
hook.Add("PlayerHurt", "Healthbeat", Healthbeat)

function HurtSound(victim, attacker, healthRemaining, damageTaken)
    victim:ScreenFade(SCREENFADE.IN, Color(20 + damageTaken, 0, 0, 250), 0.5, 0)
	if GetConVarNumber("healthsys_audio") ==0 then return end

	local soundchooser = math.random(1, 5)
    if ( victim:Health() < 30 and CurTime() - ( victim.previousHurtSoundTime or 0 ) >= 1.5 ) then
        victim.previousHurtSoundTime = CurTime()
		if soundchooser == 1 then victim:EmitSound("ambient/voices/citizen_beaten1.wav", 60, 100) end
		if soundchooser == 2 then victim:EmitSound("ambient/voices/citizen_beaten2.wav", 60, 100) end
		if soundchooser == 3 then victim:EmitSound("ambient/voices/citizen_beaten3.wav", 60, 100) end
		if soundchooser == 4 then victim:EmitSound("ambient/voices/citizen_beaten4.wav", 60, 100) end
		if soundchooser == 5 then victim:EmitSound("ambient/voices/citizen_beaten5.wav", 60, 100) end
	end
end
hook.Add("PlayerHurt", "Hurtsound", HurtSound)

concommand.Add("health_up", function(ply)
	ply:SetHealth(ply:Health() +10)
end) 
concommand.Add("health_down", function(ply)
	ply:SetHealth(ply:Health() - 10)
end) 
