extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	FactoryManager.remaining_day_time_changed.connect(on_update)

func on_update(new_value):
	$fleche.global_rotation_degrees = new_value*-360

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
