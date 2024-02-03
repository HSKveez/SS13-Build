/// how many things can we knock off a table at once by diving into it?
#define MAX_TABLE_MESSES 12

/**
 * For when you want to throw a person at something and have fun stuff happen
 *
 * This component is made for carbon mobs (really, humans), and allows its parent to throw themselves and perform tackles. This is done by enabling throw mode, then clicking on your
 *   intended target with an empty hand. You will then launch toward your target. If you hit a carbon, you'll roll to see how hard you hit them. If you hit a solid non-mob, you'll
 *   roll to see how badly you just messed yourself up. If, along your journey, you hit a table, you'll slam onto it and send up to MAX_TABLE_MESSES (8) /obj/items on the table flying,
 *   and take a bit of extra damage and stun for each thing launched.
 *
 * There are 2 separate """skill rolls""" involved here, which are handled and explained in [rollTackle()][/datum/component/tackler/proc/rollTackle] (for roll 1, carbons), and [splat()][/datum/component/tackler/proc/splat] (for roll 2, walls and solid objects)
*/
/datum/component/tackler
	dupe_mode = COMPONENT_DUPE_UNIQUE

	///If we're currently tackling or are on cooldown. Actually, shit, if I use this to handle cooldowns, then getting thrown by something while on cooldown will count as a tackle..... whatever, i'll fix that next commit
	var/tackling = TRUE
	///How much stamina it takes to launch a tackle
	var/stamina_cost
	///Launching a tackle calls Knockdown on you for this long, so this is your cooldown. Once you stand back up, you can tackle again.
	var/base_knockdown
	///Your max range for how far you can tackle.
	var/range
	///How fast you sail through the air. Standard tackles are 1 speed, but gloves that throw you faster come at a cost: higher speeds make it more likely you'll be badly injured if you fly into a non-mob obstacle.
	var/speed
	///A flat modifier to your roll against your target, as described in [rollTackle()][/datum/component/tackler/proc/rollTackle]. Slightly misleading, skills aren't relevant here, this is a matter of what type of gloves (or whatever) is granting you the ability to tackle.
	var/skill_mod
	///Some gloves, generally ones that increase mobility, may have a minimum distance to fly. Rocket gloves are especially dangerous with this, be sure you'll hit your target or have a clear background if you miss, or else!
	var/min_distance
	///The throwdatum we're currently dealing with, if we need it
	var/datum/thrownthing/tackle

/datum/component/tackler/Initialize(stamina_cost = 25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 0, min_distance = min_distance)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.base_knockdown = base_knockdown
	src.range = range
	src.speed = speed
	src.skill_mod = skill_mod
	src.min_distance = min_distance

	var/mob/P = parent
	to_chat(P, span_notice("Теперь я могу совершать прыжок перехвата! Для того чтобы сделать это, я должен активировать намерение броска и нажать на свою цель пустой рукой."))

	addtimer(CALLBACK(src, PROC_REF(resetTackle)), base_knockdown, TIMER_STOPPABLE)

/datum/component/tackler/Destroy()
	var/mob/P = parent
	to_chat(P, span_notice("Я больше не умею прыгать."))
	return ..()

/datum/component/tackler/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(checkTackle))
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(sack))
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, PROC_REF(registerTackle))

/datum/component/tackler/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW))

///Store the thrownthing datum for later use
/datum/component/tackler/proc/registerTackle(mob/living/carbon/user, datum/thrownthing/TT)
	SIGNAL_HANDLER

	tackle = TT
	tackle.thrower = user

