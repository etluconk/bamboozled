extends PlatformingBaseComponent
class_name HorizontalMovementComp

var p : CharacterBody2D

@export var player_has_control := true
@export var top_speed := 180.0
@export var cap_velocity := true
@export var velocity_cap := 180.0

@export_group("Acceleration")
@export var floor_start_rate := 2000.0
@export var floor_stop_rate := 2000.0
@export var air_start_rate := 2000.0
@export var air_stop_rate := 2000.0

@export_group("No Control Acceleration")
@export var no_control_floor_stop_rate := 500.0
@export var no_control_air_stop_rate := 500.0

# Trackers!
var horizontal_dir_facing := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var start_rate : float = 0.0
	var stop_rate : float = 0.0
	var rate : float = 0.0

	if player_has_control:
		start_rate = floor_start_rate if p.is_on_floor() else air_start_rate
		stop_rate = floor_stop_rate if p.is_on_floor() else air_stop_rate
		rate = stop_rate if horizontal_input_direction() == 0 else start_rate
	else:
		stop_rate = no_control_floor_stop_rate if p.is_on_floor() else no_control_air_stop_rate

	if enabled:
		if player_has_control:
			p.velocity.x = move_toward(p.velocity.x, top_speed * horizontal_input_direction(), rate * delta)
			if cap_velocity:
				p.velocity.x = clampf(p.velocity.x, -velocity_cap, velocity_cap)
		else:
			p.velocity.x = move_toward(p.velocity.x, 0, stop_rate * delta)
			# if cap_velocity:
			# 	p.velocity.x = clampf(p.velocity.x, -velocity_cap, velocity_cap)

	if horizontal_input_direction() > 0: horizontal_dir_facing = 1
	if horizontal_input_direction() < 0: horizontal_dir_facing = -1

# Getters!
