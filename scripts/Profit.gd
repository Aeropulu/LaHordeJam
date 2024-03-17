extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	FactoryManager.profit_changed.connect(on_profit_change)
	
func on_profit_change(new_profit):
	$profitLabel.text = str(new_profit)
	$AnimationPlayer.play("profitIncrease")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
