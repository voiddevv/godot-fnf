extends Node2D
class_name OptionsMenu

@onready var strum_line:StrumLine = $StrumLine
@onready var note_group:Node2D = $Notes
@onready var note_template:Note = $NoteTemplate
@onready var ms_display:Label = $MSDisplay
var ms_tween:Tween

@onready var downscroll_checkbox:CheckBox = $TabContainer/Gameplay/Downscroll

var dir_shit:int = 0
var spawn_timer:float = 0.0

func _ready():
	Audio.play_music("freakyMenu")
	Conductor.change_bpm(Audio.music.stream.bpm)
	Conductor.position = 0.0
	
	# lazy way to make strumline pop up when the scene loads
	_on_gameplay_checkbox_pressed("Downscroll")
	
	Ranking.judgements = Ranking.default_judgements.duplicate(true)
	Ranking.ranks = Ranking.default_ranks.duplicate(true)
	
func spawn_note(time:float):
	var new_note:Note = note_template.duplicate()
	new_note.time = time
	new_note.direction = dir_shit % 4
	new_note.visible = true
	note_group.add_child(new_note)
	return new_note
	
func _process(delta):
	Conductor.position += delta * 1000.0
	
	var scroll_speed:float = 1.0 if SettingsAPI.get_setting("scroll speed") <= 0 else SettingsAPI.get_setting("scroll speed")
	
	if Conductor.position >= 0:
		spawn_timer += delta
	
	if spawn_timer >= 0.5:
		spawn_note(Conductor.position + (1500 / scroll_speed))
		
		spawn_timer = 0.0
		dir_shit += 1
		
	for i in note_group.get_child_count():
		var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
		var note:Note = note_group.get_child(i)
		var strum_pos:Vector2 = strum_line.get_child(note.direction).global_position
		note.position.x = strum_pos.x
		note.position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.position - note.time) * scroll_speed)
	
		if note.can_be_hit and Input.is_action_just_pressed(strum_line.controls[note.direction]):
			var receptor:Receptor = strum_line.get_child(note.direction)
			receptor.play_anim("confirm")
			
			if SettingsAPI.get_setting("show ms on note hit"):
				var note_diff:float = (note.time - Conductor.position) / Conductor.rate
				var judgement:Judgement = Ranking.judgement_from_time(note_diff)
				
				ms_display.modulate = judgement.color
				ms_display.text = str(note_diff).pad_decimals(2)+"ms"
				ms_display.position.x = strum_line.position.x - (ms_display.size.x * 0.5)
				ms_display.position.y = strum_line.position.y - (ms_display.size.y * 0.5) - (110.0 * -downscroll_mult)
				ms_display.visible = true
				
				if ms_tween != null:
					ms_tween.stop()
				
				ms_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
				ms_tween.tween_property(ms_display, "position:y", ms_display.position.y + 10.0, 0.3)
				ms_tween.tween_property(ms_display, "modulate:a", 0.0, 0.3).set_delay(0.5)
			
			note.queue_free()
	
		if note.time <= Conductor.position - (500 / scroll_speed):
			note.queue_free()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sound("cancelMenu")
		
		var exit_scene_path:String = Global.scene_arguments["options_menu"].exit_scene_path
		
		if len(exit_scene_path) > 0:
			Global.switch_scene(exit_scene_path)
		else:
			Global.switch_scene("res://scenes/MainMenu.tscn")
			
		Global.scene_arguments["options_menu"].exit_scene_path = ""

func _on_tool_button_pressed(name:String):
	match name:
		"XML Converter":
			Global.switch_scene("res://tools/XML Converter.tscn")
		"TXT Converter":
			Global.switch_scene("res://tools/TXT Converter.tscn")
		"Adobe Json Converter":
			Global.switch_scene("res://tools/Adobe Json Converter.tscn")

func _on_gameplay_checkbox_pressed(name:String):
	match name:
		"Downscroll":
			var tween:Tween = create_tween()
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(strum_line, "position:y", 587.0 if downscroll_checkbox.button_pressed else 115.0, 0.5)
