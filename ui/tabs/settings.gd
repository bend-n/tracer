extends Control
class_name SettingsSaver

# utility
const UTIL = "utility"
var countdown_step_length: float = 1.0

# graphical
const GRAPHIC = "graphics"
var viewport_scale: float = 100.0
var camera_fov: float = 75.0


# trying the [ConfigFile] class out instead of the usual var2str/str2var with dict
var cfg := ConfigFile.new()

@onready var nodes := {
	"countdown_step_length" = %countdown_step,
	"camera_fov" = %camera_fov,
	"viewport_scale" = %viewport_scale
}

func _load():
	var err := cfg.load(Globals.SETTINGS)
	if err != OK: # no file
		_save() # make it
		return
	getv(UTIL, "countdown_step_length", 0.05, 30)
	getv(GRAPHIC, "camera_fov", 1, 179)
	getv(GRAPHIC, "viewport_scale", 1, 100)

func getv(section: String, variable: String, p_min: float, p_max: float):
	if cfg.has_section_key(section, variable):
		# i can use self[variable] but i think set() and get() is more readable
		var value := clampf(cfg.get_value(section, variable, get(variable)), p_min, p_max)
		set(variable, value)
		if nodes[variable] is SpinBox:
			nodes[variable].value = value
	else:
		cfg.set_value(section, variable, get(variable))

func setv(section: String, variable: String):
	cfg.set_value(section, variable, get(variable))

func _save():
	setv(UTIL, "countdown_step_length")
	setv(GRAPHIC, "camera_fov")
	setv(GRAPHIC, "viewport_scale")
	cfg.save(Globals.SETTINGS)

func _connect():
	for variable in nodes:
		(nodes[variable] as SpinBox).value_changed.connect(_spinner_change.bind(variable))

func _ready() -> void:
	_load()
	_connect()
	Globals.cfg = cfg

func _spinner_change(value: float, variable: String) -> void:
	set(variable, value)
	_save()
