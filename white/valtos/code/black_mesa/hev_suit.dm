
#define HEV_COLOR_GREEN "#00ff00"
#define HEV_COLOR_RED "#ff0000"
#define HEV_COLOR_BLUE "#00aeff"
#define HEV_COLOR_ORANGE "#f88f04"

#define HEV_ARMOR_POWERON_BONUS 60

#define HEV_DAMAGE_POWER_USE_THRESHOLD 10

#define HEV_ARMOR_POWEROFF list(20, 20, 20, 20, 30, 40, 40, 40, 40, 10)
#define PCV_ARMOR_POWEROFF list(30, 30, 30, 30, 30, 30, 20, 20, 20, 10)

#define HEV_ARMOR_POWERON list(80, 80, 80, 80, 100, 100, 100, 100, 100, 60)
#define PCV_ARMOR_POWERON list(60, 60, 60, 60, 80, 80, 70, 70, 70, 50)

#define HEV_POWERUSE_AIRTANK 2

#define HEV_POWERUSE_HIT 100
#define HEV_POWERUSE_HEAL 150

#define HEV_COOLDOWN_HEAL 10 SECONDS
#define HEV_COOLDOWN_RADS 20 SECONDS
#define HEV_COOLDOWN_ACID 20 SECONDS
#define PCV_COOLDOWN_HEAL 15 SECONDS
#define PCV_COOLDOWN_RADS 30 SECONDS
#define PCV_COOLDOWN_ACID 30 SECONDS

#define HEV_HEAL_AMOUNT 10
#define PCV_HEAL_AMOUNT 5
#define HEV_BLOOD_REPLENISHMENT 20
#define PCV_BLOOD_REPLENISHMENT 10

#define HEV_NOTIFICATION_TEXT_AND_VOICE "VOICE_AND_TEXT"
#define HEV_NOTIFICATION_TEXT "TEXT_ONLY"
#define HEV_NOTIFICATION_VOICE "VOICE_ONLY"
#define HEV_NOTIFICATION_OFF "OFF"
#define HEV_NOTIFICATIONS list(HEV_NOTIFICATION_TEXT_AND_VOICE, HEV_NOTIFICATION_TEXT, HEV_NOTIFICATION_VOICE, HEV_NOTIFICATION_OFF)

/obj/item/clothing/head/helmet/space/hev_suit
	name = "защитный костюм HEV"
	desc = "Шлем Марк IV для защитного костюма."
	icon = 'white/valtos/icons/black_mesa/hats.dmi'
	worn_icon = 'white/valtos/icons/black_mesa/head.dmi'
	icon_state = "hev"
	inhand_icon_state = "sec_helm"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 40, FIRE = 40, ACID = 40, WOUND = 10)
	obj_flags = NO_MAT_REDEMPTION
	resistance_flags = LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF|INDESTRUCTIBLE|FREEZE_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|SNUG_FIT|LAVAPROTECT|BLOCK_GAS_SMOKE_EFFECT
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_flags = STOPSPRESSUREDAMAGE
	dog_fashion = null
	slowdown = 0