///See if we can tackle or not. If we can, leap!
/datum/component/tackler/proc/checkTackle(mob/living/carbon/user, atom/A, params)
	SIGNAL_HANDLER

	if(!user.throw_mode || user.get_active_held_item() || user.pulling || user.buckled || user.incapacitated())
		return

	if(!A || !(isturf(A) || isturf(A.loc)))
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		if(prob(50))
			to_chat(user, span_warning("ПРЫГАТЬ! НАДА ПРЫГАТЬ! ЫААА! А КАК ПРЫГАТЬ? ВСПОМИНАТЬ!"))
			return

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("Невозможно прыгнуть с связанными руками!"))
		return

	if(user.body_position == LYING_DOWN)
		to_chat(user, span_warning("Прыгать можно только из положения стоя!"))
		return

	if(tackling)
		to_chat(user, span_warning("Я еще не готов!"))
		return

	if(user.has_movespeed_modifier(/datum/movespeed_modifier/shove)) // can't tackle if you just got shoved
		to_chat(user, span_warning("Я слишком выведен из равновесия, чтобы справиться с этим!"))
		return

	user.face_atom(A)

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, MIDDLE_CLICK))
		return

	tackling = TRUE
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(checkObstacle))
	playsound(user, 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)

	if(isfelinid(user)) //If cat, "pounce" instead of "leap".
		playsound(user, 'white/valtos/sounds/kis.ogg', 80, TRUE)
	if(HAS_TRAIT(user, TRAIT_HULK))
		playsound(user, 'white/Feline/sounds/hulk.ogg', 80, TRUE)

	if(can_see(user, A, 7))
		user.visible_message(span_warning("[user] прыгает на [A]!"), span_danger("Прыгаю на [A]!"))
	else
		user.visible_message(span_warning("[user] прыгает!"), span_danger("Прыгаю!"))

	if(get_dist(user, A) < min_distance)
		A = get_ranged_target_turf(user, get_dir(user, A), min_distance) //TODO: this only works in cardinals/diagonals, make it work with in-betweens too!

	user.Knockdown(base_knockdown, ignore_canstun = TRUE)
	user.adjustStaminaLoss(stamina_cost)
	user.throw_at(A, range, speed, user, FALSE)
	addtimer(CALLBACK(src, PROC_REF(resetTackle)), base_knockdown, TIMER_STOPPABLE)
	return(COMSIG_MOB_CANCEL_CLICKON)

