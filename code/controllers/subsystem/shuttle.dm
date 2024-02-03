#define MAX_TRANSIT_REQUEST_RETRIES 10
/// How many turfs to allow before we stop blocking transit requests
#define MAX_TRANSIT_TILE_COUNT (150 ** 2)
/// How many turfs to allow before we start freeing up existing "soft reserved" transit docks
/// If we're under load we want to allow for cycling, but if not we want to preserve already generated docks for use
#define SOFT_TRANSIT_RESERVATION_THRESHOLD (100 ** 2)

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/list/mobile = list()
	var/list/stationary = list()
	var/list/beacons = list()
	var/list/transit = list()

	//Now it only for ID generation
	var/list/assoc_mobile = list()
	var/list/assoc_stationary = list()

	var/list/transit_requesters = list()
	var/list/transit_request_failures = list()
	/// How many turfs our shuttles are currently utilizing in reservation space
	var/transit_utilized = 0


		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/arrivals/arrivals
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = 6000	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = 1800	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = 1200	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/area/emergencyLastCallLoc
	var/emergencyCallAmount = 0		//how many times the escape shuttle was called
	var/emergencyNoEscape
	var/emergencyNoRecall = FALSE
	var/adminEmergencyNoRecall = FALSE
	var/lastMode = SHUTTLE_IDLE
	var/lastCallTime = 6000
	var/list/hostileEnvironments = list() //Things blocking escape shuttle from leaving
	var/list/tradeBlockade = list() //Things blocking cargo from leaving.
	var/supplyBlocked = FALSE

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/ordernum = 1					//order number given to next order
	var/points = 5000					//number of trade-points we have
	var/centcom_message = ""			//Remarks from CentCom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentCom, associated with their potencies

	var/list/supply_packs = list()
	var/list/chef_groceries = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/orderhistory = list()

	var/list/hidden_shuttle_turfs = list() //all turfs hidden from navigation computers associated with a list containing the image hiding them and the type of the turf they are pretending to be
	var/list/hidden_shuttle_turf_images = list() //only the images from the above list

	var/datum/round_event/shuttle_loan/shuttle_loan

	var/shuttle_purchased = SHUTTLEPURCHASE_PURCHASABLE //If the station has purchased a replacement escape shuttle this round
	var/list/shuttle_purchase_requirements_met = list() //For keeping track of ingame events that would unlock new shuttles, such as defeating a boss or discovering a secret item

	var/lockdown = FALSE	//disallow transit after nuke goes off

	var/datum/map_template/shuttle/selected

	var/obj/docking_port/mobile/existing_shuttle

	var/obj/docking_port/mobile/preview_shuttle
	var/datum/map_template/shuttle/preview_template

	var/datum/turf_reservation/preview_reservation

	var/shuttle_loading

	var/shuttles_loaded = FALSE

/datum/controller/subsystem/shuttle/Initialize()
	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new pack()
		if(!P.contains)
			continue
		supply_packs[P.type] = P

	initial_load()

	if(!arrivals)
		log_game("No /obj/docking_port/mobile/arrivals placed on the map!")
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!backup_shuttle)
		WARNING("No /obj/docking_port/mobile/emergency/backup placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")

	return SS_INIT_SUCCESS

/datum/controller/subsystem/shuttle/proc/initial_load()
	shuttles_loaded = TRUE
	for(var/s in stationary)
		var/obj/docking_port/stationary/S = s
		S.load_roundstart()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire()
	for(var/thing in mobile)
		if(!thing)
			mobile.Remove(thing)
			continue
		var/obj/docking_port/mobile/P = thing
		P.check()
	for(var/thing in transit)
		var/obj/docking_port/stationary/transit/T = thing
		if(!T.owner)
			qdel(T, force=TRUE)
		// This next one removes transit docks/zones that aren't
		// immediately being used. This will mean that the zone creation
		// code will be running a lot.

		// If we're below the soft reservation threshold, don't clear the old space
		// We're better off holding onto it for now
		if(transit_utilized < SOFT_TRANSIT_RESERVATION_THRESHOLD)
			continue
		var/obj/docking_port/mobile/owner = T.owner
		if(owner)
			var/idle = owner.mode == SHUTTLE_IDLE
			var/not_centcom_evac = owner.launch_status == NOLAUNCH
			var/not_in_use = (!T.docked)
			if(idle && not_centcom_evac && not_in_use)
				qdel(T, force=TRUE)
	CheckAutoEvac()

	if(!SSmapping.clearing_reserved_turfs)
		while(transit_requesters.len)
			var/requester = popleft(transit_requesters)
			var/success = null
			// Do not try and generate any transit if we're using more then our max already
			if(transit_utilized < MAX_TRANSIT_TILE_COUNT)
				success = generate_transit_dock(requester)
			if(!success) // BACK OF THE QUEUE
				transit_request_failures[requester]++
				if(transit_request_failures[requester] < MAX_TRANSIT_REQUEST_RETRIES)
					transit_requesters += requester
				else
					var/obj/docking_port/mobile/M = requester
					M.transit_failure()
			if(MC_TICK_CHECK)
				break