/obj/item/clothing/suit/space/hev_suit
	name = "защитный костюм HEV"
	desc = "Данный костюм Марк IV защищает пользователя от ряда опасных сред и имеет встроенную баллистическую защиту."
	icon = 'white/valtos/icons/black_mesa/suits.dmi'
	worn_icon = 'white/valtos/icons/black_mesa/suit.dmi'
	icon_state = "hev"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 40, FIRE = 40, ACID = 40, WOUND = 10) //This is gordons suit, of course it's strong.
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	cell = /obj/item/stock_parts/cell/hyper
	slowdown = 0 //I am not gimping doctor freeman
	actions_types = list(/datum/action/item_action/hev_toggle, /datum/action/item_action/hev_toggle_notifs, /datum/action/item_action/toggle_helmet, /datum/action/item_action/toggle_spacesuit)
	resistance_flags = LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF|INDESTRUCTIBLE|FREEZE_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|SNUG_FIT|LAVAPROTECT

	///Whether or not the suit is activated/activating.
	var/activated = FALSE
	var/activating = FALSE

	///Defines the current user (duh), current helmet, internals tank and built-in radio.
	var/mob/living/carbon/current_user
	var/obj/item/clothing/head/helmet/space/hev_suit/current_helmet
	var/obj/item/tank/internals/current_internals_tank
	var/obj/item/radio/internal_radio

	///Used by the healing system.
	var/user_old_bruteloss
	var/user_old_fireloss
	var/user_old_toxloss
	var/user_old_cloneloss
	var/user_old_oxyloss

	///Lots of sound vars.
	var/activation_song = 'white/valtos/sounds/black_mesa/hev/anomalous_materials.ogg'

	var/logon_sound = 'white/valtos/sounds/black_mesa/hev/01_hev_logon.ogg'
	var/armor_sound = 'white/valtos/sounds/black_mesa/hev/02_powerarmor_on.ogg'
	var/atmospherics_sound = 'white/valtos/sounds/black_mesa/hev/03_atmospherics_on.ogg'
	var/vitalsigns_sound = 'white/valtos/sounds/black_mesa/hev/04_vitalsigns_on.ogg'
	var/automedic_sound = 'white/valtos/sounds/black_mesa/hev/05_automedic_on.ogg'
	var/weaponselect_sound = 'white/valtos/sounds/black_mesa/hev/06_weaponselect_on.ogg'
	var/munitions_sound = 'white/valtos/sounds/black_mesa/hev/07_munitionview_on.ogg'
	var/communications_sound = 'white/valtos/sounds/black_mesa/hev/08_communications_on.ogg'
	var/safe_day_sound = 'white/valtos/sounds/black_mesa/hev/09_safe_day.ogg'

	var/batt_50_sound = 'white/valtos/sounds/black_mesa/hev/power_level_is_fifty.ogg'
	var/batt_40_sound = 'white/valtos/sounds/black_mesa/hev/power_level_is_fourty.ogg'
	var/batt_30_sound = 'white/valtos/sounds/black_mesa/hev/power_level_is_thirty.ogg'
	var/batt_20_sound = 'white/valtos/sounds/black_mesa/hev/power_level_is_twenty.ogg'
	var/batt_10_sound = 'white/valtos/sounds/black_mesa/hev/power_level_is_ten.ogg'

	var/near_death_sound = 'white/valtos/sounds/black_mesa/hev/near_death.ogg'
	var/health_critical_sound = 'white/valtos/sounds/black_mesa/hev/health_critical.ogg'
	var/health_dropping_sound = 'white/valtos/sounds/black_mesa/hev/health_dropping2.ogg'

	var/blood_loss_sound = 'white/valtos/sounds/black_mesa/hev/blood_loss.ogg'
	var/blood_toxins_sound = 'white/valtos/sounds/black_mesa/hev/blood_toxins.ogg'
	var/biohazard_sound = 'white/valtos/sounds/black_mesa/hev/biohazard_detected.ogg'
	var/chemical_sound = 'white/valtos/sounds/black_mesa/hev/chemical_detected.ogg'

	var/minor_fracture_sound = 'white/valtos/sounds/black_mesa/hev/minor_fracture.ogg'
	var/major_fracture_sound = 'white/valtos/sounds/black_mesa/hev/major_fracture.ogg'
	var/minor_lacerations_sound = 'white/valtos/sounds/black_mesa/hev/minor_lacerations.ogg'
	var/major_lacerations_sound = 'white/valtos/sounds/black_mesa/hev/major_lacerations.ogg'

	var/morphine_sound = 'white/valtos/sounds/black_mesa/hev/morphine_shot.ogg'
	var/wound_sound = 'white/valtos/sounds/black_mesa/hev/wound_sterilized.ogg'
	var/antitoxin_sound = 'white/valtos/sounds/black_mesa/hev/antitoxin_shot.ogg'
	var/antidote_sound = 'white/valtos/sounds/black_mesa/hev/antidote_shot.ogg'

	var/radio_channel = RADIO_CHANNEL_COMMON

	var/timer_id = null

	///Action cooldowns, duh.
	var/voice_current_cooldown
	var/healing_current_cooldown
	var/health_statement_cooldown
	var/battery_statement_cooldown
	var/acid_statement_cooldown
	var/rad_statement_cooldown

	///Static cooldowns for even more armor differentiation, duuh.
	var/health_static_cooldown = HEV_COOLDOWN_HEAL
	var/rads_static_cooldown = HEV_COOLDOWN_RADS
	var/acid_static_cooldown = HEV_COOLDOWN_ACID

	///Muh alarms
	var/blood_loss_alarm = FALSE
	var/toxins_alarm = FALSE
	var/batt_50_alarm = FALSE
	var/batt_40_alarm = FALSE
	var/batt_30_alarm = FALSE
	var/batt_20_alarm = FALSE
	var/batt_10_alarm = FALSE
	var/health_near_death_alarm = FALSE
	var/health_critical_alarm = FALSE
	var/health_dropping_alarm = FALSE
	var/seek_medical_attention_alarm = FALSE

	///Notification modes and current playing voicelines.
	var/send_notifications = HEV_NOTIFICATION_TEXT_AND_VOICE
	var/playing_voice_line

	///Used only for differentiating of HEV and PCV
	var/armor_poweroff = HEV_ARMOR_POWEROFF
	var/armor_poweron = HEV_ARMOR_POWERON
	var/heal_amount = HEV_HEAL_AMOUNT
	var/blood_replenishment = HEV_BLOOD_REPLENISHMENT
	var/suit_name = "HEV MARK IV"

	var/list/queued_voice_lines = list()

	/// On first activation, we play the user a nice song!
	var/first_use = TRUE

/obj/item/clothing/suit/space/hev_suit/Initialize(mapload)
	. = ..()
	internal_radio = new(src)
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0 // anything greater will have the bot broadcast the channel as if it were saying it out loud.
	internal_radio.recalculateChannels()

/obj/item/clothing/suit/space/hev_suit/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/cell, cell_override = cell, _has_cell_overlays = FALSE)

/obj/item/clothing/suit/space/hev_suit/equipped(mob/user, slot)
	. = ..()
	current_user = user

/obj/item/clothing/suit/space/hev_suit/dropped()
	. = ..()
	deactivate()
	if(current_internals_tank)
		current_internals_tank = null
	current_helmet = null
	current_user = null

