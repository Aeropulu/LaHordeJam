extends Node2D

@export var day_duration: float
@export var machines: Array[Machine]

var slots: Array[Node2D]
var workers: Array[Michel]

var _worker_scene = preload("res://scenes/michel.tscn")
var _can_start_day: bool = true

signal workers_spawned
signal workers_in_place

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
			var slot = machine.get_slot(i)
			if slot is Node2D:
				slots.append(slot)
			var worker: Michel = _worker_scene.instantiate()
			workers.append(worker)
			worker.global_position = global_position
			get_tree().root.add_child(worker)
			machine._add_worker(worker)
			worker.target_slot = slot
			worker.door_pos = global_position
			worker.go_to_slot(delay * 2)
			worker.in_place.connect(_check_workers_in_place, CONNECT_ONE_SHOT)
			await get_tree().create_timer(delay).timeout
	workers_spawned.emit()

func _check_workers_in_place():
	var all_in_place := true
	for worker in workers:
		if not worker.is_in_place:
			all_in_place = false
	if all_in_place:
		workers_in_place.emit()
		start_work()

func start_work():
	for machine in machines:
		machine.work_stopped.connect(_check_all_work_stopped, CONNECT_ONE_SHOT)
		machine.start_work(day_duration)
		
func _check_all_work_stopped():
	var all_stopped := true
	for machine in machines:
		if machine._is_working:
			all_stopped = false
	if all_stopped:
		send_workers_home()
		
func send_workers_home():
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
		_can_start_day = true

func _on_button_pressed():
	spawn_workers(0.5)