/datum/controller/subsystem/shuttle/proc/CheckAutoEvac()
	if(emergencyNoEscape || adminEmergencyNoRecall || emergencyNoRecall || !emergency || !SSticker.HasRoundStarted())
		return

	var/threshold = CONFIG_GET(number/emergency_shuttle_autocall_threshold)
	if(!threshold || GLOB.disable_fucking_station_shit_please)
		return

	var/alive = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			++alive

	var/total = GLOB.joined_player_list.len
	if(total <= 0)
		return //no players no autoevac

	if(alive / total <= threshold)
		var/msg = "Automatically dispatching emergency shuttle due to crew death."
		message_admins(msg)
		log_shuttle("[msg] Alive: [alive], Roundstart: [total], Threshold: [threshold]")
		emergencyNoRecall = TRUE
		priority_announce("Обнаружены катастрофические потери: активированы протоколы аварийного шаттла - заглушаем сигналы отзыва на всех частотах.")
		if(emergency.timeLeft(1) > emergencyCallTime * 0.4)
			emergency.request(null, set_coefficient = 0.4)

/datum/controller/subsystem/shuttle/proc/block_recall(lockout_timer)
	if(adminEmergencyNoRecall)
		priority_announce("Ошибка!", "Блокировка приёмника шаттла", sound('white/valtos/sounds/trevoga2.ogg'))
		addtimer(CALLBACK(src, PROC_REF(unblock_recall)), lockout_timer)
		return
	emergencyNoRecall = TRUE
	addtimer(CALLBACK(src, PROC_REF(unblock_recall)), lockout_timer)

/datum/controller/subsystem/shuttle/proc/unblock_recall()
	if(adminEmergencyNoRecall)
		priority_announce("Ошибка!", "Блокировка приёмника шаттла", sound('white/valtos/sounds/trevoga2.ogg'))
		return
	emergencyNoRecall = FALSE

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
		if(S.id == id)
			return S
	WARNING("couldn't find dock with id: [id]")

/// Check if we can call the evac shuttle.
/// Returns TRUE if we can. Otherwise, returns a string detailing the problem.
/datum/controller/subsystem/shuttle/proc/canEvac(mob/user)
	var/srd = CONFIG_GET(number/shuttle_refuel_delay)
	if(world.time - SSticker.round_start_time < srd)
		return "Эвакуационный шаттл всё ещё готовится. Подождите [DisplayTimeText(srd - (world.time - SSticker.round_start_time))] перед очередной попыткой."

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			return "Эвакуационный шаттл не может быть вызван, пока он летит к ЦК."
		if(SHUTTLE_CALL)
			return "Эвакуационный шаттл уже в пути."
		if(SHUTTLE_DOCKED)
			return "Эвакуационный шаттл уже на месте."
		if(SHUTTLE_IGNITING)
			return "Эвакуационный шаттл уже зажигает свои двигатели и собирается улетать."
		if(SHUTTLE_ESCAPE)
			return "Эвакуационный шаттл уже отлетел от станции на безопасное расстояние."
		if(SHUTTLE_STRANDED)
			return "Эвакуационный шаттл заблокирован Центральным Командованием."
	return TRUE

