if SERVER then
	resource.AddFile("materials/vgui/vignette_w.vmt")
	resource.AddFile("sound/lowhp/hbeat.wav")
end

AddCSLuaFile()




--[[ 
#################################################
#################################################
#################################################
 DON'T TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#################################################
#################################################
#################################################
]]
CreateConVar( "etb_healtheffect_system", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "0 = Health effect OFF // 1 = Health effect ON" )

CreateConVar( "etb_heartbeat_sound", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "0 = OFF // 1 = On // At certain value of health will the heartbeat sound start playing?" )

CreateConVar( "etb_redflash", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "0 = OFF // 1 = On // At certain value of health will the screen flash red?" )

CreateConVar( "etb_vignette", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "0 = OFF // 1 = On // At certain value of health will the screen become darker?" )

CreateConVar( "etb_threshold", 65, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "At this point, sounds and screen will getting stronger" )

CreateConVar( "etb_muffle_sound", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "0 = OFF // 1 = On // At certain value of health will the sound become muffled?" )

CreateConVar( "etb_muffle_effect", 95, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Health value that the sounds will become muffled" )

local etb_healtheffect_system = GetConVar( "etb_healtheffect_system" )
local etb_heartbeat_sound = GetConVar( "etb_heartbeat_sound" )
local etb_redflash = GetConVar( "etb_redflash" )
local etb_vignette = GetConVar( "etb_vignette" )
local etb_threshold = GetConVar( "etb_threshold" )
local etb_muffle_sound = GetConVar( "etb_muffle_sound" )
local etb_muffle_effect = GetConVar( "etb_muffle_effect" )

if CLIENT then
	-- CreateClientConVar("etb_healtheffect", 1, true, true, "0 = Health effect OFF // 1 = Health effect ON")
	
	local intensity = 0
	local hpwait, hpalpha = 0, 0
	local vig = surface.GetTextureID("vgui/vignette_w")
	
	local clr = {
		[ "$pp_colour_addr" ] = 0,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}

	local function LowHP_HUDPaint()

		if etb_healtheffect_system:GetInt() == 0 then
			return 
		end
		
		local ply = LocalPlayer()
		local hp = ply:Health()
		local x, y = ScrW(), ScrH()
		local FT = FrameTime()
		
		if etb_muffle_sound:GetInt() then
			if ply:Health() + 30 <= etb_muffle_effect:GetInt() then
				if not ply.lastDSP then
					ply:SetDSP(14)
					ply.lastDSP = 14
				end
			else
				if ply.lastDSP then
					ply:SetDSP(0)
					ply.lastDSP = nil
				end
			end
		end
		
		intensity = math.Approach(intensity, math.Clamp(1 - math.Clamp(hp / etb_threshold:GetInt(), 0, 1), 0, 1), FT * 3)
		
		if intensity > 0 then
			if etb_vignette:GetInt() == 1 then
				surface.SetDrawColor(0, 0, 0, 200 * intensity)
				surface.SetTexture(vig)
				surface.DrawTexturedRect(0, 0, x, y)
			end
			
			clr[ "$pp_colour_colour" ] = 1 - intensity
			DrawColorModify(clr)
			
			if ply:Alive() then
				local CT = CurTime()
				
				if etb_heartbeat_sound:GetInt() == 1 then
					if CT > hpwait then
						ply:EmitSound("lowhp/hbeat.wav", 100 * intensity + 20, 100 + 80 * intensity)
						hpwait = CT + 0.8
					end
				end
				
				if etb_redflash:GetInt() == 1 then
					surface.SetDrawColor(200, 0, 0, math.max(80 * intensity * hpalpha, 0.5))
					surface.DrawTexturedRect(0, 0, x, y)
					
					if CT < hpwait - 0.4 then
						hpalpha = math.Approach(hpalpha, 1, FrameTime() * 10)
					else
						hpalpha = math.Approach(hpalpha, 0.33, FrameTime() * 10)
					end
				end
			end
		end	
	end
	
	hook.Add("HUDPaint", "LowHP_HUDPaint", LowHP_HUDPaint)
end
