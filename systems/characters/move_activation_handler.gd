extends Node
class_name MoveActivationHandler

@export var frame_data_system : FrameDataSystem
@export var animation_player : AnimationPlayer

func _ready() -> void:
	connect_move_frame_data_signals()

func _physics_process(_delta: float) -> void:
	if animation_player is AnimationPlayer:
		if !animation_player.is_playing():
			animation_player.play("Idle")

func connect_move_frame_data_signals() -> void:
	if not (frame_data_system is FrameDataSystem): return
	for child in frame_data_system.get_children():
		if child is MoveFrameData:
			child.move_activation_input_action_activated.connect(on_move_activation_input_action_activated)

func on_move_activation_input_action_activated(move_frame_data) -> void:
	# TEMPORARY
	var p = get_parent()
	if p is Character:
		if p.state_machine.current_state != "state_attack" and p.state_machine.current_state != "state_hitstun":
			animation_player.stop()
			animation_player.play(move_frame_data.name)

func go_to_hitstun() -> void:
	animation_player.play("Idle")
