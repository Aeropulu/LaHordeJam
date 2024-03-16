extends Node2D
class_name  Machine

var machine_parameters # resource type
var _worker_scene: PackedScene = preload("res://scenes/test_character.tscn")

@export var _cycle_duration: float = 1.0
var _current_worker: int = 0
@export var _workers = []

var _time_per_worker: float = 1.0
var _time_to_next_worker: float = 1.0
var _slot_count = 1

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
		_workers[_current_worker].work()
		_produce()
		_current_worker += 1
		if _current_worker >= _workers.size():
			_current_worker = 0

func _remaining_workers() -> int:
	return _workers.size() - _current_worker
	
func _produce() -> void:
	# machine_parameters.produce()
	has_produced.emit()
	
func _add_worker(worker) -> bool:
	var slots_count = %Slots.get_child_count()
	if _workers.size() >= slots_count:
		return false
	var slot = %Slots.get_child(_workers.size())
	slot.add_child(worker)
	_workers.append(worker)
	_time_per_worker = _cycle_duration / _workers.size()
	return true


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var worker = _worker_scene.instantiate()
		_add_worker(worker)