/datum/controller/subsystem/shuttle/proc/requestEvac(mob/user, call_reason)
	if(!emergency)
		WARNING("requestEvac(): There is no emergency shuttle, but the \
			shuttle was called. Using the backup shuttle instead.")
		if(!backup_shuttle)
			CRASH("requestEvac(): There is no emergency shuttle, \
			or backup shuttle! The game will be unresolvable. This is \
			possibly a mapping error, more likely a bug with the shuttle \
			manipulation system, or badminry. It is possible to manually \
			resolve this problem by loading an emergency shuttle template \
			manually, and then calling register() on the mobile docking port. \
			Good luck.")
		emergency = backup_shuttle

	var/can_evac_or_fail_reason = SSshuttle.canEvac(user, FALSE)
	if(can_evac_or_fail_reason != TRUE)
		to_chat(user, span_alert("[can_evac_or_fail_reason]"))
		return

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH && SSsecurity_level.get_current_level_as_number() > SEC_LEVEL_GREEN)
		to_chat(user, span_alert("You must provide a reason."))
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nПричина:\n\n[call_reason]"
	switch(SSsecurity_level.get_current_level_as_number())
		if(SEC_LEVEL_RED,SEC_LEVEL_DELTA)
			emergency.request(null, signal_origin, html_decode(emergency_reason), 1) //There is a serious threat we gotta move no time to give them five minutes.
		else
			emergency.request(null, signal_origin, html_decode(emergency_reason), 0)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = "update")) // Start processing shuttle-mode displays to display the timer
	frequency.post_signal(src, status_signal)

	var/area/A = get_area(user)

	log_shuttle("[key_name(user)] has called the emergency shuttle.")
	deadchat_broadcast(" вызывает шаттл из локации <span class='name'>[A.name]</span>.", span_name("[user.real_name]") , user, message_type=DEADCHAT_ANNOUNCEMENT)
	if(call_reason)
		SSblackbox.record_feedback("text", "shuttle_reason", 1, "[call_reason]")
		log_shuttle("Shuttle call reason: [call_reason]")
		webhook_send_roundstatus("shuttle called", list("reason" = call_reason, "seclevel" = SSsecurity_level.get_current_level_as_text()))
		SSticker.emergency_reason = call_reason
	else
		webhook_send_roundstatus("shuttle called", list("reason" = "none", "seclevel" = SSsecurity_level.get_current_level_as_text()))
	message_admins("[ADMIN_LOOKUPFLW(user)] has called the shuttle. (<A HREF='?_src_=holder;[HrefToken()];trigger_centcom_recall=1'>TRIGGER CENTCOM RECALL</A>)")

/datum/controller/subsystem/shuttle/proc/centcom_recall(old_timer, admiral_message)
	if(emergency.mode != SHUTTLE_CALL || emergency.timer != old_timer)
		return
	emergency.cancel()

	if(!admiral_message)
		admiral_message = pick(GLOB.admiral_messages)
	var/intercepttext = "<font size = 3><b>Обновление NanoTrasen</b>: Запрос шаттла.</font><hr>\
						Для предъявления по месту требования:<br><br>\
						Мы приняли к сведению ситуацию по [station_name()] и подошли \
						к выводу о том, что это не является основанием для отказа от данной станции.<br>\
						Если вы не согласны с нашим мнением, предлагаем вам открыть \
						прямую линию с нами и объяснить причину кризиса.<br><br>\
						<i>Это сообщение было автоматически сгенерировано на основе \
						показаний диагностических приборов дальнего действия. \
						Чтобы гарантировать качество запроса, каждый \
						окончательный отчет проверяется дежурным контр-адмиралом.<br> \
						<b>Заметка контр-адмирала:</b> \
						[admiral_message]"
	print_command_report(intercepttext, announce = TRUE)

// Called when an emergency shuttle mobile docking port is
// destroyed, which will only happen with admin intervention
/datum/controller/subsystem/shuttle/proc/emergencyDeregister()
	// When a new emergency shuttle is created, it will override the
	// backup shuttle.
	src.emergency = src.backup_shuttle

/datum/controller/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		log_shuttle("[key_name(user)] has recalled the shuttle.")
		message_admins("[ADMIN_LOOKUPFLW(user)] has recalled the shuttle.")
		webhook_send_roundstatus("shuttle recalled")
		deadchat_broadcast(" отзывает шаттл из локации <span class='name'>[get_area_name(user, TRUE)]</span>.", span_name("[user.real_name]") , user, message_type=DEADCHAT_ANNOUNCEMENT)
		return 1

/datum/controller/subsystem/shuttle/proc/canRecall()
	if(!emergency || emergency.mode != SHUTTLE_CALL || adminEmergencyNoRecall || emergencyNoRecall || SSticker.mode.name == "meteor")
		return
	switch(SSsecurity_level.get_current_level_as_number())
		if(SEC_LEVEL_GREEN)
			if(emergency.timeLeft(1) < emergencyCallTime)
				return
		if(SEC_LEVEL_BLUE)
			if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
				return
		else
			if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
				return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	if (!SSticker.IsRoundInProgress())
		return

	var/callShuttle = TRUE

	for(var/thing in GLOB.shuttle_caller_list)
		if(isAI(thing))
			var/mob/living/silicon/ai/AI = thing
			if(AI.deployed_shell && !AI.deployed_shell.client)
				continue
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.machine_stat & BROKEN)
				continue

		var/turf/T = get_turf(thing)
		if(T && is_station_level(T.z))
			callShuttle = FALSE
			break

	if(callShuttle)
		if(EMERGENCY_IDLE_OR_RECALLED)
			emergency.request(null, set_coefficient = 2.5)
			log_shuttle("There is no means of calling the emergency shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")
			webhook_send_roundstatus("shuttle autocalled")