/**
 * sack() is called when you actually smack into something, assuming we're mid-tackle. First it deals with smacking into non-carbons, in two cases:
 * * If it's a non-carbon mob, we don't care, get out of here and do normal thrown-into-mob stuff
 * * Else, if it's something dense (walls, machinery, structures, most things other than the floor), go to [/datum/component/tackler/proc/splat] and get ready for some high grade shit
 *
 * If it's a carbon we hit, we'll call rollTackle() which rolls a die and calculates modifiers for both the tackler and target, then gives us a number. Negatives favor the target, while positives favor the tackler.
 * Check [rollTackle()][/datum/component/tackler/proc/rollTackle] for a more thorough explanation on the modifiers at play.
 *
 * Then, we figure out what effect we want, and we get to work! Note that with standard gripper gloves and no modifiers, the range of rolls is (-3, 3). The results are as follows, based on what we rolled:
 * * -inf to -5: Seriously botched tackle, tackler suffers a concussion, brute damage, and a 3 second paralyze, target suffers nothing
 * * -4 to -2: weak tackle, tackler gets 3 second knockdown, target gets shove slowdown but is otherwise fine
 * * -1 to 0: decent tackle, tackler gets up a bit quicker than the target
 * * 1: solid tackle, tackler has more of an advantage getting up quicker
 * * 2 to 4: expert tackle, tackler has sizeable advantage and lands on their feet with a free passive grab
 * * 5 to inf: MONSTER tackle, tackler gets up immediately and gets a free aggressive grab, target takes sizeable stamina damage from the hit and is paralyzed for one and a half seconds and knocked down for three seconds
 *
 * Finally, we return a bitflag to [COMSIG_MOVABLE_IMPACT] that forces the hitpush to false so that we don't knock them away.
*/
/datum/component/tackler/proc/sack(mob/living/carbon/user, atom/hit)
	SIGNAL_HANDLER

	if(!tackling || !tackle)
		return

	user.toggle_throw_mode()
	if(!iscarbon(hit))
		if(hit.density)
			INVOKE_ASYNC(src, PROC_REF(splat), user, hit)
		return

	var/mob/living/carbon/target = hit
	var/mob/living/carbon/human/T = target
	var/mob/living/carbon/human/S = user
	if(isfelinid(user)) //If cat, "pounce" instead of "tackle".
		playsound(user, 'white/valtos/sounds/kis.ogg', 80, TRUE)
	if(HAS_TRAIT(user, TRAIT_HULK))
		playsound(user, 'white/Feline/sounds/hulk.ogg', 80, TRUE)
	var/roll = rollTackle(target)
	tackling = FALSE
	tackle.gentle = TRUE

	switch(roll)
		if(-INFINITY to -5)
			user.visible_message(span_danger("[user] неуклюже прыгает на [target], ударяясь головами друг об друга!"), span_userdanger("Неуклюже прыгаю на [target], но наши головы сталкиваются при падении!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] неуклюже прыгает на меня, ударяясь своей головой об мою!"))

			user.Paralyze(5)
			target.Paralyze(5)
			var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=15, updating_health=TRUE, wound_bonus = CANT_WOUND)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)

		if(-4 to -2) // glancing blow at best
			user.visible_message(span_warning("[user] прыгает на [target], после чего они падают!"), span_userdanger("Прыгаю на [target], сбивая цель с ног, но так же падаю при этом!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] прыгает на меня и сбивает с ног!"))

			user.Knockdown(30)
			target.Knockdown(30)
			if(ishuman(target) && !T.has_movespeed_modifier(/datum/movespeed_modifier/shove))
				T.add_movespeed_modifier(/datum/movespeed_modifier/shove) // maybe define a slightly more severe/longer slowdown for this
				addtimer(CALLBACK(T, /mob/living/carbon/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH * 2)

		if(-1 to 0) // decent hit, both parties are about equally inconvenienced
			user.visible_message(span_warning("[user] прыгает на [target], после чего они валятся на пол в клинче!"), span_userdanger("Прыгаю на [target], сбивая цель с ног и удерживая ее!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] прыгает на меня, сбивая с ног и прижимая к земле!"))

			target.adjustStaminaLoss(stamina_cost)
			target.Paralyze(5)
			user.Knockdown(20)
			target.Knockdown(25)

		if(1 to 2) // solid hit, tackler has a slight advantage
			user.visible_message(span_warning("[user] прыгает [target], после чего пытается скрутить цель!"), span_userdanger("Прыгаю на [target], сбивая цель с ног и пытаюсь скрутить!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] прыгает на меня и пытается скрутить цель!"))

			target.adjustStaminaLoss(30)
			target.Paralyze(5)
			user.Knockdown(10)
			target.Knockdown(20)

		if(3 to 4) // really good hit, the target is definitely worse off here. Without positive modifiers, this is as good a tackle as you can land
			user.visible_message(span_warning("[user] прыгает на [target], сбивая цель с ног и заламывая ей руку!"), span_userdanger("Прыгаю на [target], сбивая цель с ног и заламываю ей руку!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] прыгает на меня и заламывает мне руку!"))

			user.SetKnockdown(0)
			user.get_up(TRUE)
			user.forceMove(get_turf(target))
			target.adjustStaminaLoss(40)
			target.Paralyze(6)
			target.Knockdown(30)
			if(ishuman(target) && ishuman(user))
				INVOKE_ASYNC(S.dna.species, TYPE_PROC_REF(/datum/species, grab), S, T)
				S.setGrabState(GRAB_PASSIVE)

		if(5 to INFINITY) // absolutely BODIED
			user.visible_message(span_warning("[user] прыгает на [target], сбив цель с ног и жестко берет на болевой захват!"), span_userdanger("Прыгаю на [target], сбивая цель с ног и беру ее на болевой захват!"), ignored_mobs = target)
			to_chat(target, span_userdanger("[user] прыгает на меня и берет на болевой захват!"))

			user.SetKnockdown(0)
			user.get_up(TRUE)
			user.forceMove(get_turf(target))
			target.adjustStaminaLoss(80)
			target.Paralyze(10)
			target.Knockdown(50)
			if(ishuman(target) && ishuman(user))
				INVOKE_ASYNC(S.dna.species, TYPE_PROC_REF(/datum/species, grab), S, T)
				S.setGrabState(GRAB_AGGRESSIVE)


	return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH

/**
 * This handles all of the modifiers for the actual carbon-on-carbon tackling, and gets its own proc because of how many there are (with plenty more in mind!)
 *
 * The base roll is between (-3, 3), with negative numbers favoring the target, and positive numbers favoring the tackler. The target and the tackler are both assessed for
 * how easy they are to knock over, with clumsiness and dwarfiness being strong maluses for each, and gigantism giving a bonus for each. These numbers and ideas
 * are absolutely subject to change.

 * In addition, after subtracting the defender's mod and adding the attacker's mod to the roll, the component's base (skill) mod is added as well. Some sources of tackles
 * are better at taking people down, like the bruiser and rocket gloves, while the dolphin gloves have a malus in exchange for better mobility.
*/
/datum/component/tackler/proc/rollTackle(mob/living/carbon/target)
	var/defense_mod = 0
	var/attack_mod = 0

	// DE-FENSE
	if(target.drunkenness > 60) // drunks are easier to knock off balance
		defense_mod -= 3
	else if(target.drunkenness > 30)
		defense_mod -= 1
	if(HAS_TRAIT(target, TRAIT_CLUMSY))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_FAT)) // chonkers are harder to knock over
		defense_mod += 1
	if(HAS_TRAIT(target, TRAIT_GRABWEAKNESS))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_DWARF))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_GIANT))
		defense_mod += 2
	if(target.get_organic_health() < 50)
		defense_mod -= 1

	var/leg_wounds = 0 // -1 defense per 2 leg wounds
	for(var/i in target.all_wounds)
		var/datum/wound/iterwound = i
		if((iterwound.limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
			leg_wounds++
	defense_mod -= round(leg_wounds * 0.5)

	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		var/suit_slot = T.get_item_by_slot(ITEM_SLOT_OCLOTHING)

		if(isnull(T.wear_suit) && isnull(T.w_uniform)) // who honestly puts all of their effort into tackling a naked guy?
			defense_mod += 2
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/space/hardsuit)))
			defense_mod += 1
		if(T.is_shove_knockdown_blocked()) // riot armor and such
			defense_mod += 5
		if(T.is_holding_item_of_type(/obj/item/shield))
			defense_mod += 2
		if(T.get_organ_slot(ORGAN_SLOT_TAIL))
			defense_mod += 2

	// OF-FENSE
	var/mob/living/carbon/sacker = parent

	if(sacker.drunkenness > 60) // you're far too drunk to hold back!
		attack_mod += 1
	else if(sacker.drunkenness > 30) // if you're only a bit drunk though, you're just sloppy
		attack_mod -= 1
	if(HAS_TRAIT(sacker, TRAIT_CLUMSY))
		attack_mod -= 2
	if(HAS_TRAIT(sacker, TRAIT_DWARF))
		attack_mod -= 2
	if(HAS_TRAIT(sacker, TRAIT_GIANT))
		attack_mod += 2
	if(sacker.get_organ_slot(ORGAN_SLOT_TAIL))
		attack_mod += 2
	if(HAS_TRAIT(sacker, TRAIT_HULK))
		attack_mod += 2

	if(ishuman(target))
		var/mob/living/carbon/human/S = sacker

		var/suit_slot = S.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor)))
			attack_mod += 2
		if(suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor/riot)))
			attack_mod += 3

	var/r = rand(-3, 3) - defense_mod + attack_mod + skill_mod
	return r


