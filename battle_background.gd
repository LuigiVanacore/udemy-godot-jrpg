# res://utils/CameraFillSprite2D.gd
extends Sprite2D

@export var camera_path: NodePath
@export var cover: bool = true                      # true: riempi (può ritagliare), false: mostra tutto
@export var extra_padding: Vector2 = Vector2.ZERO   # margine world ai bordi (es. 8,8)

var _cam: Camera2D = null
var _last_zoom: Vector2 = Vector2.ONE
var _last_vp: Vector2 = Vector2.ZERO

func _ready() -> void:
	_cam = get_node_or_null(camera_path) as Camera2D


	centered = true
	offset = Vector2.ZERO
	z_index = -1000

	get_viewport().size_changed.connect(_fit_to_camera)
	_fit_to_camera()
	global_position = _cam.global_position

func _process(_delta: float) -> void:

	# se cambia zoom o viewport, riadatta
	var vp: Vector2 = get_viewport_rect().size
	if _cam.zoom != _last_zoom or vp != _last_vp:
		_fit_to_camera()

func _fit_to_camera() -> void:
	if texture == null or _cam == null:
		return

	var vp: Vector2 = get_viewport_rect().size
	var zoom: Vector2 = _cam.zoom
	# area visibile in world units
	var world_size: Vector2 = Vector2(vp.x / zoom.x, vp.y / zoom.y) + extra_padding * 2.0

	# dimensione effettiva disegnata (hframes/region considerate)
	var tex_size: Vector2 = _drawn_texture_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return

	var sx: float = world_size.x / tex_size.x
	var sy: float = world_size.y / tex_size.y
	var s: float = (max(sx, sy) if cover else min(sx, sy))
	var target_scale: Vector2 = Vector2(s, s)

	# compensa eventuale scala del parent per ottenere la scala globale desiderata
	var parent_scale: Vector2 = Vector2.ONE
	if get_parent() is Node2D:
		parent_scale = (get_parent() as Node2D).global_scale
		parent_scale.x = 1.0 if parent_scale.x == 0.0 else parent_scale.x
		parent_scale.y = 1.0 if parent_scale.y == 0.0 else parent_scale.y

	scale = target_scale / parent_scale

	_last_zoom = zoom
	_last_vp = vp

func _drawn_texture_size() -> Vector2:
	var s: Vector2 = texture.get_size()
	# spritesheet
	if hframes > 1:
		s.x /= float(hframes)
	if vframes > 1:
		s.y /= float(vframes)
	# region
	if region_enabled:
		s = region_rect.size
	return s
