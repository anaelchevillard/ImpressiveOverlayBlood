function HealthHUD()
	if (init==nil) or (init==false) then
		init=true	
		relation=0
		hp_init = LocalPlayer():Health()
		alpha_value = 0
	end
	
	
	if (alpha_value <= 100) and (alpha_value > 0) then
		alpha_value = alpha_value - 5
	end
	if hp_init != LocalPlayer():Health() and LocalPlayer():Health()<=hp_init then
		hp_init = LocalPlayer():Health()
		alpha_value=100
	elseif hp_init != LocalPlayer():Health() and LocalPlayer():Health()>=hp_init then
		hp_init = LocalPlayer():Health()
		alpha_value=0
	end
	if LocalPlayer():Health()>=100  then
		intensity = 100 - 100
		relation = 0
		
	else
		if LocalPlayer():Health()<30 then
			relation = math.Clamp((70 - LocalPlayer():Health()) / 40, 0, 1)	
		end
		intensity = 100 - LocalPlayer():Health()
	end
	

	local tab = {}
		tab[ "$pp_colour_addr" ] = ((intensity)*(0.01))
		tab[ "$pp_colour_addg" ] = ((intensity)*(-0))
		tab[ "$pp_colour_addb" ] = ((intensity)*(-0))
		tab[ "$pp_colour_brightness" ] = ((intensity)*(-0.001))
		tab[ "$pp_colour_contrast" ] = 1-(relation/2)
		tab[ "$pp_colour_colour" ] = 1-relation
		tab[ "$pp_colour_mulr" ] = ((intensity)*(-0))
		tab[ "$pp_colour_mulg" ] = ((intensity)*(-0))
		tab[ "$pp_colour_mulb" ] = ((intensity)*(-0))
	DrawColorModify( tab )
	DrawMotionBlur( 0.2, alpha_value/100, 0)
	DrawMotionBlur( 0.2, relation, 0)
	DrawToyTown(intensity*0.15, intensity*4.5)

end
hook.Add( "RenderScreenspaceEffects", "HealthHUD", HealthHUD )