extends Node2D

@export var machines: Array[Machine]
var _worker_scene = preload("res://scenes/test_character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("spawn_workers")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_workers():
	for machine in machines:
		for i in range(machine._slot_count):
			var worker = _worker_scene.instantiate()
			worker.global_position = global_position
			get_tree().root.add_child(worker)
			machine._add_worker(worker)
			await get_tree().create_timer(0.4).timeout
