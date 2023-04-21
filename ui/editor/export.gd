extends Button
class_name EditorMarshalling

@onready var editor: TrackEditor = owner

func _pressed() -> void:
	var enc := EditorMarshalling.td2s(editor.get_trackdata())
	print_rich("exporting to `[code]%s[/code]`" % enc) # for funny clipboard shenanigans
	DisplayServer.clipboard_set(enc)

static func td2s(td: TrackResource) -> String:
	var buf := var_to_bytes(td.to_d())
	var buf_c := buf.compress(FileAccess.COMPRESSION_DEFLATE)
	return "%s|%s" % [Marshalls.raw_to_base64(buf_c), String.num_uint64(buf.size(), 16)]

static func s2td(s: String) -> TrackResource:
	var split := s.lstrip('`').rstrip('`').strip_edges().split("|", false, 1)
	if not split.size() || split[0].length() < 100:
		return null
	var buf := Marshalls.base64_to_raw(split[0])
	if buf.size() < 100:
		return
	var decompressed: PackedByteArray = []
	if split.size() > 1 and split[1].length() < 20 and split[1].hex_to_int() > 0:
		decompressed = buf.decompress(split[1].hex_to_int(), FileAccess.COMPRESSION_DEFLATE)
	else: # size unknown!
		decompressed = buf.decompress_dynamic(51200, FileAccess.COMPRESSION_DEFLATE)
	if decompressed.size() < 4:
		return null
	var d = bytes_to_var(decompressed)
	if d is Dictionary:
		return TrackResource.from_d(d)
	return null
