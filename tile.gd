extends ColorRect

var base_size

func extend(scale, duration):
	size *= scale
	z_index = 10
	await get_tree().create_timer(duration).timeout
	z_index = 0
	size = base_size
