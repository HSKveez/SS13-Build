
/obj/item/food/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	max_volume = 80
	tastes = list("хлеб" = 10)
	foodtypes = GRAIN
	eat_time = 3 SECONDS

/obj/item/food/bread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)
	AddComponent(/datum/component/food_storage)

/obj/item/food/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "breadslice"
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	eat_time = 0.5 SECONDS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/breadslice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/bread/plain
	name = "хлеб"
	desc = "Обычный земной хлеб."
	icon_state = "bread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("хлеб" = 10)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_CHEAP
	burns_in_oven = TRUE

/obj/item/food/bread/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/bread/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/bread/plain/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/plain, 5, 30)

/obj/item/food/breadslice/plain
	name = "ломтик хлеба"
	desc = "Напоминание о доме."
	icon_state = "breadslice"
	foodtypes = GRAIN
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	venue_value = FOOD_PRICE_TRASH

/obj/item/food/breadslice/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_STACK)

/obj/item/food/breadslice/plain/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/food/griddle_toast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)
/obj/item/food/breadslice/moldy
	name = "заплесневелый хлеб"
	desc = "Плесень отвратительна на вкус, но очень вкусна, если у вас девиантные вкусы!"
	icon_state = "moldybreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/mold = 10)
	tastes = list("гниющая плесень" = 1)
	foodtypes = GROSS

/obj/item/food/breadslice/moldy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 25)

/obj/item/food/bread/jelliedtoast
	name = "желейный тост"
	desc = "Ломтик хлеба, покрытый вкусным джемом."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellytoast"
	trash_type = /obj/item/trash/plate
	bite_consumption = 3
	tastes = list("тост" = 1, "желе" =1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/bread/jelliedtoast/cherry
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | FRUIT | SUGAR | BREAKFAST

/obj/item/food/bread/jelliedtoast/slime
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/slimejelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	foodtypes = GRAIN | TOXIC | SUGAR | BREAKFAST

/obj/item/food/bread/butteredtoast
	name = "тост с маслом"
	desc = "Слегка намазанный маслом ломтик хлеба."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "butteredtoast"
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("масло" = 1, "тост" = 1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL


/obj/item/food/bread/twobread
	name = "два хлеба"
	desc = "Кажется ужастно горьким."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "twobread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("хлеб" = 2)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/bread/meat
	name = "мясной рулет"
	desc = "Основное блюда для уважающего себя гурмана."
	icon_state = "meatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 12)
	tastes = list("хлеб" = 10, "мясо" = 10)
	foodtypes = GRAIN | MEAT
	venue_value = FOOD_PRICE_CHEAP


/obj/item/food/bread/meat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/meat, 5, 30)

/obj/item/food/breadslice/meat
	name = "ломтик мясного рулета"
	desc = "Ломтик вкуснейшего мясного хлеба."
	icon_state = "meatbreadslice"
	foodtypes = GRAIN | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 2.4)

/obj/item/food/bread/xenomeat
	name = "хлеб с мясом чужого"
	desc = "Основное блюда для уважающего себя гурмана. Сверхъеретический."
	icon_state = "xenomeatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 15)
	tastes = list("хлеб" = 10, "кислота" = 10)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/xenomeat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/xenomeat, 5, 30)

/obj/item/food/breadslice/xenomeat
	name = "ломтик хлеба с мясом чужого"
	desc = "Ломтик вкуснейшего мясного хлеба. Сверхъеретический."
	icon_state = "xenobreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 3)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/spidermeat
	name = "хлеб с паучьим мясом"
	desc = "Обнадёживающе зеленый мясной рулет из мяса паука."
	icon_state = "spidermeatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin = 15, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 12)
	tastes = list("хлеб" = 10, "паутинки" = 5)
	foodtypes = GRAIN | MEAT | TOXIC

/obj/item/food/bread/spidermeat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/spidermeat, 5, 30)

/obj/item/food/breadslice/spidermeat
	name = "ломтик хлеба с паучиьм мясом"
	desc = "Ломтик мясного рулета с мясом паука. Похоже, этот паук, ещё жаждет твоей смерти."
	icon_state = "xenobreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtypes = GRAIN | MEAT | TOXIC

/obj/item/food/bread/banana
	name = "банановый хлеб"
	desc = "Божественно сытное угощение."
	icon_state = "bananabread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/banana = 20)
	tastes = list("хлеб" = 10) // bananjuice will also flavour
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/banana/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/banana, 5, 30)

/obj/item/food/breadslice/banana
	name = "ломтик бананового хлеба"
	desc = "Ломтик вкуснейшего бананового хлеба."
	icon_state = "bananabreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/tofu
	name = "хлеб тофу"
	desc = "Как мясной рулет, но для вегетарианцев. Не гарантированно дает сверхспособности."
	icon_state = "tofubread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 10)
	tastes = list("хлеб" = 10, "тофу" = 10)
	foodtypes = GRAIN | VEGETABLES
	venue_value = FOOD_PRICE_TRASH

/obj/item/food/bread/tofu/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/tofu, 5, 30)

/obj/item/food/breadslice/tofu
	name = "ломтик хлеба тофу"
	desc = "Ломтик вкуснейшего хлеба тофу."
	icon_state = "tofubreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/bread/creamcheese
	name = "хлеб со сливочным сыром"
	desc = "Вкуснятина!"
	icon_state = "creamcheesebread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("хлеб" = 10, "сыр" = 10)
	foodtypes = GRAIN | DAIRY

