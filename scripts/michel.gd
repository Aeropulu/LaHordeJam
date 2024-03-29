extends CharacterBody2D
class_name Michel

var working: bool = false

var target_slot: Node2D
var door_pos: Vector2

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_in_place:bool = false
var has_gone_home:bool = false

var _machine: Machine

var is_dragging:bool = false
var mouse_cursor_grab = preload("res://assets/sprites/cursor/cursor_grab.png")
var mouse_cursor_point = preload("res://assets/sprites/cursor/cursor_point.png")
var _is_crushed := false

signal in_place
signal gone_home

func work():
	if _machine.work_effect is PackedScene:
		var effect = _machine.work_effect.instantiate()
		if effect is Node2D:
			effect.global_position = global_position
		get_tree().root.add_child(effect)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()
		Input.set_custom_mouse_cursor(mouse_cursor_grab)
		$Sprite2D.visible = false
		$AnimatedSprite2D.visible = false
	else:
		if working:
			$Sprite2D.visible = false
			$AnimatedSprite2D.visible = true
			if _machine is Machine:
				$AnimatedSprite2D.speed_scale = 1 / _machine._cycle_duration
		else:
			$Sprite2D.visible = true
			$AnimatedSprite2D.visible = false
		# Add the gravity.
		#if not is_on_floor():
			#velocity.y += gravity * delta
	#
		## Handle jump.
		#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			#velocity.y = JUMP_VELOCITY
			#
		var directionY = Input.get_axis("ui_up", "ui_down")
		if directionY:
			velocity.y = directionY * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if velocity.x != 0 || velocity.y != 0:
			$AnimationPlayer.play("walking")
			
		if $AnimationPlayer.is_playing() && velocity == Vector2(0,0):
			$AnimationPlayer.stop()
			## working = true

		move_and_slide()

func go_to_slot(time: float):
	await get_tree().physics_frame
	if not target_slot is Node2D:
		return
	var tween = get_tree().create_tween()
	var michel: Michel = self
	tween.tween_property(michel, "global_position", target_slot.global_position, time)
	await tween.finished
	is_in_place = true
	in_place.emit()
	
func go_home(time: float):
	if _is_crushed:
		return
	var tween = get_tree().create_tween()
	var michel: Michel = self
	tween.tween_property(michel, "global_position", door_pos, time)
	await tween.finished
	has_gone_home = true
	gone_home.emit()

func start_work():
	working = true
	
func stop_work():
	working = false


func begin_drag():
	is_dragging = true
	$drag.visible = true
	
func end_drag():
	Input.set_custom_mouse_cursor(mouse_cursor_point)
	is_dragging = false
	$drag.visible = false
	_check_broyeuse()
	if target_slot is Node2D:
		go_to_slot(0.3)
	
func _check_broyeuse():
	var michel_area: Area2D = $Area2D
	for area in michel_area.get_overlapping_areas():
		var machine = area.get_parent()
		if machine is Machine and machine.is_broyeuse():
			has_gone_home = true
			_is_crushed = true
			target_slot = null
			_machine._remove_worker(self)
			_machine = machine
			machine._add_worker(self)
			machine.start_work()
			machine._produce()
			machine.on_crush_worker.emit()
			FactoryManager.workers.erase(self)
			queue_free()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			begin_drag()
		else:
			end_drag()
