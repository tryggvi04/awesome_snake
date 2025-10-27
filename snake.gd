extends Node2D

const GRID_SIZE = 40
const SNAKE_SIZE = 40
var speed
var direction
var turn_list = []

var snake_sprite

var snake_head = false

var grid_pos = Vector2(0, 0)
var prev_grid_pos = Vector2(0, 0)

var lerp_progress = 0.0

var should_lerp = false

var snake_count

func _ready() -> void:
	snake_sprite = $snake
	prev_grid_pos = grid_pos 
	global_position = grid_pos * GRID_SIZE
	lerp_progress = 1.0  

func _physics_process(delta: float) -> void:
	if lerp_progress < 1.0 and get_parent().can_move:
		lerp_progress += delta * speed
		lerp_progress = min(lerp_progress, 1.0)
		
		var start_pos = prev_grid_pos * GRID_SIZE
		var end_pos = grid_pos * GRID_SIZE
		global_position = start_pos.lerp(end_pos, lerp_progress)

func move():
	prev_grid_pos = grid_pos
	
	grid_pos += direction
	
	lerp_progress = 0.0

	# Handle turns
	if turn_list.size() > 0 and (turn_list[0][1] == grid_pos and !snake_head or snake_head):
		direction = turn_list[0][0]
		if direction == Vector2.UP:
			snake_sprite.rotation = 0
		elif direction == Vector2.DOWN:
			snake_sprite.rotation = PI
		elif direction == Vector2.LEFT:
			snake_sprite.rotation = -PI/2
		elif direction == Vector2.RIGHT:
			snake_sprite.rotation = PI/2
		
		turn_list.pop_front()

func set_sprite(sprite):
	snake_sprite.texture = sprite
