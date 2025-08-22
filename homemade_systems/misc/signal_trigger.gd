extends Component
class_name SignalTriggerComp

var p : Node

@export var node_recieving_from : Node
@export var signal_name : String
@export var callable_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p = get_parent()
	node_recieving_from.connect(signal_name, trigger)

func trigger() -> void:
	p.call(callable_name)
