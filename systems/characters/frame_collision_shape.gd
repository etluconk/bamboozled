@tool
extends CollisionShape2D
class_name FrameCollisionShape

enum Type {HURTBOX, HITBOX}
@export var type := Type.HITBOX:
	set(value):
		type = value
		reset_debug_color(value)

@export_tool_button("Add Multi Frame to Index", "Callable") var do_add_multi_frame_to_index = add_multi_frame_to_index
@export_tool_button("Add Frame Before", "Callable") var do_add_frame_frame_before = add_frame_before
@export_tool_button("Add Frame After", "Callable") var do_add_frame_after = add_frame_after
@export_tool_button("Remove Me", "Callable") var do_remove_me = remove_me
@export_tool_button("Only Show This Index", "Callable") var do_only_show_this_index = only_show_this_index

var p : AnimationData

@onready var eds = EditorInterface.get_selection()

func _ready() -> void:
	p = get_parent()
	reset_debug_color(type)
	eds.selection_changed.connect(on_selection_changed)

func add_multi_frame_to_index() -> void:
	if p is AnimationData:
		pass

func add_frame_after() -> void:
	if p is AnimationData:
		var index = int(name.substr(0, 1))
		p.insert_frame(index, get_tree_order_index() + 1)

func add_frame_before() -> void:
	if p is AnimationData:
		var index = int(name.substr(0, 1))
		p.insert_frame(index, get_tree_order_index())

func remove_me() -> void:
	if p is AnimationData:
		var index = int(name.substr(0, 1))
		p.frame_data.pop_at(index)
		queue_free()
		# p.call_deffered(p.cleanup_frame_names)

func only_show_this_index() -> void:
	if p is AnimationData:
		var index = int(name.substr(0, 1))
		p.only_show_index(index)
		p.cleanup_frame_names()

func reset_debug_color(value) -> void:
	match value:
		Type.HURTBOX:
			debug_color = Color("00a4506b")
		Type.HITBOX:
			debug_color = Color("ff020b6b")

func on_selection_changed() -> void:
	var selection = EditorInterface.get_selection().get_selected_nodes()
	var index = int(name.substr(0, 1))

	if selection.size() > 0 and p is AnimationData:
		if self == selection[0] and p.frame_data.size() > index:
			only_show_this_index()

func get_tree_order_index() -> int:
	var tree_order_index = 0
	for sibling in get_parent().get_children():
		if sibling == self: return tree_order_index
		tree_order_index += 1
	return -1