/datum/controller/subsystem/shuttle/proc/registerHostileEnvironment(datum/bad)
	hostileEnvironments[bad] = TRUE
	checkHostileEnvironment()

/datum/controller/subsystem/shuttle/proc/clearHostileEnvironment(datum/bad)
	hostileEnvironments -= bad
	checkHostileEnvironment()


/datum/controller/subsystem/shuttle/proc/registerTradeBlockade(datum/bad)
	tradeBlockade[bad] = TRUE
	checkTradeBlockade()

/datum/controller/subsystem/shuttle/proc/clearTradeBlockade(datum/bad)
	tradeBlockade -= bad
	checkTradeBlockade()


/datum/controller/subsystem/shuttle/proc/checkTradeBlockade()
	for(var/datum/d in tradeBlockade)
		if(!istype(d) || QDELETED(d))
			tradeBlockade -= d
	supplyBlocked = tradeBlockade.len

	if(supplyBlocked && (supply.mode == SHUTTLE_IGNITING))
		supply.mode = SHUTTLE_STRANDED
		supply.timer = null
		//Make all cargo consoles speak up
	if(!supplyBlocked && (supply.mode == SHUTTLE_STRANDED))
		supply.mode = SHUTTLE_DOCKED
		//Make all cargo consoles speak up

/datum/controller/subsystem/shuttle/proc/checkHostileEnvironment()
	for(var/datum/d in hostileEnvironments)
		if(!istype(d) || QDELETED(d))
			hostileEnvironments -= d
	emergencyNoEscape = hostileEnvironments.len

	if(emergencyNoEscape && (emergency.mode == SHUTTLE_IGNITING))
		emergency.mode = SHUTTLE_STRANDED
		emergency.timer = null
		emergency.sound_played = FALSE
		priority_announce("Обнаружены враждебные элементы. \
			Вылет отложен на неопределенный срок в ожидании \
			разрешения конфликта.", null, 'sound/misc/notice1.ogg', "Priority")
	if(!emergencyNoEscape && (emergency.mode == SHUTTLE_STRANDED))
		emergency.mode = SHUTTLE_DOCKED
		emergency.setTimer(emergencyDockTime)
		priority_announce("Враждебные элементы устранены. \
			У вас есть 3 минуты, чтобы сесть на эвакуационный шаттл.",
			null, ANNOUNCER_SHUTTLEDOCK, "Priority")

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/controller/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.docked
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.initiate_docking(getDock(destination)) != DOCKING_SUCCESS)
			return 2
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)

	if(!M)
		return 1
	if(timed)
		if(M.request(D))
			return 2
	else
		if(M.initiate_docking(D) != DOCKING_SUCCESS)
			return 2
	return 0	//dock successful

/datum/controller/subsystem/shuttle/proc/request_transit_dock(obj/docking_port/mobile/M)
	if(!istype(M))
		CRASH("[M] is not a mobile docking port")

	if(M.assigned_transit)
		return
	else
		if(!(M in transit_requesters))
			transit_requesters += M

/datum/controller/subsystem/shuttle/proc/generate_transit_dock(obj/docking_port/mobile/M)
	// First, determine the size of the needed zone
	// Because of shuttle rotation, the "width" of the shuttle is not
	// always x.
	var/travel_dir = M.preferred_direction
	// Remember, the direction is the direction we appear to be
	// coming from
	var/dock_angle = dir2angle(M.preferred_direction) + dir2angle(M.port_direction) + 180

	var/transit_width = SHUTTLE_TRANSIT_BORDER * 2
	var/transit_height = SHUTTLE_TRANSIT_BORDER * 2

	// Shuttles travelling on their side have their dimensions swapped
	// from our perspective
	var/list/union_coords = M.return_union_coords(M.get_all_towed_shuttles(), 0, 0, NORTH)
	transit_width += union_coords[3] - union_coords[1] + 1
	transit_height += union_coords[4] - union_coords[2] + 1

