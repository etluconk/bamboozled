extends PlatformingBaseComponent
class_name JumpComp

var p : CharacterBody2D

@export_group("Control")
@export var jump_velocity := 360.0
@export var jump_cancel_cutoff_divisor := 3.0
@export var instant_jump_cancel := false

@export_group("Leniency")
@export var coyote_time_dur := 0.1
@export var buffer_dur := 0.2

# Trackers
@onready var coyote_time_remaining := coyote_time_dur
@onready var buffer_time_remaining := 0.0
@onready var jumped_this_frame := false

# Signals
signal jumped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    p = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    jumped_this_frame = false

    if !enabled: return

    # Do stuff
    if (wants_to_jump() or buffered_a_jump()) and can_jump():
        jump()
        jumped_this_frame = true

    if wants_to_jump() and !can_jump():
        buffer_jump()

    if wants_to_cancel_jump() and can_cancel_jump():
        cancel_jump()

    # Update trackers
    if p.is_on_floor() and !jumped_this_frame:
        coyote_time_remaining = coyote_time_dur
        buffer_time_remaining = 0
    else:
        coyote_time_remaining -= delta
        buffer_time_remaining -= delta
    buffer_time_remaining = max(0, buffer_time_remaining)

func jump() -> void:
    p.velocity.y = -jump_velocity
    coyote_time_remaining = 0
    buffer_time_remaining = 0
    jumped.emit()

func buffer_jump() -> void:
    buffer_time_remaining = buffer_dur

func cancel_jump() -> void:
    p.velocity.y = 0.0 if instant_jump_cancel else (-jump_velocity) / jump_cancel_cutoff_divisor

# Getters!!
func can_jump() -> bool:
    return p.is_on_floor() or coyote_time_remaining > 0

func wants_to_jump() -> bool:
    return player_input_just_pressed("jump")

func buffered_a_jump() -> bool:
    return buffer_time_remaining > 0

func can_cancel_jump() -> bool:
    return p.velocity.y < (-jump_velocity) / jump_cancel_cutoff_divisor

func wants_to_cancel_jump() -> bool:
    return !player_input_pressed("jump")
