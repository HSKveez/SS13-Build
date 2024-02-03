/datum/species/dullahan
	name = "дюллахан"
	id = "dullahan"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER,TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_CAN_STRIP,TRAIT_NOHYDRATION)
	mutant_bodyparts = list("tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = TRUE
	mutantbrain = /obj/item/organ/brain/dullahan
	mutanteyes = /obj/item/organ/eyes/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

	var/obj/item/dullahan_relay/my_head

	/// Did our owner's first client connection get handled yet? Useful for when some proc needs to be called once we're sure that a client has moved into our owner, like for Dullahans.
	var/owner_first_client_connection_handled = FALSE

/datum/species/dullahan/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/human, datum/species/old_species)
	. = ..()
	human.lose_hearing_sensitivity(TRAIT_GENERIC)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)

	if(head)
		head.drop_limb()

		if(!QDELETED(head)) //drop_limb() deletes the limb if no drop location exists and character setup dummies are located in nullspace.
			head.throwforce = 25
			my_head = new /obj/item/dullahan_relay(head, human)
			human.put_in_hands(head)
			head.speech_span = null // so we don't look roboty when talking through it

			// We want to give the head some boring old eyes just so it doesn't look too jank on the head sprite.
			head.eyes = new /obj/item/organ/eyes(head)
			head.eyes.eye_color_left = human.eye_color_left
			head.eyes.eye_color_right = human.eye_color_right
			human.update_body()
			head.update_icon_dropped()

	human.set_safe_hunger_level()

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/human)
	. = ..()

	if(my_head)
		var/obj/item/bodypart/head/detached_head = my_head.loc
		my_head.owner = null
		QDEL_NULL(my_head)
		if(detached_head)
			qdel(detached_head)

	human.regenerate_limb(BODY_ZONE_HEAD, FALSE)
	human.become_hearing_sensitive()
	prevent_perspective_change = FALSE
	human.reset_perspective(human)

/datum/species/dullahan/spec_life(mob/living/carbon/human/human, seconds_per_tick, times_fired)
	. = ..()
	if(QDELETED(my_head))
		my_head = null
		human.investigate_log("has been gibbed by the loss of [human.p_their()] head.", INVESTIGATE_DEATHS)
		human.gib()
		return

	if(my_head.loc.name != human.real_name && istype(my_head.loc, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/detached_head = my_head.loc
		detached_head.real_name = human.real_name
		detached_head.name = human.real_name
		detached_head.brain.name = "мозг [human.name]"

	var/obj/item/bodypart/head/illegal_head = human.get_bodypart(BODY_ZONE_HEAD)
	if(illegal_head)
		my_head = null
		human.investigate_log("has been gibbed by having an illegal head put on [human.p_their()] shoulders.", INVESTIGATE_DEATHS)
		human.gib() // Yeah so giving them a head on their body is really not a good idea, so their original head will remain but uh, good luck fixing it after that.

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/human)
	var/obj/item/organ/eyes/eyes = human.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		human.update_tint()
		if(eyes.tint)
			prevent_perspective_change = FALSE
			human.reset_perspective(human, TRUE)
		else
			human.reset_perspective(my_head, TRUE)
			prevent_perspective_change = TRUE

/datum/species/dullahan/on_owner_login(mob/living/carbon/human/owner)
	var/obj/item/organ/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(owner_first_client_connection_handled)
		if(!eyes.tint)
			owner.reset_perspective(my_head, TRUE)
			prevent_perspective_change = TRUE
		return

	// As it's the first time there's a client in our mob, we can finally update its vision to place it in the head instead!
	var/datum/action/item_action/organ_action/dullahan/eyes_toggle_perspective_action = locate() in eyes?.actions

	eyes_toggle_perspective_action?.Trigger()
	owner_first_client_connection_handled = TRUE

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/dullahan
	zone = "abstract"
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(isdullahan(H))
			var/datum/species/dullahan/D = H.dna.species
			if(isobj(D.my_head.loc))
				var/obj/O = D.my_head.loc
				O.say(speech_args[SPEECH_MESSAGE])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = "abstract"

/obj/item/organ/eyes/dullahan
	name = "видимость головы"
	desc = "Абстракция."
	actions_types = list(/datum/action/item_action/organ_action/dullahan)
	zone = "abstract"
	tint = INFINITY // to switch the vision perspective to the head on species_gain() without issue.

/datum/action/item_action/organ_action/dullahan
	name = "Переключить перспективу"
	desc = "Переключиться между зрением головы, или слепым тела."

/datum/action/item_action/organ_action/dullahan/Trigger(trigger_flags)
	. = ..()
	var/obj/item/organ/eyes/dullahan/dullahan_eyes = target
	dullahan_eyes.tint = dullahan_eyes.tint ? NONE : INFINITY

	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			dullahan_species.update_vision_perspective(human)

/obj/item/dullahan_relay
	name = "реле Дюллахана"
	/// The mob (a dullahan) that owns this relay.
	var/mob/living/owner

/obj/item/dullahan_relay/Initialize(mapload, mob/living/carbon/human/new_owner)
	. = ..()
	if(!new_owner)
		return INITIALIZE_HINT_QDEL
	owner = new_owner
	START_PROCESSING(SSobj, src)
	RegisterSignal(owner, COMSIG_CLICK_SHIFT, PROC_REF(examinate_check))
	RegisterSignal(owner, COMSIG_LIVING_REGENERATE_LIMBS, PROC_REF(unlist_head))
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(retrieve_head))
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/dullahan_relay/Destroy()
	lose_hearing_sensitivity(ROUNDSTART_TRAIT)
	owner = null
	return ..()

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head) || QDELETED(owner))
		. = PROCESS_KILL
		qdel(src)

/obj/item/dullahan_relay/proc/examinate_check(mob/user, atom/source)
	SIGNAL_HANDLER
	if(user.client.eye == src)
		return COMPONENT_ALLOW_EXAMINATE

/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(owner)
		owner.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mods, message_range)

///Adds the owner to the list of hearers in hearers_in_view(), for visible/hearable on top of say messages
/obj/item/dullahan_relay/proc/include_owner(datum/source, list/hearers)
	SIGNAL_HANDLER
	if(!QDELETED(owner))
		hearers += owner

///Stops dullahans from gibbing when regenerating limbs
/obj/item/dullahan_relay/proc/unlist_head(datum/source, noheal = FALSE, list/excluded_zones)
	SIGNAL_HANDLER
	excluded_zones |= BODY_ZONE_HEAD

///Retrieving the owner's head for better ahealing.
/obj/item/dullahan_relay/proc/retrieve_head(datum/source, full_heal_flags)
	SIGNAL_HANDLER

	var/obj/item/bodypart/head/head = loc
	var/turf/body_turf = get_turf(owner)
	if(head && istype(head) && body_turf && !(head in owner.get_all_contents()))
		head.forceMove(body_turf)

/obj/item/dullahan_relay/Destroy()
	if(!QDELETED(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			dullahan_species.my_head = null
			owner.gib()
	owner = null
	return ..()