/**
 * This is where we handle diving into dense atoms, generally with effects ranging from bad to REALLY bad. This works as a percentile roll that is modified in two steps as detailed below. The higher
 * the roll, the more severe the result.
 *
 * Mod 1: Speed-
 * * Base tackle speed is 1, which is what normal gripper gloves use. For other sources with higher speed tackles, like dolphin and ESPECIALLY rocket gloves, we obey Newton's laws and hit things harder.
 * * For every unit of speed above 1, move the lower bound of the roll up by 15. Unlike Mod 2, this only serves to raise the lower bound, so it can't be directly counteracted by anything you can control.
 *
 * Mod 2: Misc-
 * -Flat modifiers, these take whatever you rolled and add/subtract to it, with the end result capped between the minimum from Mod 1 and 100. Note that since we can't roll higher than 100 to start with,
 * wearing a helmet should be enough to remove any chance of permanently paralyzing yourself and dramatically lessen knocking yourself unconscious, even with rocket gloves. Will expand on maybe
 * * Wearing a helmet: -6
 * * Wearing riot armor: -6
 * * Clumsy: +6
 *
 * Effects: Below are the outcomes based off your roll, in order of increasing severity
 *
 * * 1-67: Knocked down for a few seconds and a bit of brute and stamina damage
 * * 68-85: Knocked silly, gain some confusion as well as the above
 * * 86-92: Cranial trauma, get a concussion and more confusion, plus more damage
 * * 93-96: Knocked unconscious, get a random mild brain trauma, as well as a fair amount of damage
 * * 97-98: Massive head damage, probably crack your skull open, random mild brain trauma
 * * 99-Infinity: Break your spinal cord, get paralyzed, take a bunch of damage too. Very unlucky!
*/
/datum/component/tackler/proc/splat(mob/living/carbon/user, atom/hit)
	if(istype(hit, /obj/machinery/vending)) // before we do anything else-
		var/obj/machinery/vending/darth_vendor = hit
		darth_vendor.tilt(user, TRUE)
		return
	else if(istype(hit, /obj/structure/window))
		var/obj/structure/window/W = hit
		splatWindow(user, W)
		if(QDELETED(W))
			return COMPONENT_MOVABLE_IMPACT_NEVERMIND
		return

	var/oopsie_mod = 0
	var/danger_zone = (speed - 1) * 13 // for every extra speed we have over 1, take away 13 of the safest chance
	danger_zone = max(min(danger_zone, 100), 1)

	if(ishuman(user))
		var/mob/living/carbon/human/S = user
		var/head_slot = S.get_item_by_slot(ITEM_SLOT_HEAD)
		var/suit_slot = S.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(isfelinid(user))
			user.visible_message(span_danger("[user] элегантно отпрыгивает от [hit]!"), span_userdanger("Успеваю сгруппироваться и оттолкнуться от [hit]!"))
			user.adjustStaminaLoss(10, updating_health=FALSE)
			return
		if(HAS_TRAIT(user, TRAIT_HULK))
			user.visible_message(span_danger("[user] как метеорит влетает в [hit]!"), span_userdanger("СТЕЕЕНААААА!"))
			playsound(user, 'sound/weapons/punch4.ogg', 70, TRUE)
			user.Knockdown(10)
			user.adjustBruteLoss(5)
			return
		if(head_slot && (istype(head_slot,/obj/item/clothing/head/helmet/riot)) || (suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor/riot))))
			user.visible_message(span_danger("[user] влетает в [hit]!"), span_userdanger("Врезаюсь в [hit]! Хорошо что на мне защита, могло быть и хуже!"))
			user.adjustStaminaLoss(10, updating_health=FALSE)
			user.adjustBruteLoss(5)
			user.Knockdown(10)
			shake_camera(user, 1, 1)
			playsound(user, 'sound/weapons/punch1.ogg', 70, TRUE)
			return
		if((suit_slot && (istype(suit_slot,/obj/item/clothing/suit/armor))) || (head_slot && istype(head_slot,/obj/item/clothing/head/helmet)))
			if(prob(80))
				user.visible_message(span_danger("[user] влетает в [hit]!"), span_userdanger("Врезаюсь в [hit]! Хорошо что на мне защита, могло быть и хуже!"))
				user.adjustStaminaLoss(10, updating_health=FALSE)
				user.adjustBruteLoss(5)
				user.Knockdown(10)
				shake_camera(user, 1, 1)
				playsound(user, 'sound/weapons/punch2.ogg', 70, TRUE)
				return
			else
				oopsie_mod -= 20

		if(head_slot && istype(head_slot,/obj/item/clothing/head/hardhat))
			if(prob(60))
				user.visible_message(span_danger("[user] влетает в [hit]!"), span_userdanger("Врезаюсь в [hit]! Хорошо что на мне защита, могло быть и хуже!"))
				user.adjustStaminaLoss(10, updating_health=FALSE)
				user.adjustBruteLoss(5)
				user.Knockdown(10)
				shake_camera(user, 1, 1)
				playsound(user, 'sound/weapons/punch3.ogg', 70, TRUE)
				return
			else
				oopsie_mod -= -10
	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		oopsie_mod += 6 //honk!

	var/oopsie = rand(danger_zone, 100)
	if(oopsie >= 94 && oopsie_mod < 0) // good job avoiding getting paralyzed! gold star!
		to_chat(user, span_notice("Удалось смягчить удар!"))
	oopsie += oopsie_mod
	if(oopsie <= 0)
		oopsie = 1
	switch(oopsie)
		if(99 to INFINITY)
			// can you imagine standing around minding your own business when all of the sudden some guy fucking launches himself into a wall at full speed and irreparably paralyzes himself?
			user.visible_message(span_danger("[user] slams face-first into [hit] at an awkward angle, severing [user.p_their()] spinal column with a sickening crack! Fucking shit!"), span_userdanger("You slam face-first into [hit] at an awkward angle, severing your spinal column with a sickening crack! Fucking shit!"))
			var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=40, updating_health=FALSE, wound_bonus = 40)
			else
				user.adjustBruteLoss(40, updating_health=FALSE)
			user.adjustStaminaLoss(30)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			playsound(user, 'sound/effects/wounds/crack2.ogg', 70, TRUE)
			user.emote("agony")
			user.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic) // oopsie indeed!
			shake_camera(user, 7, 7)
			user.flash_act(1, TRUE, TRUE, length = 4.5)

		if(97 to 98)
			user.visible_message(span_danger("[user] slams skull-first into [hit] with a sound like crumpled paper, revealing a horrifying breakage in [user.p_their()] cranium! Holy shit!"), span_userdanger("You slam skull-first into [hit] and your senses are filled with warm goo flooding across your face! Your skull is open!"))
			var/obj/item/bodypart/head/hed = user.get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=30, updating_health=FALSE, wound_bonus = 25)
			else
				user.adjustBruteLoss(40, updating_health=FALSE)
			user.adjustStaminaLoss(30)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			user.emote("gurgle")
			shake_camera(user, 7, 7)
			user.flash_act(1, TRUE, TRUE, length = 4.5)

		if(93 to 96)
			user.visible_message(span_danger("[user] slams face-first into [hit] with a concerning squish, immediately going limp!"), span_userdanger("You slam face-first into [hit], and immediately lose consciousness!"))
			user.adjustStaminaLoss(30)
			user.adjustBruteLoss(30)
			user.Unconscious(100)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8)
			shake_camera(user, 6, 6)
			user.flash_act(1, TRUE, TRUE, length = 3.5)

		if(86 to 92)
			user.visible_message(span_danger("[user] slams head-first into [hit], suffering major cranial trauma!"), span_userdanger("You slam head-first into [hit], and the world explodes around you!"))
			user.adjustStaminaLoss(30, updating_health=FALSE)
			user.adjustBruteLoss(30)
			user.add_confusion(15)
			if(prob(80))
				user.gain_trauma(/datum/brain_trauma/mild/concussion)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8)
			user.Knockdown(40)
			shake_camera(user, 5, 5)
			user.flash_act(1, TRUE, TRUE, length = 2.5)

		if(68 to 85)
			user.visible_message(span_danger("[user] slams hard into [hit], knocking [user.p_them()] senseless!"), span_userdanger("You slam hard into [hit], knocking yourself senseless!"))
			user.adjustStaminaLoss(30, updating_health=FALSE)
			user.adjustBruteLoss(10)
			user.add_confusion(10)
			user.Knockdown(30)
			shake_camera(user, 3, 4)

		if(1 to 67)
			user.visible_message(span_danger("[user] slams into [hit]!"), span_userdanger("You slam into [hit]!"))
			user.adjustStaminaLoss(20, updating_health=FALSE)
			user.adjustBruteLoss(10)
			user.Knockdown(20)
			shake_camera(user, 2, 2)

	playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)


