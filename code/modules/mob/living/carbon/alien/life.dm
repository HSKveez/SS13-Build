
/mob/living/carbon/alien/Life(delta_time = SSMOBS_DT, times_fired)
	findQueen()
	return..()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.get_moles(GAS_PLASMA)/breath.total_moles())*breath_pressure

	if(Toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjustPlasma(breath.get_moles(GAS_PLASMA)*250)
		throw_alert("alien_tox", /atom/movable/screen/alert/alien_tox)

		toxins_used = breath.get_moles(GAS_PLASMA)

	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.adjust_moles(GAS_PLASMA, -toxins_used)
	breath.adjust_moles(GAS_O2, toxins_used)

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/humanoid/Life(delta_time, times_fired)
	. = ..()
	handle_organs(delta_time, times_fired)

/mob/living/carbon/alien/handle_status_effects(delta_time, times_fired)
	..()
	//natural reduction of movement delay due to stun.
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - (0.5 * rand(1, 2) * delta_time))