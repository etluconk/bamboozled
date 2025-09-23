@tool
extends Area2D
class_name MoveFrameArea

signal on_on_area_entered

enum AreaType {HITBOX, HURTBOX}
@export var area_type = AreaType.HITBOX:
	set(value):
		area_type = value
		apply_area_type(value)

func _ready() -> void:
	if Engine.is_editor_hint():
		apply_area_type(area_type)
		child_entered_tree.connect(on_child_entered_tree)
	area_entered.connect(on_area_entered)

func apply_area_type(value) -> void:
	match value:
		AreaType.HURTBOX:
			for child in get_children():
				if child is CollisionShape2D:
					child.debug_color = Color("00a4506b")
			collision_layer = 0
			collision_mask = 0
			set_collision_layer_value(10, true)
			set_collision_mask_value(11, true)
		AreaType.HITBOX:
			for child in get_children():
				if child is CollisionShape2D:
					child.debug_color = Color("ff020b6b")
			collision_layer = 0
			collision_mask = 0
			set_collision_layer_value(11, true)
			set_collision_mask_value(10, true)

func on_child_entered_tree(_node : Node) -> void:
	apply_area_type(area_type)

func on_area_entered(area : Area2D):
	on_on_area_entered.emit(self, area)

func set_activated(activated : bool):
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = !activated

func get_move_frame() -> MoveFrame:
	if get_parent() is MoveFrame:
		return get_parent()
	else:
		return null
