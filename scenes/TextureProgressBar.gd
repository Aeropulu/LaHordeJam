extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	max_value = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value += 1
	if value == max_value && $Timer.is_stopped():
		$Timer.start()


func _on_timer_timeout():
	$Timer.stop()
	value = 0
