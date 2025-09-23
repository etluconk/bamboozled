extends Resource
class_name StateProperties

@export_group("Self")
@export var locked : bool = false
@export var horizontal_dir_locked : bool = false

@export_group("Attacking")
@export var attack : bool = false
@export var knockback_vector : Vector2 = Vector2.ZERO
@export var hitstun_knockback_frames : int = 1