/obj/item/food/bread/creamcheese/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/creamcheese, 5, 30)

/obj/item/food/breadslice/creamcheese
	name = "ломтик хлеба со сливочным сыром"
	desc = "Кусочек вкусняшки."
	icon_state = "creamcheesebreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/food/bread/empty
	name = "хлеб"
	icon_state = "tofubread"
	desc = "Хлеб, созданный по вашим самым смелым идеям."

// What you get from cutting a custom bread. Different from custom sliced bread.
/obj/item/food/breadslice/empty
	name = "ломтик хлеба"
	icon_state = "tofubreadslice"
	foodtypes = GRAIN
	desc = "Ломтик хлеба, созданного по вашим самым смелым идеям."

/obj/item/food/bread/empty/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/empty, 5, 30)

/obj/item/food/breadslice/empty/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/bread/mimana
	name = "мимановский хлеб"
	desc = "Лучше всего есть в тишине."
	icon_state = "mimanabread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/consumable/nothing = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("хлеб" = 10, "тишина" = 10)
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/mimana/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/mimana, 5, 30)

/obj/item/food/breadslice/mimana
	name = "ломтик мимановского хлеба"
	desc = "Ломтик тишины!"
	icon_state = "mimanabreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GRAIN | FRUIT

/obj/item/food/baguette
	name = "багет"
	desc = "Бон аппети!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	inhand_icon_state = "baguette"
	worn_icon_state = "baguette"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 3)
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	attack_verb_continuous = list("touche's")
	attack_verb_simple = list("touche")
	tastes = list("хлеб" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/garlicbread
	name = "чесночный хлеб"
	desc = "Увы, рано или поздно он заканчивается."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	inhand_icon_state = "garlicbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/garlic = 2)
	bite_consumption = 3
	tastes = list("хлеб" = 1, "чеснок" = 1, "масло" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/deepfryholder
	name = "сетка для фритюра"
	desc = "Если ты видишь это описание, то в код для фритюрницы насрали."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bite_consumption = 2

/obj/item/food/deepfryholder/MakeEdible()
	AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			food_flags = food_flags,\
			foodtypes = foodtypes,\
			volume = max_volume,\
			eat_time = eat_time,\
			tastes = tastes,\
			eatverbs = eatverbs,\
			bite_consumption = bite_consumption,\
			on_consume = CALLBACK(src, PROC_REF(On_Consume)))


/obj/item/food/deepfryholder/Initialize(mapload, obj/item/fried)
	if(!fried)
		stack_trace("A deepfried object was created with no fried target")
		return INITIALIZE_HINT_QDEL
	. = ..()
	name = fried.name //We'll determine the other stuff when it's actually removed
	appearance = fried.appearance
	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	lefthand_file = fried.lefthand_file
	righthand_file = fried.righthand_file
	inhand_icon_state = fried.inhand_icon_state
	desc = fried.desc
	w_class = fried.w_class
	slowdown = fried.slowdown
	equip_delay_self = fried.equip_delay_self
	equip_delay_other = fried.equip_delay_other
	strip_delay = fried.strip_delay
	species_exception = fried.species_exception
	item_flags = fried.item_flags
	obj_flags = fried.obj_flags
	inhand_x_dimension = fried.inhand_x_dimension
	inhand_y_dimension = fried.inhand_y_dimension

	if(!(SEND_SIGNAL(fried, COMSIG_ITEM_FRIED, src) & COMSIG_FRYING_HANDLED)) //If frying is handled by signal don't do the defaault behavior.
		fried.forceMove(src)


/obj/item/food/deepfryholder/Destroy()
	if(contents)
		QDEL_LIST(contents)
	return ..()

/obj/item/food/deepfryholder/proc/On_Consume(eater, feeder)
	if(contents)
		QDEL_LIST(contents)

/obj/item/food/deepfryholder/proc/fry(cook_time = 30)
	switch(cook_time)
		if(0 to 15)
			add_atom_colour(rgb(166,103,54), FIXED_COLOUR_PRIORITY)
			name = "слегка обжаренный [name]"
			desc = "[desc] Это было слегка обжарено во фритюре."
		if(16 to 49)
			add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
			name = "обжаренный [name]"
			desc = "[desc] Он был обжарен, что повысило его вкус на [rand(1, 75)]%."
		if(50 to 59)
			add_atom_colour(rgb(63,23,4), FIXED_COLOUR_PRIORITY)
			name = "сильно обжаренный [name]"
			desc = "[desc] Обжарено во фритюре до совершенства."
		if(60 to INFINITY)
			add_atom_colour(rgb(33,19,9), FIXED_COLOUR_PRIORITY)
			name = "физическое проявление самой концепции жареной пищи"
			desc = "Сильно прожаренное... что-то. Кто еще может сказать?"
	foodtypes |= FRIED

/obj/item/food/butterbiscuit
	name = "бисквит с маслом"
	desc = "Намажьте мне бисквит маслом!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("масло" = 1, "бисквит" = 1)
	foodtypes = GRAIN | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/butterdog
	name = "масло-дог"
	desc = "Изготовлено с использованием экзотических масел."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("масло" = 1, "экзотическое масло" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)