/datum/component/tackler/proc/resetTackle()
	tackling = FALSE
	QDEL_NULL(tackle)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

///A special case for splatting for handling windows
/datum/component/tackler/proc/splatWindow(mob/living/carbon/user, obj/structure/window/W)
	playsound(user, 'sound/effects/Glasshit.ogg', 140, TRUE)

	if(W.type in list(/obj/structure/window, /obj/structure/window/fulltile, /obj/structure/window/unanchored, /obj/structure/window/fulltile/unanchored)) // boring unreinforced windows
		for(var/i = 0, i < speed, i++)
			var/obj/item/shard/shard = new /obj/item/shard(get_turf(user))
			shard.embedding = list(embed_chance = 100, ignore_throwspeed_threshold = TRUE, impact_pain_mult=3, pain_chance=5)
			shard.updateEmbedding()
			user.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
			shard.embedding = null
			shard.updateEmbedding()
		W.obj_destruction()
		user.adjustStaminaLoss(10 * speed)
		user.Paralyze(30)
		user.visible_message(span_danger("[user] smacks into [W] and shatters it, shredding [user.p_them()]self with glass!"), span_userdanger("You smacks into [W] and shatter it, shredding yourself with glass!"))

	else
		user.visible_message(span_danger("[user] smacks into [W] like a bug!"), span_userdanger("You smacks into [W] like a bug!"))
		user.Paralyze(10)
		user.Knockdown(30)
		W.take_damage(30 * speed)
		user.adjustStaminaLoss(10 * speed, updating_health=FALSE)
		user.adjustBruteLoss(5 * speed)

