extends Node2D
class_name  Machine

enum Machinetype { PROFIT, TIME, BROYEUSE, MULTIPLIER }
@export var machine_type: Machinetype
var _worker_scene: PackedScene = preload("res://scenes/michel.tscn")

@export var work_effect: PackedScene

@export var _base_cycle_duration := 1.0
var _cycle_duration: float = 1.0
var _current_worker: int = 0
var _workers: Array[Michel]

var _time_per_worker: float = 1.0
var _time_to_next_worker: float = 1.0

@export var _slot_count = 1
signal slot_count_changed(new_count)
signal slot_added
signal slot_removed
signal slot_change_error

var _is_working:bool = false

signal on_profit
signal on_time_accel
signal on_crush_worker
signal on_multiplier_increase

signal workers_in_place
signal work_started
signal work_stopped

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.speed_scale = 0
	FactoryManager.add_machine(self)
	on_profit.connect(FactoryManager._on_machine_profit)
	on_time_accel.connect(FactoryManager._on_machine_time_accel)
	on_crush_worker.connect(FactoryManager._on_machine_crush_worker)
	on_multiplier_increase.connect(FactoryManager._on_machine_multiplier_increase)
	FactoryManager.speed_factor_changed.connect(_on_speed_factor_changed)
	_cycle_duration = _base_cycle_duration / FactoryManager._current_speed_factor

func _on_speed_factor_changed():
	_cycle_duration = _base_cycle_duration / FactoryManager._current_speed_factor
	if (_workers.size() != 0):
		_time_per_worker = _cycle_duration / _workers.size()
	if _is_working:
		$AnimatedSprite2D.speed_scale = FactoryManager._current_speed_factor

func _set_cycle_duration(new_value):
	if (_cycle_duration != 0):
		var ratio: float = new_value / _base_cycle_duration
		_time_to_next_worker *= ratio
	_cycle_duration = new_value
	if (_workers.size() != 0):
		_time_per_worker = _cycle_duration / _workers.size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _is_working:
		if machine_type == Machinetype.BROYEUSE:
			_process_broyeuse(delta)
		else:
			_process_cycle(delta)
	
func start_work():
	if _workers.size() == 0 and machine_type != Machinetype.BROYEUSE:
		return
	_is_working = true
	for worker in _workers:
		worker.start_work()
	$AnimatedSprite2D.speed_scale = FactoryManager._current_speed_factor
		
func stop_work():
	_is_working = false
	for worker in _workers:
		if worker != null:
			worker.stop_work()
	work_stopped.emit()
	_workers.clear()
	$AnimatedSprite2D.speed_scale = 0
	
func _process_cycle(delta):
	if _workers.size() <= 0 or _remaining_workers() <= 0:
		return
	_time_to_next_worker -= delta
	# print(_time_per_worker)
	if _time_to_next_worker <= 0:
		_time_to_next_worker += _time_per_worker
		_workers[_current_worker].work()
		_produce()
		_current_worker += 1
		if _current_worker >= _workers.size():
			_current_worker = 0
			if (FactoryManager._remaining_day_time < _cycle_duration):
				# No time to work more today lads
				stop_work()

func _process_broyeuse(delta):
	_time_to_next_worker -= delta
	if _time_to_next_worker <= 0.0:
		_time_to_next_worker = 0.0
		stop_work()
		FactoryManager._check_workers_left()

func _remaining_workers() -> int:
	return _workers.size() - _current_worker
	
func _produce() -> void:
	match machine_type:
		Machinetype.PROFIT:
			on_profit.emit()
		Machinetype.TIME:
			on_time_accel.emit()
		Machinetype.BROYEUSE:
			on_crush_worker.emit()
		Machinetype.MULTIPLIER:
			on_multiplier_increase.emit()
	
func _add_worker(worker) -> void:
	_workers.append(worker)
	_time_per_worker = _cycle_duration / _workers.size()


func _remove_worker(worker) -> void:
	_workers.erase(worker)
	if _workers.size() <= 0:
		call_deferred("stop_work")
	else:
		_time_per_worker = _cycle_duration / _workers.size()
	pass

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if not FactoryManager._can_start_day:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & 2 == 2:
			remove_slot()
		else:
			add_slot()
			
func set_slot_count(number:int):
	number = clampi(number, 0, $Slots.get_child_count())
	if number != _slot_count:
		_slot_count = number
		slot_count_changed.emit(number)
	else:
		slot_change_error.emit()

func get_slot(index: int) -> Node2D:
	if index <= min(_slot_count, $Slots.get_child_count()):
		return $Slots.get_child(index)
	else:
		return null

func add_slot() -> void:
	if _slot_count < $Slots.get_child_count():
		set_slot_count(_slot_count + 1)
		slot_added.emit()
	else:
		slot_change_error.emit()

func remove_slot() -> void:
	if _slot_count == 0:
		slot_change_error.emit()
		return
	set_slot_count(_slot_count - 1)

func is_broyeuse() -> bool:
	return machine_type == Machinetype.BROYEUSE