/*
	to_chat(world, "The attempted transit dock will be [transit_width] width, and \)
		[transit_height] in height. The travel dir is [travel_dir]."
*/

	var/transit_path = /turf/open/space/transit
	switch(travel_dir)
		if(NORTH)
			transit_path = /turf/open/space/transit/north
		if(SOUTH)
			transit_path = /turf/open/space/transit/south
		if(EAST)
			transit_path = /turf/open/space/transit/east
		if(WEST)
			transit_path = /turf/open/space/transit/west

	var/datum/turf_reservation/proposal = SSmapping.RequestBlockReservation(transit_width, transit_height, null, /datum/turf_reservation/transit, transit_path)

	if(!istype(proposal))
		return FALSE

	var/turf/bottomleft = locate(proposal.bottom_left_coords[1], proposal.bottom_left_coords[2], proposal.bottom_left_coords[3])
	// Then create a transit docking port in the middle
	var/matrix/dir_rotation = matrix(union_coords[1], union_coords[2], 0, union_coords[3], union_coords[4], 0) * matrix(dock_angle, MATRIX_ROTATE)
	/*		Shuttle Space		Dock Space
			*------s1			d1----------*
			|		|			|			|
			|		|	->		|		x	|	x = (0,0)
			|	x	|			|			|
			s0------*			*----------d0
		┌  ┐ ┌						 ┐	┌  ┐
		|s0| |  cos(dir)  sin(dir)	|	|d0|
		|s1| | -sin(dir)  cos(dir)	| = |d1|
		└  ┘ └						 ┘	└  ┘
	*/

	var/x0 = dir_rotation.a
	var/y0 = dir_rotation.b
	var/x1 = dir_rotation.d
	var/y1 = dir_rotation.e
	// Then we want the point closest to -infinity,-infinity
	var/x2 = min(x0, x1)
	var/y2 = min(y0, y1)

	// Then invert the numbers
	var/transit_x = bottomleft.x + SHUTTLE_TRANSIT_BORDER + abs(x2)
	var/transit_y = bottomleft.y + SHUTTLE_TRANSIT_BORDER + abs(y2)

	var/turf/midpoint = locate(transit_x, transit_y, bottomleft.z)
	if(!midpoint)
		qdel(proposal)
		return FALSE
	var/area/old_area = midpoint.loc
	old_area.turfs_to_uncontain += proposal.reserved_turfs
	var/area/shuttle/transit/A = new()
	A.parallax_movedir = travel_dir
	A.contents = proposal.reserved_turfs
	A.contained_turfs = proposal.reserved_turfs
	var/obj/docking_port/stationary/transit/new_transit_dock = new(midpoint)
	new_transit_dock.reserved_area = proposal
	new_transit_dock.name = "Transit for [M.id]/[M.name]"
	new_transit_dock.owner = M
	new_transit_dock.assigned_area = A

	// Add 180, because ports point inwards, rather than outwards
	new_transit_dock.setDir(angle2dir(dock_angle))

	// Proposals use 2 extra hidden tiles of space, from the cordons that surround them
	transit_utilized += (proposal.width + 2) * (proposal.height + 2)
	M.assigned_transit = new_transit_dock
	RegisterSignal(proposal, COMSIG_PARENT_QDELETING, PROC_REF(transit_space_clearing))

	return new_transit_dock

/// Gotta manage our space brother
/datum/controller/subsystem/shuttle/proc/transit_space_clearing(datum/turf_reservation/source)
	SIGNAL_HANDLER
	transit_utilized -= (source.width + 2) * (source.height + 2)

/datum/controller/subsystem/shuttle/Recover()
	initialized = SSshuttle.initialized
	if (istype(SSshuttle.mobile))
		mobile = SSshuttle.mobile
	if (istype(SSshuttle.stationary))
		stationary = SSshuttle.stationary
	if (istype(SSshuttle.transit))
		transit = SSshuttle.transit
	if (istype(SSshuttle.transit_requesters))
		transit_requesters = SSshuttle.transit_requesters
	if (istype(SSshuttle.transit_request_failures))
		transit_request_failures = SSshuttle.transit_request_failures

	if (istype(SSshuttle.emergency))
		emergency = SSshuttle.emergency
	if (istype(SSshuttle.arrivals))
		arrivals = SSshuttle.arrivals
	if (istype(SSshuttle.backup_shuttle))
		backup_shuttle = SSshuttle.backup_shuttle

	if (istype(SSshuttle.emergencyLastCallLoc))
		emergencyLastCallLoc = SSshuttle.emergencyLastCallLoc

	if (istype(SSshuttle.hostileEnvironments))
		hostileEnvironments = SSshuttle.hostileEnvironments

	if (istype(SSshuttle.supply))
		supply = SSshuttle.supply

	if (istype(SSshuttle.discoveredPlants))
		discoveredPlants = SSshuttle.discoveredPlants

	if (istype(SSshuttle.shoppinglist))
		shoppinglist = SSshuttle.shoppinglist
	if (istype(SSshuttle.requestlist))
		requestlist = SSshuttle.requestlist
	if (istype(SSshuttle.orderhistory))
		orderhistory = SSshuttle.orderhistory

	if (istype(SSshuttle.shuttle_loan))
		shuttle_loan = SSshuttle.shuttle_loan

	if (istype(SSshuttle.shuttle_purchase_requirements_met))
		shuttle_purchase_requirements_met = SSshuttle.shuttle_purchase_requirements_met

	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	centcom_message = SSshuttle.centcom_message
	ordernum = SSshuttle.ordernum
	points = D.account_balance
	emergencyNoEscape = SSshuttle.emergencyNoEscape
	emergencyCallAmount = SSshuttle.emergencyCallAmount
	shuttle_purchased = SSshuttle.shuttle_purchased
	lockdown = SSshuttle.lockdown

	selected = SSshuttle.selected

	existing_shuttle = SSshuttle.existing_shuttle

	preview_shuttle = SSshuttle.preview_shuttle
	preview_template = SSshuttle.preview_template

	preview_reservation = SSshuttle.preview_reservation

