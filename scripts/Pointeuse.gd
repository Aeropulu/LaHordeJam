extends Node2D

signal pointeuse_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$pointer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func launch_journey():
	$pointer.visible = true
	$pointer.play()
	$pointerSFX.play()
	await $pointerSFX.finished
	$ding.play()
	await $ding.finished
	pointeuse_finished.emit()
	FactoryManager._on_button_pressed()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		launch_journey()


func _on_pointer_animation_finished():
	$pointer.visible = false
