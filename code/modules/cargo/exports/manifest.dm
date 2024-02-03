// Approved manifest.
// +80 credits flat.
/datum/export/manifest_correct
	cost =  CARGO_CRATE_VALUE * 0.4
	k_elasticity = 0
	unit_name = "утвержденная накладная"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_correct/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_approved() && !M.errors)
		return TRUE
	return FALSE

// Correctly denied manifest.
// Refunds the package cost minus the cost of crate.
/datum/export/manifest_error_denied
	cost = -CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "правильно отклоненная накладная"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_error_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_denied() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return ..() + M.order_cost


// Erroneously approved manifest.
// Substracts the package cost.
/datum/export/manifest_error
	unit_name = "ошибочно утвержденная накладная"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_error/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_approved() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return -M.order_cost


// Erroneously denied manifest.
// Substracts the package cost minus the cost of crate.
/datum/export/manifest_correct_denied
	cost = CARGO_CRATE_VALUE
	unit_name = "ошибочно отклоненная накладная"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_correct_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_denied() && !M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return ..() - M.order_cost