/datum/controller/subsystem/shuttle/proc/is_in_shuttle_bounds(atom/A)
	var/area/current = get_area(A)
	if(istype(current, /area/shuttle) && !istype(current, /area/shuttle/transit))
		return TRUE
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.is_in_shuttle_bounds(A))
			return TRUE

/datum/controller/subsystem/shuttle/proc/get_containing_shuttle(atom/A)
	var/list/mobile_cache = mobile
	for(var/i in 1 to mobile_cache.len)
		var/obj/docking_port/port = mobile_cache[i]
		if(port.is_in_shuttle_bounds(A))
			return port

/datum/controller/subsystem/shuttle/proc/get_containing_dock(atom/A)
	. = list()
	var/list/stationary_cache = stationary
	for(var/i in 1 to stationary_cache.len)
		var/obj/docking_port/port = stationary_cache[i]
		if(port.is_in_shuttle_bounds(A))
			. += port

/datum/controller/subsystem/shuttle/proc/get_dock_overlap(x0, y0, x1, y1, z)
	. = list()
	var/list/stationary_cache = stationary
	for(var/i in 1 to stationary_cache.len)
		var/obj/docking_port/port = stationary_cache[i]
		if(!port || port.z != z)
			continue
		var/list/bounds = port.return_coords()
		var/list/overlap = get_overlap(x0, y0, x1, y1, bounds[1], bounds[2], bounds[3], bounds[4])
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs.len && ys.len)
			.[port] = overlap

/datum/controller/subsystem/shuttle/proc/update_hidden_docking_ports(list/remove_turfs, list/add_turfs)
	var/list/remove_images = list()
	var/list/add_images = list()

	if(remove_turfs)
		for(var/T in remove_turfs)
			var/list/L = hidden_shuttle_turfs[T]
			if(L)
				remove_images += L[1]
		hidden_shuttle_turfs -= remove_turfs

	if(add_turfs)
		for(var/V in add_turfs)
			var/turf/T = V
			var/image/I
			if(remove_images.len)
				//we can just reuse any images we are about to delete instead of making new ones
				I = remove_images[1]
				remove_images.Cut(1, 2)
				I.loc = T
			else
				I = image(loc = T)
				add_images += I
			I.appearance = T.appearance
			I.override = TRUE
			hidden_shuttle_turfs[T] = list(I, T.type)

	hidden_shuttle_turf_images -= remove_images
	hidden_shuttle_turf_images += add_images

	for(var/V in GLOB.navigation_computers)
		var/obj/machinery/computer/shuttle_flight/C = V
		C.update_hidden_docking_ports(remove_images, add_images)

	QDEL_LIST(remove_images)

