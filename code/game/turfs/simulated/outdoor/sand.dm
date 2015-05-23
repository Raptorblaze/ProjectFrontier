/turf/simulated/outdoor/sand

	name = "sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"

/turf/simulated/outdoor/sand/Entered(atom/movable/A as mob|obj) // Loop around the map
	if(movement_disabled)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	..()
	if ((!(A) || src != A.loc))	return

	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if(A.z > 6) return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(A, /obj/effect/meteor))
				qdel(A)
				return

			var/move_to_z = src.z
			var/safety = 1

			//Check if it's a mob pulling an object
			var/atom/movable/was_pulling = null
			var/mob/living/MOB = null
			if(isliving(A))
				MOB = A
				if(MOB.pulling)
					was_pulling = MOB.pulling //Store the object to transition later

			while(move_to_z == src.z)
				var/move_to_z_str = pickweight(accessable_z_levels)
				move_to_z = text2num(move_to_z_str)
				safety++
				if(safety > 10)
					break

			if(!move_to_z)
				return

			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE + 1
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			spawn (0)
				if(was_pulling && MOB) //Carry the object they were pulling over when they transition
					was_pulling.loc = MOB.loc
					MOB.start_pulling(was_pulling)
				if ((A && A.loc))
					A.loc.Entered(A)