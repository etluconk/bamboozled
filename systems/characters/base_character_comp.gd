extends PlatformingBaseComponent
class_name BaseCharacterComp

var p : CharacterBody2D

func _ready() -> void:
	p = get_parent()

func _physics_process(_delta: float) -> void:
	if enabled:
		p.move_and_slide()