/**
 * Loads a shuttle template and sends it to a given destination port, optionally replacing the existing shuttle
 *
 * Arguments:
 * * loading_template - The shuttle template to load
 * * destination_port - The station docking port to send the shuttle to once loaded
 * * replace - Whether to replace the shuttle or create a new one
*/
/datum/controller/subsystem/shuttle/proc/action_load(datum/map_template/shuttle/loading_template, obj/docking_port/stationary/destination_port, replace = FALSE)
	// Check for an existing preview
	if(preview_shuttle && (loading_template != preview_template))
		preview_shuttle.jumpToNullSpace()
		preview_shuttle = null
		preview_template = null
		QDEL_NULL(preview_reservation)

	if(!preview_shuttle)
		if(load_template(loading_template))
			preview_shuttle.linkup(loading_template, destination_port)
		preview_template = loading_template

	// get the existing shuttle information, if any
	var/timer = 0
	var/mode = SHUTTLE_IDLE
	var/obj/docking_port/stationary/dest_dock

	if(istype(destination_port))
		dest_dock = destination_port
	else if(existing_shuttle && replace)
		timer = existing_shuttle.timer
		mode = existing_shuttle.mode
		dest_dock = existing_shuttle.docked

	if(!dest_dock)
		dest_dock = generate_transit_dock(preview_shuttle)

	if(!dest_dock)
		CRASH("No dock found for preview shuttle ([preview_template.name]), aborting.")

	var/result = preview_shuttle.canDock(dest_dock)
	// truthy value means that it cannot dock for some reason
	// but we can ignore the someone else docked error because we'll
	// be moving into their place shortly
	if((result != SHUTTLE_CAN_DOCK) && (result != SHUTTLE_SOMEONE_ELSE_DOCKED))
		WARNING("Template shuttle [preview_shuttle] cannot dock at [dest_dock] ([result]).")
		return

	if(existing_shuttle && replace)
		existing_shuttle.jumpToNullSpace()

	var/list/force_memory = preview_shuttle.movement_force
	preview_shuttle.movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)
	preview_shuttle.initiate_docking(dest_dock)
	preview_shuttle.movement_force = force_memory

	. = preview_shuttle

	// Shuttle state involves a mode and a timer based on world.time, so
	// plugging the existing shuttles old values in works fine.
	preview_shuttle.timer = timer
	preview_shuttle.mode = mode

	preview_shuttle.register(replace)

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab
	preview_shuttle = null
	preview_template = null
	existing_shuttle = null
	selected = null
	QDEL_NULL(preview_reservation)

/**
 * Loads a shuttle template into the transit Z level, usually referred to elsewhere in the code as a shuttle preview.
 * Does not register the shuttle so it can't be used yet, that's handled in action_load()
 *
 * Arguments:
 * * loading_template - The shuttle template to load
 */
/datum/controller/subsystem/shuttle/proc/load_template(datum/map_template/shuttle/loading_template)
	. = FALSE
	// Load shuttle template to a fresh block reservation.
	preview_reservation = SSmapping.RequestBlockReservation(loading_template.width, loading_template.height, type = /datum/turf_reservation/transit)
	if(!preview_reservation)
		CRASH("failed to reserve an area for shuttle template loading")
	var/turf/bottom_left = TURF_FROM_COORDS_LIST(preview_reservation.bottom_left_coords)
	loading_template.load(bottom_left, centered = FALSE, register = FALSE)

	var/affected = loading_template.get_affected_turfs(bottom_left, centered=FALSE)

	var/found = 0
	// Search the turfs for docking ports
	// - We need to find the mobile docking port because that is the heart of
	//   the shuttle.
	// - We need to check that no additional ports have slipped in from the
	//   template, because that causes unintended behaviour.
	for(var/affected_turfs in affected)
		for(var/obj/docking_port/port in affected_turfs)
			if(istype(port, /obj/docking_port/mobile))
				found++
				if(found > 1)
					qdel(port, force=TRUE)
					log_mapping("Shuttle Template [loading_template.mappath] has multiple mobile docking ports.")
				else
					preview_shuttle = port
	if(!found)
		var/msg = "load_template(): Shuttle Template [loading_template.mappath] has no mobile docking port. Aborting import."
		for(var/affected_turfs in affected)
			var/turf/T0 = affected_turfs
			T0.empty()

		message_admins(msg)
		WARNING(msg)
		return
	//Everything fine
	loading_template.post_load(preview_shuttle)
	return TRUE

/**
 * Removes the preview_shuttle from the transit Z-level
 */
/datum/controller/subsystem/shuttle/proc/unload_preview()
	if(preview_shuttle)
		preview_shuttle.jumpToNullSpace()
	preview_shuttle = null

/datum/controller/subsystem/shuttle/ui_state(mob/user)
	return GLOB.admin_state

/datum/controller/subsystem/shuttle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleManipulator")
		ui.open()

