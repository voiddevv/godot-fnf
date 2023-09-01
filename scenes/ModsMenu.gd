extends CanvasLayer

@onready var menu_items:Node2D = $MenuItems
@onready var text_template:FreeplayAlphabet = $__TemplateItem__
@onready var contributor_template:Panel = $Contributors/ContributorTemplate
@onready var contributor_list:VBoxContainer = $Contributors/ScrollContainer/VBoxContainer

var cur_selected:int = 0
var mod_list:PackedStringArray = []
var mod_configs:Array[ModConfig] = []

func _ready() -> void:
	if OS.is_debug_build():
		queue_free()
		return
	
	ModManager._ready()
	get_window().files_dropped.connect(_on_files_dropped)
	get_tree().paused = true
	
	ModManager._ready()
	
	mod_list = ModManager.list_all_mods()
	mod_list.insert(0, ModManager.FALLBACK_MOD)
	
	var titles:Array = []
	
	for i in mod_list.size():
		var name:String = mod_list[i]
		
		# switch to the mod to allow us to
		# load the modded mod config scene
		var success:bool = ModManager.switch_mod(name.get_basename().replace(ModManager.MOD_FOLDER, ""))
		if not success: continue
		
		var config:ModConfig = load("res://mod_data/config.tscn").instantiate()
		
		var mod_title:FreeplayAlphabet = text_template.duplicate()
		var icon:Sprite2D = mod_title.get_node("Icon")
		mod_title.text = config.title
		icon.texture = config.icon
		mod_title.position = Vector2(100, (70 * i) + 30)
		mod_title.x_add += 100
		mod_title.visible = true
		mod_title.is_menu_item = true
		mod_title.target_y = i
		mod_title.is_template = false
		menu_items.add_child(mod_title)
		mod_configs.append(config)
	
	# switch back to current mod to avoid conflicts or something
	ModManager.switch_mod(SettingsAPI.get_setting("current mod"))
	
	change_selection()
	
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, mod_list.size())
	
	for i in menu_items.get_child_count():
		var item:FreeplayAlphabet = menu_items.get_child(i)
		item.target_y = i - cur_selected
		item.modulate.a = 1.0 if cur_selected == i else 0.6
		
	for child in contributor_list.get_children():
		child.queue_free()
		
	for contributor in mod_configs[cur_selected].contributors.contributors:
		var template:Panel = contributor_template.duplicate()
		template.get_node("Icon").texture = contributor.icon
		template.get_node("Label").text = contributor.name
		template.visible = true
		
		contributor_list.add_child(template)
		
	Audio.play_sound("scrollMenu")
	
func _process(delta):
	get_tree().paused = true
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		Audio.stop_music()
		Audio.play_sound("confirmMenu")
		
		SettingsAPI.set_setting("current mod", mod_list[cur_selected].replace(ModManager.MOD_FOLDER, "").replace(".pck", ""))
		SettingsAPI.flush()
		ModManager.switch_mod(SettingsAPI.get_setting("current mod"))
		
		Global.reset_scene(true)
		queue_free()
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false
		Audio.play_sound("cancelMenu")
		queue_free()

func _on_show_item_pressed(name:String):
	match name:
		"Show Description":
			$Description/ScrollContainer/Label.text = mod_configs[cur_selected].description
			$Description.visible = !$Description.visible
			$"FumnyStrip/Show Description".text = "Hide Description" if $Description.visible else "Show Description"
			
		"Show Contributors":
			$Contributors.visible = !$Contributors.visible
			$"FumnyStrip/Show Contributors".text = "Hide Contributors" if $Contributors.visible else "Show Contributors"

		"Open Mods Folder":
			OS.shell_open(ProjectSettings.globalize_path(ModManager.MOD_FOLDER))

func _on_files_dropped(mods:PackedStringArray) -> void:
	for mod_path in mods:
		DirAccess.copy_absolute(mod_path, 'user://mods/' + mod_path.get_file())
	
	queue_free()
	get_parent().add_child(load("res://scenes/ModsMenu.tscn").instantiate())
