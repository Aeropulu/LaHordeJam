extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$broyeuse.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	$crie.play()
	$blood.emitting = true


func _on_blood_finished():
	queue_free()
