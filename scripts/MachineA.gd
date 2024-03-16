extends Area2D

var machine_cadence: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func increaseCadence():
	machine_cadence += 0.1
	$AnimatedSprite2D.speed_scale = machine_cadence


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("clique_gauche"):
		increaseCadence()
