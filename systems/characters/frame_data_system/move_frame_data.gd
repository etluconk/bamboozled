@tool
extends Node2D
class_name MoveFrameData

var player_idx : int = -1

@export var progress : int = 0:
	set(value):
		progress = value
		progress_changed.emit()
@export var move_activation_input_action : MoveActivationInputAction

signal progress_changed
signal move_activation_input_action_activated

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return

	if move_activation_input_action is MoveActivationInputAction:
		if move_activation_input_action.button != null:
			if player_input_just_pressed(move_activation_input_action.button):
				move_activation_input_action_activated.emit(self)

func get_active_move_frame() -> MoveFrame:
	return get_children()[progress]

func get_active_move_frame_areas_of_type(area_type : MoveFrameArea.AreaType) -> Array[MoveFrameArea]:
	if progress > get_child_count() - 1: return []

	var active_move_frame = get_children()[progress]
	if active_move_frame is MoveFrame:
		return active_move_frame.get_move_frame_areas_of_type(area_type)
	else:
		return []

func activate_current_move_frame_area() -> void:
	for i in get_children().size():
		var child = get_children()[i]
		if i == progress:
			child.show()
			if child is MoveFrame:
				for grandchild in child.get_children():
					grandchild.set_activated(true)
		else:
			child.hide()
			if child is MoveFrame:
				for grandchild in child.get_children():
					grandchild.set_activated(false)

func set_all_move_frames_enabled(enabled : bool) -> void:
	for i in get_children().size():
		var child = get_children()[i]
		if enabled:
			child.show()
			if child is MoveFrame:
				for grandchild in child.get_children():
					grandchild.set_activated(true)
		else:
			child.hide()
			if child is MoveFrame:
				for grandchild in child.get_children():
					grandchild.set_activated(false)

func horizontal_input_direction() -> float:
	if player_idx == -1: return 0
	return int(Input.is_action_pressed("right_" + str(player_idx))) - int(Input.is_action_pressed("left_" + str(player_idx)))


func player_input_just_pressed(input_action_name : String) -> bool:
	if player_idx == -1: return false
	return Input.is_action_just_pressed(input_action_name + "_" + str(player_idx))

func player_input_pressed(input_action_name : String) -> bool:
	if player_idx == -1: return false
	return Input.is_action_pressed(input_action_name + "_" + str(player_idx))