/obj/item/clothing/suit/space/hev_suit/Destroy()
	if(internal_radio)
		qdel(internal_radio)
	if(current_internals_tank)
		REMOVE_TRAIT(current_internals_tank, TRAIT_NODROP, "hev_trait")
		current_internals_tank = null
	current_helmet = null
	deactivate()
	current_user = null
	return ..()

/datum/action/item_action/hev_toggle
	name = "переключить костюм"
	button_icon = 'white/valtos/icons/black_mesa/toggles.dmi'
	background_icon_state = "bg_hl"
	button_icon = 'white/valtos/icons/black_mesa/toggles.dmi'
	button_icon_state = "system_off"

/datum/action/item_action/hev_toggle_notifs
	name = "переключить уведомления костюма"
	button_icon = 'white/valtos/icons/black_mesa/toggles.dmi'
	background_icon_state = "bg_hl"
	button_icon = 'white/valtos/icons/black_mesa/toggles.dmi'
	button_icon_state = "sound_VOICE_AND_TEXT"

/datum/action/item_action/hev_toggle_notifs/Trigger(trigger_flags)
	var/obj/item/clothing/suit/space/hev_suit/my_suit = target
	var/new_setting = tgui_input_list(my_suit.current_user, "Выберите тип уведомлений.", "Настройки HEV", HEV_NOTIFICATIONS)

	if(!new_setting)
		new_setting = HEV_NOTIFICATION_TEXT_AND_VOICE

	to_chat(my_suit.current_user, span_notice("Уведомления [my_suit] теперь [new_setting]."))

	my_suit.send_notifications = new_setting

	button_icon_state = "sound_[new_setting]"

	playsound(my_suit, 'white/valtos/sounds/black_mesa/hev/blip.ogg', 50)

	build_all_button_icons()

/datum/action/item_action/hev_toggle/Trigger(trigger_flags)
	var/obj/item/clothing/suit/space/hev_suit/my_suit = target

	if(my_suit.activated)
		my_suit.deactivate()
	else
		my_suit.activate()

	var/toggle = FALSE

	if(my_suit.activated || my_suit.activating)
		toggle = TRUE

	button_icon_state = toggle ? "system_on" : "system_off"

	playsound(my_suit, 'white/valtos/sounds/black_mesa/hev/blip.ogg', 50)

	build_all_button_icons()

/obj/item/clothing/suit/space/hev_suit/proc/send_message(message, color = HEV_COLOR_ORANGE)
	if(send_notifications != HEV_NOTIFICATION_TEXT_AND_VOICE && send_notifications != HEV_NOTIFICATION_TEXT)
		return
	if(!current_user)
		return
	to_chat(current_user, "[suit_name]: <span style='color: [color];'>[message]</span>")

/obj/item/clothing/suit/space/hev_suit/proc/send_hev_sound(sound_in, priority, volume = 50)
	if(send_notifications != HEV_NOTIFICATION_TEXT_AND_VOICE && send_notifications != HEV_NOTIFICATION_VOICE)
		return

	if(!activated)
		return

	if(playing_voice_line)
		if(priority) //Shit's fucked, we better say this ASAP
			queued_voice_lines.Insert(1, sound_in)
		else
			queued_voice_lines += sound_in
		return

	if(queued_voice_lines.len)
		var/voice_line = queued_voice_lines[1]
		var/sound/voice = sound(voice_line, wait = 1, channel = CHANNEL_HEV)
		voice.status = SOUND_STREAM
		playing_voice_line = TRUE
		playsound(src, voice, volume)
		queued_voice_lines -= voice_line
		addtimer(CALLBACK(src, PROC_REF(reset_sound)), 4 SECONDS)
		return

	playing_voice_line = TRUE

	var/sound/voice = sound(sound_in, wait = 1, channel = CHANNEL_HEV)
	voice.status = SOUND_STREAM
	playsound(src, voice, volume)

	addtimer(CALLBACK(src, PROC_REF(reset_sound)), 4 SECONDS)

/obj/item/clothing/suit/space/hev_suit/proc/reset_sound()
	playing_voice_line = FALSE
	send_hev_sound()

