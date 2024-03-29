/proc/power_failure()
	priority_announce("Аномальная активность обнаружена энергосетях [station_name()]. В качестве меры предосторожности энергия будет отключена на неопределенный срок.", "Критический сбой питания", ANNOUNCER_POWEROFF)
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(istype(get_area(S), /area/ai_monitored/turret_protected) || !is_station_level(S.z))
			continue
		S.charge = 0
		S.output_level = 0
		S.output_attempt = FALSE
		S.update_icon()
		S.power_change()

	for(var/area/A in GLOB.the_station_areas)
		if(!A.requires_power || A.always_unpowered )
			continue
		if(GLOB.typecache_powerfailure_safe_areas[A.type])
			continue

		A.power_light = FALSE
		A.power_equip = FALSE
		A.power_environ = FALSE
		A.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.apcs_list)
		if(C.cell && is_station_level(C.z))
			var/area/A = C.area
			if(GLOB.typecache_powerfailure_safe_areas[A.type])
				continue

			C.cell.charge = 0

/proc/power_restore()

	priority_announce("Электроэнергия восстановлена на [station_name()]. Приносим свои извинения за доставленные неудобства.", "Электропитание стабилизировано", ANNOUNCER_POWEROFF)
	for(var/obj/machinery/power/apc/C in GLOB.machines)
		if(C.cell && is_station_level(C.z))
			C.cell.charge = C.cell.maxcharge
			C.failure_timer = 0
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = TRUE
		S.update_icon()
		S.power_change()
	for(var/area/A in GLOB.the_station_areas)
		if(!A.requires_power || A.always_unpowered)
			continue
		if(!istype(A, /area/shuttle))
			A.power_light = TRUE
			A.power_equip = TRUE
			A.power_environ = TRUE
			A.power_change()

/proc/power_restore_quick()

	priority_announce("Все СМЕСы на станции [station_name()] были заряжены нашей электромагнитной установкой. Приносим свои извинения за доставленные неудобства.", "Электропитание стабилизировано", ANNOUNCER_POWERON)
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!is_station_level(S.z))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = TRUE
		S.update_icon()
		S.power_change()

