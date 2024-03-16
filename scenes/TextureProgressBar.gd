extends TextureProgressBar

var global_capital = 0
var _death_effect: PackedScene = preload("res://scenes/vfx/blood_effect.tscn")
var shakingTime = 100

func generate_death(capital):
	#Create effect
	var effect = _death_effect.instantiate()
	add_child(effect)
	%Camera2D.shakingTimer = shakingTime
	#GLOBAl SCORE
	global_capital += capital

# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	max_value = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value += 1
	if value == max_value && $Timer.is_stopped():
		$Timer.start()
		generate_death(1)


func _on_timer_timeout():
	$Timer.stop()
	value = 0
