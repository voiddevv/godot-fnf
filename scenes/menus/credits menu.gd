extends Node2D
@onready var items = $items
@onready var template = $Template

@export var data : CreditsList

func _ready():
	var index:int = 0
	for i in data.data:
		var _temp = template.duplicate()

		index += 1
		var pan:Panel = _temp.get_child(0) as Panel
		var flat_box:StyleBoxFlat = pan.get_theme_stylebox("panel").duplicate()
		var spr:Sprite2D = pan.get_node("icon")
		spr.texture = i.icon
		spr.hframes = 2
		flat_box.bg_color = i.bgcolor
		pan.add_theme_stylebox_override("panel",flat_box)
		items.add_child(_temp)
		_temp.position.y += 180 * index
		print(i.icon)
	pass
