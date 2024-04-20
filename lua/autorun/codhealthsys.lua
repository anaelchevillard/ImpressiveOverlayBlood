AddCSLuaFile("codhealthsys.lua")

CreateConVar("healthsys", 1, FCVAR_NOTIFY, true)
CreateConVar("healthsys_regen", 1, FCVAR_NOTIFY, true)
CreateConVar("healthsys_visual", 1, FCVAR_NOTIFY, true)
CreateConVar("healthsys_heartbeat", "1", FCVAR_NOTIFY, true) --turn the hearthbeat sound off/on
CreateConVar("healthsys_audio", "1", FCVAR_NOTIFY, true) --turn the pain sounds off/on
CreateConVar("healthsys_delay", "0", FCVAR_NOTIFY, false) --set the delay before your health begins to regenerate
CreateConVar("healthsys_speed", "0", FCVAR_NOTIFY, false) --set how fast the health regenerates
CreateConVar("healthsys_amount", "0", FCVAR_NOTIFY, false) --set how much health you regenerate
CreateConVar("healthsys_maxhealth", "100", FCVAR_NOTIFY, false) --set the maximum health you can regenerate
CreateConVar("healthsys_maxheal", "100", FCVAR_NOTIFY, false) --completion to healthsys_maxhealth. by default you will only regenerate 100 times if you set it and healthsys_maxhealth to 200, you will full heal instead of only getting 100 health points


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


	if LocalPlayer():Health() <=80 then
	DrawToyTown(1, ScrH()/2)
	end
	
	if LocalPlayer():Health() <=50 then
	DrawBloom(0.7, 1.7, 8, 7, 1, 1, 0.75, 0, 0)
	end
	
	if LocalPlayer():Health() <=35 then
		DrawMotionBlur(0.4, 10, 0.01)
		DrawBloom(0.30, 5, 5, 0, 1, 0.5, 0.5, 0, 0)
		DrawMaterialOverlay("effects/bleed_overlay", 0.01)
	end
	if LocalPlayer():Health() <=25 then
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
	if victim:Health()<=0 then
lowhealtbeat:Stop()
	end
end
hook.Add("PlayerHurt", "Healthbeat", Healthbeat)

function HurtSound(victim, attacker)
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