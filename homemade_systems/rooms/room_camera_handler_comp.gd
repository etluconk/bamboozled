extends Component
class_name RoomCameraHandlerComp

var p : CharacterBody2D

@export var room_camera : RoomCamera
@export var horizontal_movement_comp : HorizontalMovementComp
@export var gravity_comp : GravityComp
@export var wall_jump_comp : WallJumpComp
@export var jump_comp : JumpComp
@export var platforming_comp : Component
@export var animated_sprite : AnimatedSprite2D
@export var animation_player : AnimationPlayer

func _ready() -> void:
	p = get_parent()
	process_priority = 5

func _process(_delta: float) -> void:
	if enabled:
		if room_camera.is_transitioning():
			horizontal_movement_comp.enabled = false
			gravity_comp.enabled = false
			wall_jump_comp.enabled = false
			jump_comp.enabled = false
			platforming_comp.enabled = false

			if animated_sprite != null:
				animated_sprite.speed_scale = 0.2
			if animation_player != null:
				animation_player.speed_scale = 0.2
		else:
			horizontal_movement_comp.enabled = true
			gravity_comp.enabled = true
			wall_jump_comp.enabled = true
			jump_comp.enabled = true
			platforming_comp.enabled = true

			if animated_sprite != null:
				animated_sprite.speed_scale = 1
			if animation_player != null:
				animation_player.speed_scale = 1