/datum/component/tackler/proc/delayedSmash(obj/structure/window/W)
	if(W)
		W.obj_destruction()
		playsound(W, "shatter", 70, TRUE)

///Check to see if we hit a table, and if so, make a big mess!
/datum/component/tackler/proc/checkObstacle(mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(!tackling)
		return

	var/turf/T = get_turf(owner)
	var/obj/structure/table/kevved = locate(/obj/structure/table) in T.contents
	if(!kevved)
		return

	var/list/messes = list()

	// we split the mess-making into two parts (check what we're gonna send flying, intermission for dealing with the tackler, then actually send stuff flying) for the benefit of making sure the face-slam text
	// comes before the list of stuff that goes flying, but can still adjust text + damage to how much of a mess it made
	for(var/obj/item/I in T.contents)
		if(!I.anchored)
			messes += I
			if(messes.len >= MAX_TABLE_MESSES)
				break

	// for telling HOW big of a mess we just made
	var/HOW_big_of_a_miss_did_we_just_make = ""
	if(messes.len)
		if(messes.len < MAX_TABLE_MESSES / 4)
			HOW_big_of_a_miss_did_we_just_make = ", making a mess"
		else if(messes.len < MAX_TABLE_MESSES / 2)
			HOW_big_of_a_miss_did_we_just_make = ", making a big mess"
		else if(messes.len < MAX_TABLE_MESSES)
			HOW_big_of_a_miss_did_we_just_make = ", making a giant mess"
		else
			HOW_big_of_a_miss_did_we_just_make = ", making a ginormous mess!" // an extra exclamation point!! for emphasis!!!

	owner.visible_message(span_danger("[owner] trips over [kevved] and slams into it face-first[HOW_big_of_a_miss_did_we_just_make]!"), span_userdanger("You trip over [kevved] and slam into it face-first[HOW_big_of_a_miss_did_we_just_make]!"))
	owner.adjustStaminaLoss(15 + messes.len * 2, FALSE)
	owner.adjustBruteLoss(8 + messes.len)
	owner.Paralyze(0.4 SECONDS * messes.len) // .4 seconds of paralyze for each thing you knock around
	owner.Knockdown(2 SECONDS + 0.4 SECONDS * messes.len) // 2 seconds of knockdown after the paralyze

	for(var/obj/item/I in messes)
		var/dist = rand(1, 3)
		var/sp = 2
		if(prob(25 * (src.speed - 1))) // if our tackle speed is higher than 1, with chance (speed - 1 * 25%), throw the thing at our tackle speed + 1
			sp = speed + 1
		I.throw_at(get_ranged_target_turf(I, pick(GLOB.alldirs), range = dist), range = dist, speed = sp)
		I.visible_message(span_danger("[I] goes flying[sp > 3 ? " dangerously fast" : ""]!")) // standard embed speed

	playsound(owner, 'sound/weapons/smash.ogg', 70, TRUE)
	tackle.finalize(hit=TRUE)
	resetTackle()

#undef MAX_TABLE_MESSES