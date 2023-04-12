extends Control
class_name TrackButton

signal edit
signal delete
signal play
signal watch
signal include

const trackloader_scn = preload("res://scenes/track.tscn")

@export var button: Button

var editable := false # can edit
var dev := false # can edit main tracks and can move tracks into main
var builtin := false # added to tracks.cfg

func _ready() -> void:
	%edit.visible = editable || dev
	%delete.visible = editable || dev
	%include.visible = dev && !builtin

func init(t: TrackResource, g: GhostData) -> void:
	%name.text = t.name
	t.name_changed.connect(func(n: String): %name.text = n)
	if g == null:
		%watch.hide()
		%time.text = "no time set"
	else:
		%time.text = GameTimer.format_precise(g.time)
	builtin = t.builtin
	var tex := Thumbnail._load(Globals.THUMBS % t.name, Thumbnail.hash_b(t.bytes()), false)
	if tex == null:
		tex = await mkthumb(t)
	(%thumb as TextureRect).texture = ImageTexture.create_from_image(tex)
	# update thumb on savea
	t.saved.connect(func(): print("update thumb!"); (%thumb as TextureRect).texture = ImageTexture.create_from_image(await mkthumb(t)))

func mkthumb(t: TrackResource) -> Image:
	var p: String = Globals.THUMBS % t.name
	var trackloader: TrackLoader = trackloader_scn.instantiate()
	trackloader.track = t
	trackloader.add_child(IntroCam.new(t, null))
	var tex := await Thumbnail.create_thumb(self, trackloader, Vector2i(450, 200))
	var e := Thumbnail.save(tex, p, Thumbnail.hash_b(t.bytes()))
	if e != OK:
		push_error("saving thumbnail failed with error %d" % e)
	return tex


func _on_delete_pressed() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.min_size = Vector2(250, 100)
	dialog.exclusive = true
	dialog.title = "Are you sure!"
	dialog.dialog_text = "Delete track!"
	dialog.cancel_button_text = "no way"
	dialog.ok_button_text = "yea sure"
	dialog.dialog_hide_on_ok = false
	dialog.dialog_close_on_escape = false
	dialog.unresizable = true
	dialog.popup_window = true
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.add_theme_stylebox_override("panel", preload("res://ui/panel_dark.stylebox"))
	add_child(dialog)
	dialog.show()
	dialog.confirmed.connect(emit_signal.bind(&"delete"))
	dialog.canceled.connect(dialog.queue_free)
	dialog.confirmed.connect(queue_free)