/datum/controller/subsystem/shuttle/ui_data(mob/user)
	var/list/data = list()
	data["tabs"] = list("Status", "Templates", "Modification")

	// Templates panel
	data["templates"] = list()
	var/list/templates = data["templates"]
	data["templates_tabs"] = list()
	data["selected"] = list()

	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

		if(!templates[S.port_id])
			data["templates_tabs"] += S.port_id
			templates[S.port_id] = list(
				"port_id" = S.port_id,
				"templates" = list())

		var/list/L = list()
		L["name"] = S.name
		L["shuttle_id"] = S.shuttle_id
		L["port_id"] = S.port_id
		L["description"] = S.description
		L["admin_notes"] = S.admin_notes

		if(selected == S)
			data["selected"] = L

		templates[S.port_id]["templates"] += list(L)

	data["templates_tabs"] = sort_list(data["templates_tabs"])

	data["existing_shuttle"] = null

	// Status panel
	data["shuttles"] = list()
	for(var/i in mobile)
		var/obj/docking_port/mobile/M = i
		var/timeleft = M.timeLeft(1)
		var/list/L = list()
		L["name"] = M.name
		L["id"] = M.id
		L["timer"] = M.timer
		L["timeleft"] = M.getTimerStr()
		if (timeleft > 1 HOURS)
			L["timeleft"] = "Infinity"
		L["can_fast_travel"] = M.timer && timeleft >= 50
		L["can_fly"] = TRUE
		if(istype(M, /obj/docking_port/mobile/emergency))
			L["can_fly"] = FALSE
		else if(!M.destination)
			L["can_fast_travel"] = FALSE
		if (M.mode != SHUTTLE_IDLE)
			L["mode"] = capitalize(M.mode)
		L["status"] = M.getDbgStatusText()
		if(M == existing_shuttle)
			data["existing_shuttle"] = L

		data["shuttles"] += list(L)

	return data

/datum/controller/subsystem/shuttle/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	// Preload some common parameters
	var/shuttle_id = params["shuttle_id"]
	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

	switch(action)
		if("select_template")
			if(S)
				existing_shuttle = getShuttle(S.port_id)
				selected = S
				. = TRUE
		if("jump_to")
			if(params["type"] == "mobile")
				for(var/i in mobile)
					var/obj/docking_port/mobile/M = i
					if(M.id == params["id"])
						user.forceMove(get_turf(M))
						. = TRUE
						break

		if("fly")
			for(var/i in mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == params["id"])
					. = TRUE
					M.admin_fly_shuttle(user)
					break

		if("fast_travel")
			for(var/i in mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == params["id"] && M.timer && M.timeLeft(1) >= 50)
					M.setTimer(50)
					. = TRUE
					message_admins("[key_name_admin(usr)] fast travelled [M]")
					log_admin("[key_name(usr)] fast travelled [M]")
					SSblackbox.record_feedback("text", "shuttle_manipulator", 1, "[M.name]")
					break

		if("load")
			if(S && !shuttle_loading)
				. = TRUE
				shuttle_loading = TRUE
				// If successful, returns the mobile docking port
				var/obj/docking_port/mobile/mdp = action_load(S)
				if(mdp)
					user.forceMove(get_turf(mdp))
					message_admins("[key_name_admin(usr)] loaded [mdp] with the shuttle manipulator.")
					log_admin("[key_name(usr)] loaded [mdp] with the shuttle manipulator.</span>")
					SSblackbox.record_feedback("text", "shuttle_manipulator", 1, "[mdp.name]")
				shuttle_loading = FALSE

		if("preview")
			//if(preview_shuttle && (loading_template != preview_template))
			if(S && !shuttle_loading)
				. = TRUE
				shuttle_loading = TRUE
				unload_preview()
				load_template(S)
				if(preview_shuttle)
					preview_template = S
					user.forceMove(get_turf(preview_shuttle))
				shuttle_loading = FALSE

		if("replace")
			if(existing_shuttle == backup_shuttle)
				// TODO make the load button disabled
				WARNING("The shuttle that the selected shuttle will replace \
					is the backup shuttle. Backup shuttle is required to be \
					intact for round sanity.")
			else if(S && !shuttle_loading)
				. = TRUE
				shuttle_loading = TRUE
				// If successful, returns the mobile docking port
				var/obj/docking_port/mobile/mdp = action_load(S, replace = TRUE)
				if(mdp)
					user.forceMove(get_turf(mdp))
					message_admins("[key_name_admin(usr)] load/replaced [mdp] with the shuttle manipulator.")
					log_admin("[key_name(usr)] load/replaced [mdp] with the shuttle manipulator.</span>")
					SSblackbox.record_feedback("text", "shuttle_manipulator", 1, "[mdp.name]")
				shuttle_loading = FALSE
				if(emergency == mdp) //you just changed the emergency shuttle, there are events in game + captains that can change your snowflake choice.
					var/set_purchase = tgui_alert(usr, "Do you want to also disable shuttle purchases/random events that would change the shuttle?", "Butthurt Admin Prevention", list("Yes, disable purchases/events", "No, I want to possibly get owned"))
					if(set_purchase == "Yes, disable purchases/events")
						SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_FORCED