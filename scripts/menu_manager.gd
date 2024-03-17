extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$menu_main.visible = true
	$menu_briefing.visible = false
	$menu_config.visible = false
	$menu_debriefing.visible = false
	$menu_gameover.visible = false
	FactoryManager.day_end.connect(on_day_end)
	FactoryManager.game_over.connect(on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	$menu_main.visible = false
	$menu_briefing.visible = true


func _on_launch_config_pressed():
	$menu_briefing.visible = false
	$menu_config.visible = true
	

func _on_pointeuse_pointeuse_finished():
	$menu_config.visible = false
	
func on_day_end():
	$menu_debriefing.visible = true
	
func on_game_over():
	$menu_gameover.visible = true
