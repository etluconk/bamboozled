extends PlatformingBaseComponent
class_name HorizontalMovementComp

var p : CharacterBody2D

@export var top_speed := 180.0
@export var cap_velocity := true
@export var velocity_cap := 180.0

@export_group("Acceleration")
@export var floor_start_rate := 2000.0
@export var floor_stop_rate := 2000.0
@export var air_start_rate := 2000.0
@export var air_stop_rate := 2000.0

# Trackers!
var horizontal_dir_facing := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var start_rate = floor_start_rate if p.is_on_floor() else air_start_rate
	var stop_rate = floor_stop_rate if p.is_on_floor() else air_stop_rate
	var rate = stop_rate if horizontal_input_direction() == 0 else start_rate

	if enabled:
		p.velocity.x = move_toward(p.velocity.x, top_speed * horizontal_input_direction(), rate * delta)

	if cap_velocity:
		p.velocity.x = clampf(p.velocity.x, -velocity_cap, velocity_cap)

	if horizontal_input_direction() > 0: horizontal_dir_facing = 1
	if horizontal_input_direction() < 0: horizontal_dir_facing = -1

# Getters!
