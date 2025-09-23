@tool
extends Node2D
class_name FrameDataSystem

@export var active_move_frame_data_name : String:
	set(value):
		active_move_frame_data_name = value
		update_frame_data()

@onready var hitbox = $%Hitbox
@onready var hurtbox = $%Hurtbox

signal took_a_hit
signal attacked

func _ready() -> void:
	for child in get_children():
		if child is MoveFrameData:
			child.progress_changed.connect(update_frame_data)
			child.hide()
			child.player_idx = get_player_idx()

	if !Engine.is_editor_hint():
		hitbox.show()
		hurtbox.show()

	connect_move_frame_area_signals()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return

	var p = get_parent()
	if p is Character:
		if get_active_move_frame_data() != null:
			if get_active_move_frame_data().get_active_move_frame() != null:
				p.state_properties = get_active_move_frame_data().get_active_move_frame().state_properties

func update_frame_data():
	disable_and_enable_move_frames()

func free_all_children_of_node(node : Node):
	if !node: return
	for child in node.get_children():
		child.free()

func get_active_move_frame_areas_of_type(area_type : MoveFrameArea.AreaType) -> Array[MoveFrameArea]:
	var active_move_frame_data = get_active_move_frame_data()

	if active_move_frame_data != null:
		return active_move_frame_data.get_active_move_frame_areas_of_type(area_type)
	else:
		return []

func get_active_move_frame_data() -> MoveFrameData:
	return get_node_or_null(active_move_frame_data_name)

func disable_and_enable_move_frames() -> void:
	var active_move_frame_data = get_node_or_null(active_move_frame_data_name)
	for child in get_children():
		if child is MoveFrameData:
			if child == active_move_frame_data:
				child.show()
				child.activate_current_move_frame_area()
			else:
				child.hide()
				child.set_all_move_frames_enabled(false)

func connect_move_frame_area_signals() -> void:
	for child in get_children():
		if child is MoveFrameData:
			for grandchild in child.get_children():
				if grandchild is MoveFrame:
					for great_grandchild in grandchild.get_children():
						if great_grandchild is MoveFrameArea:
							great_grandchild.on_on_area_entered.connect(on_move_frame_area_entered)

func on_move_frame_area_entered(move_frame_area : MoveFrameArea, entering_area : MoveFrameArea) -> void:
	if move_frame_area.area_type == MoveFrameArea.AreaType.HURTBOX and entering_area.get_move_frame().get_character() != get_parent():
		took_a_hit.emit(entering_area.get_move_frame())



func get_player_idx() -> int:
	var p = get_parent()
	if p is Character:
		return p.player_idx
	else:
		return -1