/obj/item/clothing/suit/space/hev_suit/proc/activate()
	if(!current_user)
		return FALSE

	if(activating || activated)
		send_message("ОШИБКА - СИСТЕМА [activating ? "ВКЛЮЧАЕТСЯ" : "ВКЛЮЧЕНА"]", HEV_COLOR_RED)
		return FALSE

	var/power_test = item_use_power(10, TRUE)
	if(!(power_test & COMPONENT_POWER_SUCCESS))
		var/failure_reason
		switch(power_test)
			if(COMPONENT_NO_CELL)
				failure_reason = "БАТАРЕЯ НЕ ОБНАРУЖЕНА"
			if(COMPONENT_NO_CHARGE)
				failure_reason = "ЗАРЯД БАТАРЕИ НА НУЛЕ"
			else
				failure_reason = "ОШИБКА БАТАРЕИ"
		send_message("ОШИБКА - СБОЙ ПИТАНИЯ - [failure_reason]", HEV_COLOR_RED)
		return FALSE

	var/obj/item/clothing/head/helmet/space/hev_suit/helmet = current_user.head

	if(!helmet || !istype(helmet))
		send_message("ОШИБКА - ШЛЕМ НЕ ОБНАРУЖЕН", HEV_COLOR_RED)
		return FALSE

	current_helmet = helmet

	ADD_TRAIT(current_helmet, TRAIT_NODROP, "hev_trait")

	send_message("АКТИВАЦИЯ СИСТЕМЫ")
	activating = TRUE

	if(first_use && !SSviolence.active)
		var/sound/song = sound(activation_song, volume = 50)
		SEND_SOUND(current_user, song)
		first_use = FALSE

	playsound(src, logon_sound, 50)

	send_message("ПОДКЛЮЧЕНИЕ К ШЛЕМУ...")
	send_message("...ШЛЕМ ПОДКЛЮЧЁН", HEV_COLOR_GREEN)

	send_message("КАЛИБРОВКА МУСКУЛЬНЫХ УСИЛИТЕЛЕЙ...")
	send_message("...КАЛИБРОВКА УСПЕШНА", HEV_COLOR_GREEN)

	send_message("КАЛИБРОВКА УДАРОСТОЙКОЙ БРОНИ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(powerarmor)), 10 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/use_hev_power(amount)
	var/power_test = item_use_power(amount)
	if(!(power_test & COMPONENT_POWER_SUCCESS))
		var/failure_reason
		switch(power_test)
			if(COMPONENT_NO_CELL)
				failure_reason = "БАТАРЕЯ НЕ УСТАНОВЛЕНА"
			if(COMPONENT_NO_CHARGE)
				failure_reason = "ЗАРЯД БАТАРЕИ НА НУЛЕ"
			else
				failure_reason = "СБОЙ БАТАРЕИ"
		send_message("ОШИБКА - СБОЙ ПИТАНИЯ - [failure_reason]", HEV_COLOR_RED)
		deactivate()
		return FALSE
	announce_battery()
	return TRUE

/obj/item/clothing/suit/space/hev_suit/proc/announce_battery()
	var/datum/component/cell/my_cell = GetComponent(/datum/component/cell)
	var/current_battery_charge = my_cell.inserted_cell.percent()

	if(current_battery_charge <= 10 && !batt_10_alarm)
		send_hev_sound(batt_10_sound)
		batt_10_alarm = TRUE
		return
	else if(current_battery_charge > 10 && batt_10_alarm)
		batt_10_alarm = FALSE

	if(current_battery_charge > 10 && current_battery_charge <= 20 && !batt_20_alarm)
		send_hev_sound(batt_20_sound)
		batt_20_alarm = TRUE
		return
	else if(current_battery_charge > 20 && batt_20_alarm)
		batt_20_alarm = FALSE

	if(current_battery_charge > 20 && current_battery_charge <= 30 && !batt_30_alarm)
		send_hev_sound(batt_30_sound)
		batt_30_alarm = TRUE
		return
	else if(current_battery_charge > 30 && batt_30_alarm)
		batt_30_alarm = FALSE

	if(current_battery_charge > 30 && current_battery_charge <= 40 && !batt_40_alarm)
		send_hev_sound(batt_40_sound)
		batt_40_alarm = TRUE
		return
	else if(current_battery_charge > 40 && batt_40_alarm)
		batt_40_alarm = FALSE

	if(current_battery_charge > 40 && current_battery_charge <= 50 && !batt_50_alarm)
		send_hev_sound(batt_50_sound)
		batt_50_alarm = TRUE
		return
	else if(current_battery_charge > 50 && batt_50_alarm)
		batt_50_alarm = FALSE

/obj/item/clothing/suit/space/hev_suit/proc/powerarmor()
	armor = armor.setRating(
		armor_poweron[1],
		armor_poweron[2],
		armor_poweron[3],
		armor_poweron[4],
		armor_poweron[5],
		armor_poweron[6],
		armor_poweron[7],
		armor_poweron[8],
		armor_poweron[9],
		armor_poweron[10]
		)
	current_helmet.armor = current_helmet.armor.setRating(
		armor_poweron[1],
		armor_poweron[2],
		armor_poweron[3],
		armor_poweron[4],
		armor_poweron[5],
		armor_poweron[6],
		armor_poweron[7],
		armor_poweron[8],
		armor_poweron[9],
		armor_poweron[10]
		)
	user_old_bruteloss = current_user.getBruteLoss()
	user_old_fireloss = current_user.getFireLoss()
	user_old_toxloss = current_user.getToxLoss()
	user_old_cloneloss = current_user.getCloneLoss()
	user_old_oxyloss = current_user.getOxyLoss()
	RegisterSignal(current_user, COMSIG_MOB_RUN_ARMOR, PROC_REF(process_hit))
	playsound(src, armor_sound, 50)
	send_message("...ПРОИЗВЕДЕНА", HEV_COLOR_GREEN)
	send_message("ДАТЧИК АТМОСФЕРНОГО ЗАГРЯЗНЕНИЯ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(atmospherics)), 4 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/process_hit()
	SIGNAL_HANDLER
	var/new_bruteloss = current_user.getBruteLoss()
	var/new_fireloss = current_user.getFireLoss()
	var/new_toxloss = current_user.getToxLoss()
	var/new_cloneloss = current_user.getCloneLoss()
	var/new_oxyloss = current_user.getOxyLoss()
	var/use_power_this_hit = FALSE
	if(current_user.getBruteLoss() > (new_bruteloss + HEV_DAMAGE_POWER_USE_THRESHOLD))
		use_power_this_hit = TRUE
	if(current_user.getFireLoss() > (new_fireloss + HEV_DAMAGE_POWER_USE_THRESHOLD))
		use_power_this_hit = TRUE
	if(current_user.getToxLoss() > (new_toxloss + HEV_DAMAGE_POWER_USE_THRESHOLD))
		use_power_this_hit = TRUE
	if(current_user.getCloneLoss() > (new_cloneloss + HEV_DAMAGE_POWER_USE_THRESHOLD))
		use_power_this_hit = TRUE
	user_old_bruteloss = new_bruteloss
	user_old_fireloss = new_fireloss
	user_old_toxloss = new_toxloss
	user_old_cloneloss = new_cloneloss
	user_old_oxyloss = new_oxyloss
	state_health()
	if(use_power_this_hit)
		use_hev_power(HEV_POWERUSE_HIT)

/obj/item/clothing/suit/space/hev_suit/proc/state_health()
	var/health_percent = round((current_user.health / current_user.maxHealth) * 100, 1)

	if(health_percent <= 20 && !health_near_death_alarm)
		send_hev_sound(near_death_sound, TRUE)
		health_near_death_alarm = TRUE
		return
	else if(health_percent > 20 && health_near_death_alarm)
		health_near_death_alarm = FALSE

	if(health_percent > 20 && health_percent <= 30 && !health_critical_alarm)
		send_hev_sound(health_critical_sound, TRUE)
		health_critical_alarm = TRUE
		return
	else if(health_percent > 30 && health_critical_alarm)
		health_critical_alarm = FALSE

	if(health_percent > 30 && health_percent <= 80 && !health_dropping_alarm)
		send_hev_sound(health_dropping_sound, TRUE)
		health_dropping_alarm = TRUE
		return
	else if(health_percent > 80 && health_dropping_alarm)
		health_dropping_alarm = FALSE

/obj/item/clothing/suit/space/hev_suit/proc/atmospherics()
	var/obj/item/tank/internals/tank = current_user.get_item_by_slot(ITEM_SLOT_SUITSTORE)
	if(!tank || !istype(tank))
		send_message("...ОШИБКА, НЕ ОБНАРУЖЕН КИСЛОРОДНЫЙ БАЛЛОН", HEV_COLOR_RED)
		send_message("БИОМОНИТОРИНГ ЗДОРОВЬЯ...")
		timer_id = addtimer(CALLBACK(src, PROC_REF(vitalsigns)), 4 SECONDS, TIMER_STOPPABLE)
		return
	current_internals_tank = tank
	ADD_TRAIT(current_internals_tank, TRAIT_NODROP, "hev_trait")
	to_chat(current_user, span_notice("Слышу щелчок как [current_internals_tank] закрепляется в костюме."))
	playsound(src, atmospherics_sound, 50)
	send_message("...ОТКАЛИБРОВАН", HEV_COLOR_GREEN)
	send_message("БИОМОНИТОРИНГ ЗДОРОВЬЯ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(vitalsigns)), 4 SECONDS, TIMER_STOPPABLE)


/obj/item/clothing/suit/space/hev_suit/proc/handle_tank()
	if(!current_internals_tank)
		return
	if(use_hev_power(HEV_POWERUSE_AIRTANK))
		current_internals_tank.populate_gas()

/obj/item/clothing/suit/space/hev_suit/proc/vitalsigns()
	RegisterSignal(current_user, COMSIG_MOB_STATCHANGE, PROC_REF(stat_changed))
	playsound(src, vitalsigns_sound, 50)
	send_message("...АКТИВИРОВАН", HEV_COLOR_GREEN)
	send_message("СИСТЕМА ЖИЗНЕОБЕСПЕЧЕНИЯ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(medical_systems)), 3 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/stat_changed(datum/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD)
		playsound(src, 'white/valtos/sounds/black_mesa/hev/flatline.ogg', 40)
		internal_radio.talk_into(src, "ВНИМАНИЕ! ПОЛЬЗОВАТЕЛЬ [uppertext(current_user.real_name)] МЁРТВ. МЕСТОПОЛОЖЕНИЕ ПОЛЬЗОВАТЕЛЯ: [loc.x], [loc.y], [loc.z]!", radio_channel)
		deactivate()

/obj/item/clothing/suit/space/hev_suit/proc/medical_systems()
	RegisterSignal(current_user, COMSIG_CARBON_GAIN_WOUND, PROC_REF(process_wound))
	RegisterSignal(current_user, COMSIG_ATOM_ACID_ACT, PROC_REF(process_acid))
	START_PROCESSING(SSobj, src)
	playsound(src, automedic_sound, 50)
	send_message("...ВКЛЮЧЕНА", HEV_COLOR_GREEN)
	send_message("СИСТЕМА ЖИЗНЕОБЕСПЕЧЕНИЯ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(weaponselect)), 3 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/process(delta_time)
	if(!activated)
		return
	if(current_user.blood_volume < BLOOD_VOLUME_OKAY)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.blood_volume += blood_replenishment
		if(!blood_loss_alarm)
			send_hev_sound(blood_loss_sound)
			blood_loss_alarm = TRUE
	else if(blood_loss_alarm && current_user.blood_volume >= BLOOD_VOLUME_OKAY)
		blood_loss_alarm = FALSE

	var/diseased = FALSE

	for(var/thing in current_user.diseases)
		var/datum/disease/disease_to_kill = thing
		disease_to_kill.cure()
		diseased = TRUE

	if(diseased)
		send_hev_sound(biohazard_sound)
		send_message("БОЛЕЗНЬ ИЗЛЕЧЕНА", HEV_COLOR_BLUE)

	handle_tank()

	if(current_user.getToxLoss() > 30 && !toxins_alarm)
		send_hev_sound(blood_toxins_sound)
		toxins_alarm = TRUE
	else if(toxins_alarm && current_user.getToxLoss() <= 30)
		toxins_alarm = FALSE

	if(current_user.all_wounds)
		var/datum/wound/wound2fix = current_user.all_wounds[1]
		wound2fix.remove_wound()
		send_message("ТРАВМА ОБРАБОТАНА", HEV_COLOR_BLUE)

	if(world.time <= healing_current_cooldown)
		return

	var/new_bruteloss = current_user.getBruteLoss()
	var/new_fireloss = current_user.getFireLoss()
	var/new_toxloss = current_user.getToxLoss()
	var/new_cloneloss = current_user.getCloneLoss()
	var/new_oxyloss = current_user.getOxyLoss()
	var/new_stamloss = current_user.getStaminaLoss()

	if(new_stamloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustStaminaLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown * 2

	if(new_oxyloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustOxyLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown
			send_message("АДРЕНАЛИН ВВЕДЁН", HEV_COLOR_BLUE)
			send_hev_sound(morphine_sound)
		return

	if(new_bruteloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustBruteLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown
			send_message("ПРОТИВОТРАВМИРУЮЩЕЕ ВЕЩЕСТВО ВВЕДЕНО", HEV_COLOR_BLUE)
			send_hev_sound(wound_sound)
		return

	if(new_fireloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustFireLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown
			send_message("ПРОТИВООЖОГОВОЕ ВЕЩЕСТВО ВВЕДЕНО", HEV_COLOR_BLUE)
			send_hev_sound(wound_sound)
		return

	if(new_toxloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustToxLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown
			send_message("АНТИТОКСИН ВВЕДЁН", HEV_COLOR_BLUE)
			send_hev_sound(antitoxin_sound)
		return

	if(new_cloneloss)
		if(use_hev_power(HEV_POWERUSE_HEAL))
			current_user.adjustCloneLoss(-HEV_HEAL_AMOUNT)
			healing_current_cooldown = world.time + health_static_cooldown
			send_message("КЛЕТОЧНЫЙ СТАБИЛИЗАТОР ВВЕДЁН", HEV_COLOR_BLUE)
			send_hev_sound(antidote_sound)
		return

/obj/item/clothing/suit/space/hev_suit/proc/process_wound(carbon, wound, bodypart)
	SIGNAL_HANDLER

	var/list/minor_fractures = list(
		/datum/wound/blunt,
		/datum/wound/blunt/moderate
		)
	var/list/major_fractures = list(
		/datum/wound/blunt/severe,
		/datum/wound/blunt/critical,
		/datum/wound/loss
		)
	var/list/minor_lacerations = list(
		/datum/wound/burn,
		/datum/wound/burn/moderate,
		/datum/wound/pierce,
		/datum/wound/pierce/moderate,
		/datum/wound/slash,
		/datum/wound/slash/moderate
		)
	var/list/major_lacerations = list(
		/datum/wound/burn/severe,
		/datum/wound/burn/critical,
		/datum/wound/pierce/severe,
		/datum/wound/pierce/critical,
		/datum/wound/slash/severe,
		/datum/wound/slash/critical
		)

	if(wound in minor_fractures)
		send_hev_sound(minor_fracture_sound)
	else if(wound in major_fractures)
		send_hev_sound(major_fracture_sound)
	else if(wound in minor_lacerations)
		send_hev_sound(minor_lacerations_sound)
	else if(wound in major_lacerations)
		send_hev_sound(major_lacerations_sound)
	else
		var/sound2play = pick(list(
			minor_fracture_sound,
			major_fracture_sound,
			minor_lacerations_sound,
			major_lacerations_sound
		))
		send_hev_sound(sound2play)

/obj/item/clothing/suit/space/hev_suit/proc/process_acid()
	SIGNAL_HANDLER
	if(world.time <= acid_statement_cooldown)
		return
	acid_statement_cooldown = world.time + acid_static_cooldown
	send_hev_sound(chemical_sound)

/obj/item/clothing/suit/space/hev_suit/proc/weaponselect()
	ADD_TRAIT(current_user, list(TRAIT_GUNFLIP,TRAIT_GUN_NATURAL), "hev_trait")
	playsound(src, weaponselect_sound, 50)
	send_message("...ВКЛЮЧЕНА", HEV_COLOR_GREEN)
	send_message("УРОВЕНЬ КОЛИЧЕСТВА БОЕПРИПАСОВ...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(munitions_monitoring)), 4 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/munitions_monitoring()
	//Crickets, not sure what to make this do!
	playsound(src, munitions_sound, 50)
	send_message("...ВКЛЮЧЕН", HEV_COLOR_GREEN)
	send_message("ПЕРЕГОВОРНОЕ УСТРОИСТВО...")
	timer_id = addtimer(CALLBACK(src, PROC_REF(comms_system)), 4 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/comms_system()

	playsound(src, communications_sound, 50)
	send_message("...ВКЛЮЧЕНО", HEV_COLOR_GREEN)
	timer_id = addtimer(CALLBACK(src, PROC_REF(finished)), 4 SECONDS, TIMER_STOPPABLE)

/obj/item/clothing/suit/space/hev_suit/proc/finished()
	to_chat(current_user, span_notice("[src] прочно закрепляется на моём теле!"))
	ADD_TRAIT(src, TRAIT_NODROP, "hev_trait")
	send_message("БЕЗОПАСНОГО ВАМ ДНЯ", HEV_COLOR_GREEN)
	playsound(src, safe_day_sound, 50)
	activated = TRUE
	activating = FALSE

/obj/item/clothing/suit/space/hev_suit/proc/deactivate()
	if(timer_id)
		deltimer(timer_id)
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(src, TRAIT_NODROP, "hev_trait")
	armor = armor.setRating(
		armor_poweroff[1],
		armor_poweroff[2],
		armor_poweroff[3],
		armor_poweroff[4],
		armor_poweroff[5],
		armor_poweroff[6],
		armor_poweroff[7],
		armor_poweroff[8],
		armor_poweroff[9],
		armor_poweroff[10]
		)
	if(current_helmet)
		current_helmet.armor = current_helmet.armor.setRating(
		armor_poweroff[1],
		armor_poweroff[2],
		armor_poweroff[3],
		armor_poweroff[4],
		armor_poweroff[5],
		armor_poweroff[6],
		armor_poweroff[7],
		armor_poweroff[8],
		armor_poweroff[9],
		armor_poweroff[10]
		)
		REMOVE_TRAIT(current_helmet, TRAIT_NODROP, "hev_trait")
	if(current_internals_tank)
		REMOVE_TRAIT(current_internals_tank, TRAIT_NODROP, "hev_trait")
	if(current_user)
		send_message("СИСТЕМА ДЕАКТИВИРОВАНА", HEV_COLOR_RED)
		REMOVE_TRAIT(current_user, list(TRAIT_GUNFLIP,TRAIT_GUN_NATURAL), "hev_trait")
		UnregisterSignal(current_user, list(
			COMSIG_ATOM_ACID_ACT,
			COMSIG_CARBON_GAIN_WOUND,
			COMSIG_MOB_RUN_ARMOR,
			COMSIG_MOB_STATCHANGE
		))
	activated = FALSE
	activating = FALSE

/obj/machinery/suit_storage_unit/hev
	suit_type = /obj/item/clothing/suit/space/hev_suit
	helmet_type = /obj/item/clothing/head/helmet/space/hev_suit
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/tank/internals/oxygen


/obj/item/clothing/head/helmet/space/hev_suit/pcv
	name = "энергетический боевой шлем"
	desc = "Устаревший боевой шлем, разработанный в начале 21 века в Соил-3 третьего класса защиты. Содержит точки крепления для очков ночного видения AN/PVS."
	icon = 'white/valtos/icons/black_mesa/hecucloth.dmi'
	worn_icon = 'white/valtos/icons/black_mesa/hecumob.dmi'
	icon_state = "hecu_helm"
	inhand_icon_state = "sec_helm"
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 20, FIRE = 20, ACID = 20, WOUND = 10)
	flags_inv = HIDEHAIR
	obj_flags = NO_MAT_REDEMPTION
	resistance_flags = FIRE_PROOF|ACID_PROOF|FREEZE_PROOF
	clothing_flags = SNUG_FIT
	clothing_traits = null
	flags_cover = HEADCOVERSEYES | PEPPERPROOF
	flash_protect = null
	visor_flags_inv = null
	visor_flags = null
	slowdown = 0
	unique_reskin = list(
		"Basic" = "hecu_helm",
		"Corpsman" = "hecu_helm_medic",
		"Basic Black" = "hecu_helm_black",
		"Corpsman Black" = "hecu_helm_medic_black",
	)

/obj/item/clothing/suit/space/hev_suit/pcv
	name = "энергетический боевой жилет"
	desc = "Электрический боевой бронижилет, энергия придаёт жёсткость энерговолокну, создавая слой упругой брони в ответ на урон, полученный от кинетической силы. Онащен счетчиком Гейгера, тактической рацией, визором и инъектором боевого коктейля, который позволяет пользователю нормально функционировать даже после серьезной травмы. Концентрация бронепластин в нижней части задней панели от бортового компьютера заставляет шоколадный глаз чувствовать непробиваемым."
	icon = 'white/valtos/icons/black_mesa/hecucloth.dmi'
	worn_icon = 'white/valtos/icons/black_mesa/hecumob.dmi'
	icon_state = "hecu_vest"
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 20, FIRE = 20, ACID = 20, WOUND = 10) //This is muhreens suit, of course it's mildly strong and balanced for PvP.
	flags_inv = null
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	cell = /obj/item/stock_parts/cell/super
	actions_types = list(/datum/action/item_action/hev_toggle, /datum/action/item_action/hev_toggle_notifs)
	resistance_flags = FIRE_PROOF|ACID_PROOF|FREEZE_PROOF
	clothing_flags = SNUG_FIT
	unique_reskin = list(
		"Basic" = "hecu_vest",
		"Corpsman" = "hecu_vest_medic",
		"Basic Black" = "hecu_vest_black",
		"Corpsman Black" = "hecu_vest_medic_black",
	)

	activation_song = 'white/valtos/sounds/black_mesa/pcv/planet.ogg'

	logon_sound = 'white/valtos/sounds/black_mesa/pcv/01_pcv_logon.ogg'
	armor_sound = 'white/valtos/sounds/black_mesa/pcv/02_powerarmor_on.ogg'
	atmospherics_sound = 'white/valtos/sounds/black_mesa/pcv/03_atmospherics_on.ogg'
	vitalsigns_sound = 'white/valtos/sounds/black_mesa/pcv/04_vitalsigns_on.ogg'
	automedic_sound = 'white/valtos/sounds/black_mesa/pcv/05_automedic_on.ogg'
	weaponselect_sound = 'white/valtos/sounds/black_mesa/pcv/06_weaponselect_on.ogg'
	munitions_sound = 'white/valtos/sounds/black_mesa/pcv/07_munitionview_on.ogg'
	communications_sound = 'white/valtos/sounds/black_mesa/pcv/08_communications_on.ogg'
	safe_day_sound = 'white/valtos/sounds/black_mesa/pcv/09_safe_day.ogg'

	batt_50_sound = 'white/valtos/sounds/black_mesa/pcv/power_level_is_fifty.ogg'
	batt_40_sound = 'white/valtos/sounds/black_mesa/pcv/power_level_is_fourty.ogg'
	batt_30_sound = 'white/valtos/sounds/black_mesa/pcv/power_level_is_thirty.ogg'
	batt_20_sound = 'white/valtos/sounds/black_mesa/pcv/power_level_is_twenty.ogg'
	batt_10_sound = 'white/valtos/sounds/black_mesa/pcv/power_level_is_ten.ogg'

	near_death_sound = 'white/valtos/sounds/black_mesa/pcv/near_death.ogg'
	health_critical_sound = 'white/valtos/sounds/black_mesa/pcv/health_critical.ogg'
	health_dropping_sound = 'white/valtos/sounds/black_mesa/pcv/health_dropping2.ogg'

	blood_loss_sound = 'white/valtos/sounds/black_mesa/pcv/blood_loss.ogg'
	blood_toxins_sound = 'white/valtos/sounds/black_mesa/pcv/blood_toxins.ogg'
	biohazard_sound = 'white/valtos/sounds/black_mesa/pcv/biohazard_detected.ogg'
	chemical_sound = 'white/valtos/sounds/black_mesa/pcv/chemical_detected.ogg'

	minor_fracture_sound = 'white/valtos/sounds/black_mesa/pcv/minor_fracture.ogg'
	major_fracture_sound = 'white/valtos/sounds/black_mesa/pcv/major_fracture.ogg'
	minor_lacerations_sound = 'white/valtos/sounds/black_mesa/pcv/minor_lacerations.ogg'
	major_lacerations_sound = 'white/valtos/sounds/black_mesa/pcv/major_lacerations.ogg'

	morphine_sound = 'white/valtos/sounds/black_mesa/pcv/morphine_shot.ogg'
	wound_sound = 'white/valtos/sounds/black_mesa/pcv/wound_sterilized.ogg'
	antitoxin_sound = 'white/valtos/sounds/black_mesa/pcv/antitoxin_shot.ogg'
	antidote_sound = 'white/valtos/sounds/black_mesa/pcv/antidote_shot.ogg'

	armor_poweroff = PCV_ARMOR_POWEROFF
	armor_poweron = PCV_ARMOR_POWERON
	heal_amount = PCV_HEAL_AMOUNT
	blood_replenishment = PCV_BLOOD_REPLENISHMENT
	health_static_cooldown = PCV_COOLDOWN_HEAL
	rads_static_cooldown = PCV_COOLDOWN_RADS
	acid_static_cooldown = PCV_COOLDOWN_ACID
	suit_name = "PCV MARK II"

/obj/item/clothing/suit/space/hev_suit/pcv/AltClick(mob/living/user)
	reskin_obj(user)
	. = ..()

#undef HEV_COLOR_GREEN
#undef HEV_COLOR_RED
#undef HEV_COLOR_BLUE
#undef HEV_COLOR_ORANGE
#undef HEV_ARMOR_POWERON_BONUS
#undef HEV_DAMAGE_POWER_USE_THRESHOLD
#undef HEV_ARMOR_POWEROFF
#undef PCV_ARMOR_POWEROFF
#undef HEV_ARMOR_POWERON
#undef PCV_ARMOR_POWERON
#undef HEV_POWERUSE_AIRTANK
#undef HEV_POWERUSE_HIT
#undef HEV_POWERUSE_HEAL
#undef HEV_COOLDOWN_HEAL
#undef HEV_COOLDOWN_RADS
#undef HEV_COOLDOWN_ACID
#undef HEV_HEAL_AMOUNT
#undef PCV_HEAL_AMOUNT
#undef HEV_BLOOD_REPLENISHMENT
#undef HEV_NOTIFICATION_TEXT_AND_VOICE
#undef HEV_NOTIFICATION_TEXT
#undef HEV_NOTIFICATION_VOICE
#undef HEV_NOTIFICATION_OFF
#undef HEV_NOTIFICATIONS