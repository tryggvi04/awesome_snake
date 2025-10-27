extends Node2D

# >
# <

@onready var apple = %apple
@onready var camera = %Camera2D
@onready var shockwave = %shockwave
@onready var mat = shockwave.material

var apple_grid_pos = Vector2(0, 0)

const GRID_BORDER_Y = 25
const GRID_BORDER_X = 27

const snake_scene = preload("res://snake.tscn")
const snake_head_sprite = preload("res://Assets/Images/snake_head.png")
const snake_neck_sprite = preload("res://Assets/Images/snake_neck.png")
const snake_body_sprite = preload("res://Assets/Images/snake_body.png")
var snakes = []

var direction = Vector2(0, -1)
var speed = 7  # grid a second
var GRID_SIZE = 40

var move_timer = 0.0

var snake_head

var turn_list = []

var snake_count = 0

var dying = false

var can_move = true



func _ready() -> void:
	spawn_apple()
	snakes.append(%snake)
	snakes[0].speed = speed
	snakes[0].direction = direction
	snakes[0].grid_pos = Vector2(14, 14)
	snakes[0].global_position = snakes[0].grid_pos * GRID_SIZE
	snake_head = snakes[0]
	snake_head.set_sprite(snake_head_sprite)
	
	var new_snake = spawn_snake(snake_neck_sprite)
	snakes.append(new_snake)
	
	new_snake = spawn_snake(snake_body_sprite)
	snakes.append(new_snake)


func _physics_process(delta: float) -> void:
	var moved = true
	move_timer += delta * speed
	if move_timer >= 1:
		if turn_list.is_empty() == false:
			var cur_turn = turn_list.pop_front()
			give_turn_array_to_snakes(cur_turn, snake_head.grid_pos + snake_head.direction)
		for snake in snakes:
			snake.move()
		handle_physics()
		move_timer = 0
	var grid_pos = snake_head.grid_pos
	grid_pos += direction 
	if Input.is_action_just_pressed("up") and direction != Vector2(0, 1):
		direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("down") and direction != Vector2(0, -1):
		direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("right") and direction != Vector2(-1, 0):
		direction = Vector2(1, 0)
	elif Input.is_action_just_pressed("left") and direction != Vector2(1, 0):
		direction = Vector2(-1, 0)
	else:
		moved = false
	if moved:
		turn_list.append(direction)


func spawn_apple():
	apple_grid_pos = Vector2()
	var same_place = true
	while same_place == true:
		apple_grid_pos = Vector2(randi_range(3, GRID_BORDER_X-1), randi_range(3, GRID_BORDER_Y-1))
		same_place = false
		for snake in snakes:
			if snake.grid_pos == apple_grid_pos:
				same_place = true
				break
	#mat.set_shader_parameter("radius", apple_grid_pos)
			
	apple.global_position = apple_grid_pos * GRID_SIZE


func give_turn_array_to_snakes(direction: Vector2, grid_pos: Vector2):
	for snake in snakes:
		snake.turn_list.append([direction, grid_pos])


func handle_physics():
	if snake_head.grid_pos.x > GRID_BORDER_X:
		died()
	if snake_head.grid_pos.x <= 2:
		died()
	if snake_head.grid_pos.y > GRID_BORDER_Y:
		died()
	if snake_head.grid_pos.y <= 2:
		died()
	
	for snake in snakes:
		if snake != snake_head:
			if snake_head.grid_pos == snake.grid_pos:
				died()
	
	var apple_radius = 60
	var apples_to_remove = []

	if snake_head.grid_pos == apple_grid_pos:
		trigger_shockwave()
		camera.shake(0.3, 100)
		spawn_apple()
		var new_snake = spawn_snake(snake_body_sprite)
		snakes.append(new_snake)
		apples_to_remove.append(apple)


func spawn_snake(sprite_to_use: Texture):
	snake_count += 1
	var new_snake = snake_scene.instantiate()
	add_child(new_snake)
	new_snake.snake_count = snake_count

	var last_snake = snakes[snakes.size() - 1]

	new_snake.grid_pos = last_snake.grid_pos - last_snake.direction
	new_snake.global_position = new_snake.grid_pos * GRID_SIZE

	new_snake.direction = last_snake.direction
	new_snake.snake_sprite.rotation = last_snake.snake_sprite.rotation
	new_snake.speed = speed
	new_snake.turn_list = last_snake.turn_list.duplicate(true)
	new_snake.set_sprite(sprite_to_use)

	return new_snake

func died():
	if dying == false:
		dying = true
		camera.shake(0.4, 100)
		can_move = false
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
		
func trigger_shockwave():
	var uv_center = apple.global_position / 1200
	mat.set_shader_parameter("center", uv_center)
	mat.set_shader_parameter("radius", 0.0)
	mat.set_shader_parameter("strength", 0.1)
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/radius", 0.5, 0.1)
	tween.tween_property(mat, "shader_parameter/strength", 0.0, 0.1)
	
