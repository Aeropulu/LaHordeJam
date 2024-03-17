extends Camera2D

var _signal = 1
var frequency = 1.0
var shakingDuration = 30
var shakingTimer = 0

func _ready():
	pass # Replace with function body.

func _process(delta):
	if shakingTimer > 0 :#&& (global_position.y == 432 || global_position.y == 0):
		if fmod(shakingTimer, frequency) == 0:
			var horizontalAmplitude = randf_range(2.0,5.0)
			var verticalAmplitude = randf_range(2.0,5.0)
			_signal *= -1
			set_offset(Vector2(horizontalAmplitude*_signal + 960,verticalAmplitude*_signal + 540))
		shakingTimer -= 1
	else:
		set_offset(Vector2(960,540))
