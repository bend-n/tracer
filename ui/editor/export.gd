extends Button
class_name EditorMarshalling

@onready var editor: TrackEditor = owner

func _pressed() -> void:
	var enc := EditorMarshalling.td2s(editor.to_trackdata())
	print_rich("exporting %s to `[code]%s[/code]`" % [editor.n, enc]) # for funny clipboard shenanigans
	DisplayServer.clipboard_set(enc)

static func td2s(td: TrackResource) -> String:
	var buf := var_to_bytes(td.to_d())
	var buf_c := buf.compress(FileAccess.COMPRESSION_DEFLATE)
	return "%s|%s" % [Marshalls.raw_to_base64(buf_c), int2hex(buf.size())]

static func int2hex(num: int) -> String:
	var s := "       "
	for i in range(7, 0, -1):
		var digit := num & 0x0F
		var ch := digit + 48
		if ch > 57:
			ch += 7
		s[i-1] = char(ch)
		num >>= 4
		i -= 1
	s = s.lstrip('0')
	return s

static func s2td(s: String) -> TrackResource:
	var split := s.lstrip('`').rstrip('`').strip_edges().split("|", false, 1)
	if not split.size():
		return null
	var buf := Marshalls.base64_to_raw(split[0])
	var decompressed: PackedByteArray
	if split.size() > 1:
		var buffer_s := split[1].hex_to_int()
		decompressed = buf.decompress(buffer_s, FileAccess.COMPRESSION_DEFLATE)
	else: # size unknown!
		decompressed = buf.decompress_dynamic(51200, FileAccess.COMPRESSION_DEFLATE)
	var d = bytes_to_var(decompressed)
	if d is Dictionary:
		return TrackResource.from_d(bytes_to_var(decompressed))
	else:
		return
