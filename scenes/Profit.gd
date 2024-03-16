extends Node2D

var global_profit = 1000

var _profit_effect: PackedScene = preload("res://scenes/vfx/profit_effect.tscn")

func generate_profit(profit):
	#Create effect
	var dollar = _profit_effect.instantiate()
	add_child(dollar)
	#GLOBAl SCORE
	global_profit += profit
	$profitLabel.text = str(global_profit)

# Called when the node enters the scene tree for the first time.
func _ready():
	$profitLabel.text = str(global_profit)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		generate_profit(1000)
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
