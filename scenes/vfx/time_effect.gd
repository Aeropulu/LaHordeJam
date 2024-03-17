extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$profitSFX.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D/hand.global_rotation_degrees -= 3


func _on_animation_player_animation_finished(anim_name):
	queue_free()
