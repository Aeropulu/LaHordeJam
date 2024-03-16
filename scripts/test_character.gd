extends Node2D

@onready var _navigation_agent: NavigationAgent2D = %NavigationAgent
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var new_pos: Vector2 = event.global_position
		print(event.global_position)
		_navigation_agent.set_target_position(new_pos)
		print(_navigation_agent.is_target_reachable())
		print(_navigation_agent.target_position)
