extends Node2D

@onready var _navigation_agent: NavigationAgent2D = %NavigationAgent
var particles_scene = preload("res://scenes/Particles/work_ping.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func work():
	add_child(particles_scene.instantiate())
