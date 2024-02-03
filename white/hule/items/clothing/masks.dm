/obj/item/clothing/mask/gas/anonist
	name = "подозрительная маска"
	desc = "Древняя маска гордого воина, сражающегося с несправедливостью, подлым правительством и прогнившей системой."
	icon = 'white/hule/icons/obj/masks.dmi'
	worn_icon = 'white/hule/icons/onmob/masks.dmi'
	icon_state = "fawkes"
	inhand_icon_state = "fawkes"
	armor = list("melee" = 10, "bullet" = 20, "laser" = 0,"energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	modifies_speech = TRUE
	var/cursed = TRUE

/obj/item/clothing/mask/gas/anonist/equipped(mob/living/carbon/human/user, slot)
	..()
	if(cursed && slot == 2)
		to_chat(user, span_warning("Ха лолка ебать затралил у тя [pick("батрудинов","биекция","тошиба","бомбанушен228","будапешт","бандера","бандероль","багратион","багет","баребух","бивалент")] еБаТьТыЛоХ"))
//		to_chat(user, "<img src=[pick("cdn.discordapp.com/attachments/389758687750782997/428556384435568640/unknown.png", "cdn.discordapp.com/attachments/389758687750782997/428556488198324224/B8ytQCR6_6w.png","cdn.discordapp.com/attachments/389758687750782997/428556551574257684/unknown.png","cdn.discordapp.com/attachments/389758687750782997/428558148400578561/unknown.png")]>")

/obj/item/clothing/mask/gas/anonist/attack_hand(mob/user)
	if(cursed && iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			to_chat(user, span_userdanger("Ты че деб? Ты хочешь чтоб ОНИ меня ВЫЧИСЛИЛИ по ай-си-кью и ОТПИЗДИЛИ, дурашка? А, блин????????????"))
			return
	..()

/obj/item/clothing/mask/gas/anonist/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		if(prob(1))
			playsound(get_turf(src), 'white/valtos/sounds/povezlo-povezlo.ogg', 50, TRUE)
			message += pick(" А теперь слушайте внимательно, тупорылая раковая опухоль планеты Земля: желаю Вам сдохнуть от рака, спида или несчастного случая. Вы — выблядок, костлявый пидорок, который тяжелее своего хуёчка в жизни ничего не держал. А если Вы ещё и в армии служили, то Вы автоматная «служанка». Короче ебучий хуесос, трусливый педик и лоховское чмо. К тому же Вы маменькин сынок, а отец Ваш вафлёр кривозубый.", \
				" Вы мне тут дурачка не включайте, я прекрасно знаю, кто Вы и что Вы.", \
				" До встречи.", \
				" Я прекрасно вижу ПДА, с которых писались сообщения, я вижу ID-карту, а также много ещё чего. И не указывайте мне, что делать, сами занимайтесь делом.", \
				" Опыт по таким как Вы есть. При обращении к конкретному человеку слово «Вы» и его производные пишутся с большой буквы, если обращаетесь к нескольким людям — с маленькой.", \
				" Не нужно включать олигофрена и переводить всё в шутку, типа всё ОК и это просто Космическая Станция. Увы, тупорылые долбоёбы вроде Вас осознают всю тягость последствий уже после гнилого базара. Слово — не воробей, вылетит — не поймаешь.", \
				" Смелый Вы только в радиоканале, в реальной жизни Вы трусливая падаль. Занимайтесь своими делами и не лезьте в чужие дела, каждый зарабатывает как может.", \
				" Вы — высокопримативное низкоранговое быдло. Были бы Вы хотя бы чуток низкопримативнее, не разводили бы срач, а купили шоколадку за 25 кредитов, но в силу инстинктивного менталитета Ваша блядская гордость не позволила Вам этого сделать.", \
				" Не забудьте посмотреть прикреплённые фотографии к шлюзам. В прошлый месяц заработал 28 миллионов кредитов, дальше — больше. Вы моего мизинца не стоите. Ещё я сейчас активно работаю над облачным онлайн-тандердомом нового поколения и у меня безлимитный нейролинк 1 Кубит/с. Помните, что мои шаттлы уникальные в своём роде, такого больше ни у кого нет и не будет. Это не ЧСВ, а констатация очевидных фактов.", \
				" Такие ублюдки как Вы потом мне извинения приносят и признают свою неправоту.", \
				" Я никогда не буду просто так катить на кого-то бочку, я всегда за справедливость.", \
				" С неуважением, инженер с двумя дипломами, который никогда не пил, не курил и не ширялся.", \
				" Игнор.", \
				" Всё, что я сказал, чистейшая правда. Клянусь сердцем своей матери.", \
				" Приветствую, тупорылое, прокуренное, пропитое и перетраханное быдло.", \
				" А ещё я имею серьёзные связи в Правительстве, так что не бесите меня.", \
				" Нейролинк работает с 2550 года, а начал я заниматься этой темой ещё со времён первой NanoStation, чиповал ассистентов, производил пиратские диски с ЕРП, а продавцы покупали у меня оптом. Я этим занимаюсь профессионально и с душой.", \
				" Нейролинк пользуется огромной популярностью, дальше — больше. Многие люди готовы платить за отсутствие ассистентов и большую скорость ЕРП, кроме того, у многих квантовые связи блокируют или ограничивают ЕРП-трафик, тут-то на помощь и приходит Нейролинк.", \
				" Более 40 миллионов людей с ПДА не имеют возможности проводить ЕРП, так как ПДА режут или блокируют скорость ЕРП-трафика, так как он даёт очень сильную нагрузку на сеть. Как правило, такое ограничение на безлимитных тарифах. Также такое встречается на тарифах ЕРП, если NanoTrasen не уверен, сможет ли выдержать нагрузку с ЕРП-трафиком. Иногда встречается лимит по ЕРП-трафику, например: не более 50 ЕРП в месяц, потом скорость на ЕРП режут. В первую очередь для таких случаев и подходит Нейролинк, где можно заниматься ЕРП по прямым ссылкам напрямую с серверов на большой скорости.", \
				" Вы наверное не в курсе, что ЕРПешась эмоутами бесплатно, на таких тупорылых долбоёбах как Вы зарабатывают бабло на показах Lifeweb и прочего дерьма. Здесь же Вы платите за удобный сервис.", \
				" За что Вы предъявляете? За то, что Нейролинк даёт людям возможность ЕРП на большой скорости без лишних хлопот? За сраные 25 кредитов? С какого хуя Вам кто-то что-то должен делать бесплатно? Вы не подумали, что содержание Нейролинка, в том числе аренда сервера стоит денег? Платные годовые подписки на НаноДиске и Облаке NanoTrasen с последующим продлением Вам о чём-то говорят? За «спасибо» работают только рабы и лохи, любой труд должен быть оплачен.", \
				" Вы просто завидуете, так как наверняка работаете за ~30 кредитных косарей в месяц. Станция-работа-станция — вот Ваша стезя. В ЕРП-технологиях и инженерном деле нихуя не понимаете, поэтому беситесь ещё сильнее. Что сука, жабка давит, что я разработал систему, которая приносит охуенное бабло в пассивном режиме, а Вам приходится РАБотать на какого-то дядю? А вообще, кто Вам мешает заняться чем-то «серым»??? Вы типичный завистливый ассистент-неудачник. Это судьба. Смиритесь. Всегда будут бедняки, средний класс и богатые. ВСЕГДА. Вы же бедняк, поэтому хотите, чтобы все были равны. Такие как Вы живут по принципу «ни себе ни людям».")
	speech_args[SPEECH_MESSAGE] = trim(message)

/datum/design/anonist
	name = "Странная Маска"
	id = "anonist"
	build_type = AUTOLATHE
	materials = list(/datum/material/diamond = 100000) // 50 алмазов
	build_path = /obj/item/clothing/mask/gas/anonist
	category = list("initial", "Разное")