# res://battle/ui/TurnIndicator.gd
class_name TurnIndicator
extends Node2D

@export var follow_offset: Vector2 = Vector2(0, -48)  # offset di base
@export var top_margin: float = 6.0                   # margine extra sopra lo sprite del target
@export var smooth_speed: float = 14.0                # 0 = snap istantaneo; 10-20 = morbido
@export var auto_place_above_sprite: bool = true      # prova a metterti sopra al "Body" del target

var _target: Unit = null

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		visible = false
		return
	visible = true

	var desired: Vector2 = _anchor_pos_for(_target)
	if smooth_speed <= 0.0:
		global_position = desired
	else:
		# movimento morbido verso il punto desiderato
		global_position = global_position.lerp(desired, clamp(delta * smooth_speed, 0.0, 1.0))

	# resta sopra al target nel layering Y-sort
	z_index = int(global_position.y) + 100

# -----------------------------
# API: imposta il target
# -----------------------------
func follow_unit(n: Unit) -> void:
	if n is Unit:
		_target = n
	else:
		push_warning("TurnIndicator.follow_node: il nodo non è un Node2D.")
		_target = null

func follow_relative(path: NodePath, base: Node = null) -> void:
	# path relativo a 'base' (se nullo usa il parent dell'indicatore)
	var root := base if base != null else get_parent()
	if root == null:
		push_warning("TurnIndicator.follow_relative: base/root nullo.")
		return
	var n := root.get_node_or_null(path)
	if n == null:
		push_warning("TurnIndicator.follow_relative: path non trovato: %s" % String(path))
		_target = null
		return
	follow_unit(n)

func clear_target() -> void:
	_target = null

# -----------------------------
# Helpers
# -----------------------------
func _anchor_pos_for(t: Unit) -> Vector2:
	# Posizione base = centro del target
	var p: Vector2 = t.global_position

	if auto_place_above_sprite and t.has_node("Sprite"):
		var sprite := t.get_node("Sprite")
		var h: float = _half_height_world(sprite)
		if h > 0.0:
			# mettiti sopra la “testa”
			return p + Vector2(0, -h - top_margin) + follow_offset

	# fallback: solo offset
	return p + follow_offset

func _half_height_world(sprite: Node) -> float:
	# Calcola metà altezza in world units, provando Sprite2D/AnimatedSprite2D
	if sprite is Sprite2D:
		var spr := sprite as Sprite2D
		if spr.texture != null:
			var tex := spr.texture.get_size()
			var gs := spr.global_scale
			# se è un spritesheet, tieni conto dei frames
			var w := tex.x
			var h := tex.y
			if spr.hframes > 1:
				w = w / float(spr.hframes)
			if spr.vframes > 1:
				h = h / float(spr.vframes)
			return (h * gs.y) * 0.5
	elif sprite is AnimatedSprite2D:
		var aspr := sprite as AnimatedSprite2D
		if aspr.sprite_frames != null:
			var anims := aspr.sprite_frames.get_animation_names()
			if anims.size() > 0:
				var _name := anims[0]
				var tex: Texture2D = aspr.sprite_frames.get_frame_texture(_name, 0)
				if tex != null:
					var sz := tex.get_size()
					var gs := aspr.global_scale
					return (sz.y * gs.y) * 0.5
	return 0.0
