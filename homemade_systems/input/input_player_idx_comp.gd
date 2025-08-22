extends Component
class_name InputPlayerIdxComp

var player_idx := 0

var p : Node

func _ready() -> void:
	p = get_parent()
	if p is Character:
		player_idx = p.player_idx
