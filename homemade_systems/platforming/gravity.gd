extends PlatformingBaseComponent
class_name GravityComp

var p : CharacterBody2D

@export var rise_gravity_strength := 20.0
@export var fall_gravity_strength := 60.0

@export var cap_rise_velocity := false
@export var rise_velocity_cap := -100.0
@export var cap_fall_velocity := true
@export var fall_velocity_cap := 100.0

# Trackers
@onready var was_on_floor := true
@onready var previous_velocity : Vector2

# Signals

signal landed(previous_velocity: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p = get_parent()
	previous_velocity = p.velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if enabled: apply_gravity(delta)

	if p.is_on_floor() and !was_on_floor:
		landed.emit(previous_velocity)

	# Update trackers
	was_on_floor = p.is_on_floor()
	previous_velocity = p.velocity

func apply_gravity(delta: float) -> void:
	if p.is_on_floor(): return

	var rising = p.velocity.y < 0
	var gravity_strength = rise_gravity_strength if rising else fall_gravity_strength

	p.velocity.y += gravity_strength * delta

	if cap_rise_velocity:
		p.velocity.y = max(rise_velocity_cap, p.velocity.y)
	if cap_fall_velocity:
		p.velocity.y = min(fall_velocity_cap, p.velocity.y)
