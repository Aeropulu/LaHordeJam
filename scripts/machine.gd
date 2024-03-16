extends Node2D
class_name  Machine

enum Machinetype { PROFIT, TIME, BROYEUSE }
@export var machine_type: Machinetype
var _worker_scene: PackedScene = preload("res://scenes/test_character.tscn")

@export var _cycle_duration: float = 1.0 : set = _set_cycle_duration
var _current_worker: int = 0
@export var _workers = []

var _time_per_worker: float = 1.0
var _time_to_next_worker: float = 1.0
@export var _slot_count = 1

signal on_profit
signal on_time_accel
signal on_crush_worker

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_cycle_duration(new_value):
	if (_cycle_duration != 0):
		var ratio: float = new_value / _cycle_duration
		_time_to_next_worker *= ratio
	_cycle_duration = new_value
	if (_workers.size() != 0):
		_time_per_worker = _cycle_duration / _workers.size()
	$AnimatedSprite2D.speed_scale = 1.0 / _cycle_duration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _check_workers_in_place(delta):
		_process_cycle(delta)
	
func _check_workers_in_place(delta) -> bool:
	var all_in_place: bool = true
	for i in range(min(_slot_count, _workers.size())):
		var worker = _workers[i]
		var slot = %Slots.get_child(i)
		var is_in_place = worker.global_position.distance_squared_to(slot.global_position) < 5
		all_in_place = all_in_place and is_in_place
		if not is_in_place:
			worker.global_position = worker.global_position.move_toward(slot.global_position, delta * 500)
	return all_in_place
	
func _process_cycle(delta):
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
	match machine_type:
		Machinetype.PROFIT:
			print("PROFIT")
			on_profit.emit()
		Machinetype.TIME:
			print("GO FAST")
			on_time_accel.emit()
		Machinetype.BROYEUSE:
			print("NOM NOM NOM")
			on_crush_worker.emit()
	
func _add_worker(worker) -> bool:
	var slots_count = %Slots.get_child_count()
	if _workers.size() >= slots_count:
		return false
	var slot = %Slots.get_child(_workers.size())
	slot.add_child(worker)
	_workers.append(worker)
	_time_per_worker = _cycle_duration / _workers.size()
	return true


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & 2 == 2:
			_set_cycle_duration(_cycle_duration * 0.9)
			return
		var worker = _worker_scene.instantiate()
		_add_worker(worker)
