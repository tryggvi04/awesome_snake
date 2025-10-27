extends Node2D

const tile_scene = preload("res://tile.tscn")

const GRID_SIZE = 40

const STARTX = 2
const STARTY = 2
const XM = 28
const YM = 25

var map = []

func _ready() -> void:
	var index = 0
	for i in range(STARTY, YM+3):
		var row = []
		for j in range(STARTX, XM+3):
			row.append(0)
		map.append(row)
	for y in range(STARTY, YM):
		index += 1
		for x in range(STARTX, XM):
			var new_tile = tile_scene.instantiate()
			add_child(new_tile)
			new_tile.base_size = Vector2(GRID_SIZE, GRID_SIZE)
			new_tile.pivot_offset = Vector2(GRID_SIZE/2, GRID_SIZE/2)
			new_tile.size = Vector2(GRID_SIZE, GRID_SIZE)
			new_tile.global_position = Vector2(x*GRID_SIZE, y*GRID_SIZE)
			if index % 2 == 0:
				new_tile.color = Color.DARK_RED
			else:
				new_tile.color = Color.BLACK
			index += 1
			map[y][x] = new_tile

func room_shake():
	for x in range(STARTX+1, XM-3):
		for y in range(STARTY+1, YM-5):
			map[y][x].extend(5, 0.05)
		await get_tree().create_timer(0.001).timeout
		
