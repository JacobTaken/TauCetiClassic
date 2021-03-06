//device to take core samples from mineral turfs - used for various types of analysis

/obj/item/weapon/storage/box/samplebags
	name = "sample bag box"
	desc = "A box claiming to contain sample bags."

/obj/item/weapon/storage/box/samplebags/atom_init()
	for (var/i in 1 to 7)
		var/obj/item/weapon/evidencebag/S = new(src)
		S.name = "sample bag"
		S.desc = "a bag for holding research samples."
	. = ..()

//////////////////////////////////////////////////////////////////

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract geological core samples."
	icon = 'icons/obj/device.dmi'
	icon_state = "sampler0"
	item_state = "sampler"
	w_class = 1.0
	//slot_flags = SLOT_BELT
	var/sampled_turf = ""
	var/num_stored_bags = 10
	var/obj/item/weapon/evidencebag/filled_bag

/obj/item/device/core_sampler/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "<span class='notice'>\The [src] is [sampled_turf ? "full" : "empty"], and has [num_stored_bags] bag\s remaining.</span>")

/obj/item/device/core_sampler/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/evidencebag))
		if(W.contents.len)
			to_chat(user, "\red This bag has something inside it!")
		else if(num_stored_bags < 10)
			qdel(W)
			num_stored_bags += 1
			to_chat(user, "\blue You insert the [W] into the core sampler.")
		else
			to_chat(user, "\red The core sampler can not fit any more bags!")
	else
		return ..()

/obj/item/device/core_sampler/proc/sample_item(item_to_sample, mob/user)
	var/datum/geosample/geo_data
	if(istype(item_to_sample, /turf/simulated/mineral))
		var/turf/simulated/mineral/T = item_to_sample
		T.geologic_data.UpdateNearbyArtifactInfo(T)
		geo_data = T.geologic_data
	else if(istype(item_to_sample, /obj/item/weapon/ore))
		var/obj/item/weapon/ore/O = item_to_sample
		geo_data = O.geologic_data

	if(geo_data)
		if(filled_bag)
			to_chat(user, "\red The core sampler is full!")
		else if(num_stored_bags < 1)
			to_chat(user, "\red The core sampler is out of sample bags!")
		else
			icon_state = "sampler1"

			//put in a rock sliver
			var/obj/item/weapon/rocksliver/R = new
			R.geological_data = geo_data

			filled_bag = new(src)
			filled_bag.name = "sample bag"
			filled_bag.put_item_in(R)
			num_stored_bags--

			to_chat(user, "\blue You take a core sample of the [item_to_sample].")
	else
		to_chat(user, "\red You are unable to take a sample of [item_to_sample].")

/obj/item/device/core_sampler/attack_self()
	if(filled_bag)
		to_chat(usr, "\blue You eject the full sample bag.")
		var/success = 0
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			success = M.put_in_inactive_hand(filled_bag)
		if(!success)
			filled_bag.loc = get_turf(src)
		filled_bag = null
		icon_state = "sampler0"
	else
		to_chat(usr, "\red The core sampler is empty.")
