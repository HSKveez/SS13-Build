//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////
/obj/item/food/salad
	icon = 'icons/obj/food/soupsalad.dmi'
	trash_type = /obj/item/reagent_containers/glass/bowl
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("листья" = 1)
	foodtypes = VEGETABLES
	eatverbs = list("devour","nibble","gnaw","gobble","chomp") //who the fuck gnaws and devours on a salad
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/salad/melonfruitbowl
	name = "фруктовая арбузная миска"
	desc = "Для тех, кто любит съедобные миски."
	icon_state = "spring_salad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 4)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("арбуз" = 1)
	foodtypes = FRUIT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/salad/aesirsalad
	name = "салат Асов"
	desc = "Вероятно, он слишком невероятен для обычных людей, чтобы насладиться этим салатом в полной мере."
	icon_state = "aesirsalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/medicine/omnizine = 10, /datum/reagent/consumable/nutriment/vitamin = 12)
	tastes = list("листья" = 1)
	foodtypes = VEGETABLES | FRUIT

/obj/item/food/salad/herbsalad
	name = "травяной салат"
	desc = "Вкусный салат с яблоками."
	icon_state = "herbsalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("листья" = 1, "яблоки" = 1)
	foodtypes = VEGETABLES | FRUIT

/obj/item/food/salad/validsalad
	name = "валидный салат"
	desc = "Это просто салат с фрикадельками и ломтиками жареного картофеля. Ничего подозрительного."
	icon_state = "validsalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/doctor_delight = 8, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("листья" = 1, "картоха" = 1, "мясо" = 1, "валиды" = 1)
	foodtypes = VEGETABLES | MEAT | FRIED | JUNKFOOD | FRUIT

/obj/item/food/salad/fruit
	name = "фруктовый салат"
	desc = "Обычный фруктовый салат."
	icon_state = "fruitsalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("фрукты" = 1)
	foodtypes = FRUIT

/obj/item/food/salad/jungle
	name = "салат \"Джунгли\""
	desc = "Экзотические фрукты в миске."
	icon_state = "junglesalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 7)
	tastes = list("фрукты" = 1, "джунгли" = 1)
	foodtypes = FRUIT

/obj/item/food/salad/citrusdelight
	name = "цитрусовый восторг"
	desc = "Цитрусовый передоз!"
	icon_state = "citrusdelight"
	food_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/consumable/nutriment/vitamin = 7)
	tastes = list("кислинка" = 1, "листья" = 1)
	foodtypes = FRUIT

/obj/item/food/salad/ricebowl
	name = "миска риса"
	desc = "Миска сырого риса."
	icon_state = "ricebowl"
	microwaved_type = /obj/item/food/salad/boiledrice
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("рис" = 1)
	foodtypes = GRAIN | RAW

/obj/item/food/salad/boiledrice
	name = "миска вареного риса"
	desc = "Еще теплая миска риса."
	icon_state = "boiledrice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("рис" = 1)
	foodtypes = GRAIN

/obj/item/food/salad/ricepudding
	name = "рисовый пудинг"
	desc = "Все любят рисовый пудинг!"
	icon_state = "ricepudding"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("рис" = 1, "сладость" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/salad/ricepork
	name = "рис и свинина"
	desc = "Это рис и ...\"свинина\"..."
	icon_state = "riceporkbowl"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("рис" = 1, "мясо" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/salad/risotto
	name = "ризотто"
	desc = "Доказательство того, что итальянцы освоили все виды углеводов."
	icon_state = "risotto"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("rice" = 1, "cheese" = 1)
	foodtypes = GRAIN | DAIRY
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/salad/eggbowl
	name = "яичная миска"
	desc = "Миска риса с приготовленным яйцом."
	icon_state = "eggbowl"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("рис" = 1, "яйцо" = 1)
	foodtypes = GRAIN | MEAT //EGG = MEAT -NinjaNomNom 2017

/obj/item/food/salad/edensalad
	name = "салат Эдема"
	desc = "Салат с нераскрытым потенциалом."
	icon_state = "edensalad"
	food_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/medicine/earthsblood = 3, /datum/reagent/medicine/omnizine = 5, /datum/reagent/drug/happiness = 2)
	tastes = list("extreme bitterness" = 3, "hope" = 1)
	foodtypes = VEGETABLES

/obj/item/food/salad/gumbo
	name = "Черноглазое гамбо"
	desc = "Пряное и соленое блюдо из мяса и риса."
	icon_state = "gumbo"
	food_reagents = list(/datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/nutriment/vitamin = 3, /datum/reagent/consumable/nutriment = 5)
	tastes = list("building heat" = 2, "savory meat and vegtables" = 1)
	foodtypes = GRAIN | MEAT | VEGETABLES


/obj/item/reagent_containers/glass/bowl
	name = "миска"
	desc = "Простая миска, используемая для супов и салатов."
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/glass = 500)
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_ASSISTANT * 0.6

/obj/item/reagent_containers/glass/bowl/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/salad/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

// empty salad for custom salads
/obj/item/food/salad/empty
	name = "salad"
	foodtypes = NONE
	tastes = list()
	icon_state = "bowl"
	desc = "A delicious customized salad."
