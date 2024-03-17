extends Node2D

@export var day_duration: float
var machines: Array[Machine]

var slots: Array[Node2D]
var workers: Array[Michel]

var _worker_scene = preload("res://scenes/michel.tscn")
var _can_start_day: bool = true

var total_slot_count: int = 0

var current_profit := 0 : set = set_current_profit
var profit_objective := 0

var _day_duration:float = 3.0
var _remaining_day_time:float = 0.0 : set = set_remaining_day_time
signal remaining_day_time_changed(new_value)

var _current_speed_factor := 1.0 : set = set_speed_factor
var _speed_factor_increment := 0.1
signal speed_factor_changed

signal profit_changed(new_value)

signal workers_spawned
signal workers_in_place

signal day_end
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	for machine in machines:
		total_slot_count += machine._slot_count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _remaining_day_time > 0.0:
		_remaining_day_time -= delta
	
func set_current_profit(new_val):
	current_profit = new_val
	profit_changed.emit(new_val)
	
func set_speed_factor(new_val):
	_current_speed_factor = new_val
	speed_factor_changed.emit()

func set_remaining_day_time(new_val):
	_remaining_day_time = new_val
	remaining_day_time_changed.emit(new_val)

func add_machine(mach: Machine):
	machines.append(mach)

func spawn_workers(time: float):
	if not _can_start_day:
		return
		
	_can_start_day = false
	slots.clear()
	workers.clear()
	
	var worker_count := 0
	for machine in machines:
		worker_count += machine._slot_count
	var delay: float = time / worker_count
	for machine in machines:
		for i in range(machine._slot_count):
			print(machine.global_position)
			var slot = machine.get_slot(i)
			if slot is Node2D:
				slots.append(slot)
			print(slot.get_parent().global_position)
			var worker: Michel = _worker_scene.instantiate()
			workers.append(worker)
			worker.global_position = global_position
			get_tree().root.add_child(worker)
			machine._add_worker(worker)
			worker.target_slot = slot
			worker.door_pos = global_position
			worker._machine = machine
			worker.go_to_slot(time)
			worker.in_place.connect(_check_workers_in_place, CONNECT_ONE_SHOT)
			await get_tree().create_timer(delay).timeout
	workers_spawned.emit()
	if workers.size() == 0:
		return

func _check_workers_in_place():
	var all_in_place := true
	for worker in workers:
		if not worker.is_in_place:
			all_in_place = false
	if all_in_place:
		workers_in_place.emit()
		await get_tree().create_timer(0.3).timeout
		start_work()

func start_work():
	_remaining_day_time = day_duration
	for machine in machines:
		machine.work_stopped.connect(_check_all_work_stopped, CONNECT_ONE_SHOT)
		machine.start_work()
		
func _check_all_work_stopped():
	var all_stopped := true
	for machine in machines:
		if machine._is_working:
			all_stopped = false
	if all_stopped:
		send_workers_home()
		
func send_workers_home():
	if workers.size() == 0:
		_check_defeat()
		return
	for worker in workers:
		worker.gone_home.connect(_check_workers_left, CONNECT_ONE_SHOT)
		worker.go_home(0.5)
		
func _check_workers_left():
	var all_gone := true
	for worker in workers:
		if not worker.has_gone_home:
			all_gone = false
	if all_gone:
		for worker in workers:
			worker.queue_free()
		workers.clear()
		_check_defeat()
		
func _check_defeat():
	if current_profit < profit_objective:
		game_over.emit()
		pass
	_can_start_day = true
	day_end.emit()
	
func _on_machine_profit():
	set_current_profit(current_profit + 100)
	
func _on_machine_time_accel():
	_current_speed_factor += _speed_factor_increment
	
func _on_machine_crush_worker():
	pass

func _on_button_pressed():
	spawn_workers(0.5)
