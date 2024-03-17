extends Control

@onready var _slot_count_label: RichTextLabel = $SlotCount
@export var machine: Machine
var _max_count: int
# Called when the node enters the scene tree for the first time.
func _ready():
	if not machine is Machine:
		return
	machine.slot_count_changed.connect(_on_count_changed)
	_max_count = machine.get_node("Slots").get_child_count()
	_on_count_changed(machine._slot_count)

func _on_count_changed(new_count) -> void:
	_slot_count_label.text = "{}/{}".format([str(new_count), str(_max_count)], "{}")
