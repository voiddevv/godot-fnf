extends CanvasLayer

var show_extra_info:bool = false
var _vram_peak:float = 0.0

var _update_timer:float = 0.0


enum FPS_TEXT_TYPE{
	NORMAL_TEXT = 0,
	EXTRA_TEXT = 1
}

@onready var fps_label:Label = $FPSLabel
var default_texts:Dictionary = {
	"FPS - ": Engine.get_frames_per_second,
}
var extra_texts:Dictionary = {
	"VRAM": func() : return String.humanize_size(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)),
	"RAM": func() : return String.humanize_size(OS.get_static_memory_usage()),
	"OBJECTS": func() : return Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
	"AUDIO LATENCY": func() : return "%s MS" % (snapped(Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY) *1000,1.01))
}

func add_text(type:FPS_TEXT_TYPE,text:String,callable:Callable):
	match type:
		FPS_TEXT_TYPE.NORMAL_TEXT:
			default_texts[text] = callable
		FPS_TEXT_TYPE.EXTRA_TEXT:
			extra_texts[text] = callable
			pass
	pass

func _ready():
	update_text()

func _physics_process(delta):
	visible = SettingsAPI.get_setting("fps counter")
	
	if Input.is_action_just_pressed("show_extra_info"):
		show_extra_info = not show_extra_info
		update_text()
		
	_update_timer += delta
	
	if _update_timer >= 1.0:
		_update_timer = 0.0
		update_text()
		
func update_text():
	fps_label.text = "FPS - %s\n" %default_texts.values()[0].call()
	
	if OS.is_debug_build() and show_extra_info:
		
		var vram:float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
		var ram:float = Performance.get_monitor(Performance.MEMORY_STATIC)
		for i in extra_texts:
			var v = extra_texts.get(i)
			fps_label.text += "%s - %s\n" %[i,v.call()]

