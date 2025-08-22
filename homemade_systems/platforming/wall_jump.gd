extends PlatformingBaseComponent
class_name WallJumpComp

var p : CharacterBody2D

@export var horizontal_movement_componenent : HorizontalMovementComp
@export var jump_componenent : JumpComp
@export var wall_left_ray : RayCast2D
@export var wall_right_ray : RayCast2D

@export_group("Control")
@export var jump_y_velocity := 360.0
@export var jump_x_velocity := 1000.0
@export var wall_cling_velocity_max := 100

@export_group("Leniency")
@export var wall_stick_dur := 0.2
@export var wall_stick_margin := 2.0
@export var buffer_dur := 0.2

# Trackers
@onready var wall_stick_remaining = wall_stick_dur
@onready var stuck_to_wall := false
@onready var was_stuck_to_wall := stuck_to_wall
@onready var buffer_time_remaining = 0

# Signals
signal wall_jumped(wall_normal)
signal hit_wall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p = get_parent()
	wall_left_ray.target_position = Vector2(wall_stick_margin + 3, 0)
	wall_right_ray.target_position = Vector2(-wall_stick_margin - 3, 0)
	process_priority = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !enabled: return

	# Wall stick
	var on_wall_left = wall_left_ray.is_colliding() and !p.is_on_floor()
	var on_wall_right = wall_right_ray.is_colliding() and !p.is_on_floor()

	if can_wall_jump(on_wall_left, on_wall_right):
		if !stuck_to_wall:
			wall_stick_remaining = wall_stick_dur
		stuck_to_wall = true
		if !p.is_on_wall():
			if on_wall_left:
				p.position.x += wall_stick_margin
			elif on_wall_right:
				p.position.x -= wall_stick_margin

	if stuck_to_wall and sign(horizontal_input_direction()) == wall_normal().x:
		wall_stick_remaining -= delta
	if stuck_to_wall and sign(horizontal_input_direction()) != wall_normal().x:
		wall_stick_remaining = wall_stick_dur
	if clinging_to_wall():
		p.velocity.y = min(p.velocity.y, wall_cling_velocity_max)

	if stuck_to_wall and (wall_stick_remaining <= 0 or !p.is_on_wall_only()):
		stuck_to_wall = false

	if stuck_to_wall:
		p.velocity.x = wall_normal().x * -1

	# Do stuff
	if (wants_to_jump() or buffered_a_jump()) and can_wall_jump(on_wall_left, on_wall_right):
		jump(on_wall_left, on_wall_right)

	if wants_to_jump() and !can_wall_jump(on_wall_left, on_wall_right) and !p.is_on_floor() and !jump_componenent.can_jump():
		buffer_jump()

	if stuck_to_wall and !was_stuck_to_wall:
		hit_wall.emit()

	# Update trackers
	if p.is_on_wall_only():
		buffer_time_remaining = 0
	else:
		buffer_time_remaining -= delta
		wall_stick_remaining = 0

	was_stuck_to_wall = stuck_to_wall

func jump(on_wall_left: bool, on_wall_right: bool) -> void:
	var wall_norm = wall_normal().x

	if !p.is_on_wall():
		if on_wall_left:
			p.position.x += wall_stick_margin
			wall_norm = -1
		elif on_wall_right:
			p.position.x -= wall_stick_margin
			wall_norm = 1

	p.velocity.x = wall_norm * jump_x_velocity
	p.velocity.y = -jump_y_velocity
	wall_stick_remaining = 0
	stuck_to_wall = false
	buffer_time_remaining = 0

	jump_componenent.coyote_time_remaining = 0
	wall_jumped.emit(wall_norm)

func buffer_jump() -> void:
	buffer_time_remaining = buffer_dur

# Getters!

func can_wall_jump(on_wall_left: bool, on_wall_right: bool) -> bool:
	return p.is_on_wall_only() or on_wall_left or on_wall_right

func wants_to_jump() -> bool:
	var wants = player_input_just_pressed("up")
	return wants

func buffered_a_jump() -> bool:
	return buffer_time_remaining > 0

func wall_normal() -> Vector2:
	return p.get_wall_normal()

func clinging_to_wall() -> bool:
	return stuck_to_wall and sign(horizontal_input_direction()) == -wall_normal().x and p.velocity.y > 0 and enabled
