extends Node2D
class_name  Machine

var machine_parameters # resource type

@export var _cycle_duration: float = 1.0
var _current_worker: int = 0
@export var _workers = []

var _time_per_worker: float = 1.0
var _time_to_next_worker: float = 1.0

signal has_produced # maybe this should go in the machine_parameters?

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _workers.size() <= 0 or _remaining_workers() <= 0:
		return
	_time_to_next_worker -= delta
	if _time_to_next_worker <= 0:
		_time_to_next_worker += _time_per_worker
		_workers[_current_worker].work
		_produce()
		_current_worker += 1

func _remaining_workers() -> int:
	return _workers.size() - _current_worker
	
func _produce() -> void:
	machine_parameters.produce()
	has_produced.emit()
