extends CharacterBody2D
class_name Character

@export var player_idx = 0
@export var animation_player : AnimationPlayer
@onready var gravity_comp : GravityComp = $%GravityComp
@onready var horizontal_movement_comp : HorizontalMovementComp = $%HorizontalMovementComp
@onready var jump_comp : JumpComp = $%JumpComp

@onready var frame_data_system : FrameDataSystem = $%FrameDataSystem
@onready var move_activation_handler : MoveActivationHandler = $%MoveActivationHandler
@onready var sprite : Sprite2D = $Sprite2D

var state_machine : CallableStateMachine = CallableStateMachine.new()
var horizontal_dir_facing := 1
@export var state_properties : StateProperties

var hitstun_knockback_vector : Vector2 = Vector2.ZERO
var hitstun_knockback_time_remaining : float = 0.0

var invinsibility_time_remaining : float = 0.0

func _ready() -> void:
	state_machine.add_states(state_grounded, enter_state_grounded, leave_state_grounded)
	state_machine.add_states(state_attack, enter_state_attack, leave_state_attack)
	state_machine.add_states(state_hitstun, enter_state_hitstun, leave_state_hitstun)
	state_machine.set_initial_state(state_grounded)

	frame_data_system.took_a_hit.connect(on_took_a_hit)

func _physics_process(delta: float) -> void:
	state_machine.update(delta)

func update_horizontal_dir_facing() -> void:
	horizontal_dir_facing = horizontal_movement_comp.horizontal_dir_facing
	frame_data_system.scale.x = float(horizontal_dir_facing)
	sprite.flip_h = (horizontal_dir_facing == -1)

func on_took_a_hit(attacking_move_frame : MoveFrame) -> void:
	if invinsibility_time_remaining > 0: return

	match state_machine.current_state:
		"state_grounded":
			state_machine.change_state(state_hitstun)
			set_hitstun_knockback_vector(attacking_move_frame)
			hitstun_knockback_time_remaining = attacking_move_frame.state_properties.hitstun_knockback_frames / 60.0
		"state_attack":
			state_machine.change_state(state_hitstun)
			set_hitstun_knockback_vector(attacking_move_frame)
			hitstun_knockback_time_remaining = attacking_move_frame.state_properties.hitstun_knockback_frames / 60.0

func set_hitstun_knockback_vector(attacking_move_frame : MoveFrame) ->  void:
	var kb_vector = attacking_move_frame.state_properties.knockback_vector
	hitstun_knockback_vector = Vector2(
		kb_vector.x * attacking_move_frame.get_character().horizontal_dir_facing,
		kb_vector.y)

func apply_knockback() -> void:
	velocity = hitstun_knockback_vector



func enter_state_grounded() -> void:
	# print("player " + str(player_idx) + " entering grounded state")
	pass

func state_grounded(_delta : float) -> void:
	gravity_comp.enabled = true
	horizontal_movement_comp.enabled = true
	horizontal_movement_comp.player_has_control = true
	jump_comp.enabled = true

	move_and_slide()

	if !animation_player.is_playing():
		animation_player.play("Idle")

	if !state_properties.horizontal_dir_locked:
		update_horizontal_dir_facing()
	if state_properties.attack:
		state_machine.change_state(state_attack)

func leave_state_grounded() -> void:
	# print("player " + str(player_idx) + " leaving grounded state")
	pass



func enter_state_attack() -> void:
	# print("player " + str(player_idx) + " entering attack state")
	pass

func state_attack(_delta : float) -> void:
	if state_properties.locked:
		gravity_comp.enabled = false
		horizontal_movement_comp.enabled = false
		horizontal_movement_comp.player_has_control = true
		jump_comp.enabled = false
		velocity = Vector2.ZERO
	else:
		gravity_comp.enabled = true
		horizontal_movement_comp.enabled = true
		horizontal_movement_comp.player_has_control = true
		jump_comp.enabled = true
		move_and_slide()

	if !state_properties.horizontal_dir_locked:
		update_horizontal_dir_facing()

	if !state_properties.attack:
		state_machine.change_state(state_grounded)

func leave_state_attack() -> void:
	# print("player " + str(player_idx) + " leaving attack state")
	pass


func enter_state_hitstun() -> void:
	# print("player " + str(player_idx) + " entering hitstun state")
	move_activation_handler.go_to_hitstun()
	apply_knockback()
	if animation_player is AnimationPlayer:
		animation_player.play("Hitstun")

func state_hitstun(delta : float) -> void:
	gravity_comp.enabled = true
	horizontal_movement_comp.enabled = true
	horizontal_movement_comp.player_has_control = false
	jump_comp.enabled = false
	apply_knockback()
	move_and_slide()

	hitstun_knockback_time_remaining -= delta

	if hitstun_knockback_time_remaining <= 0:
		state_machine.change_state(state_grounded)

func leave_state_hitstun() -> void:
	# print("player " + str(player_idx) + " leaving hitstun state")
	if animation_player is AnimationPlayer:
		animation_player.play("Idle")
