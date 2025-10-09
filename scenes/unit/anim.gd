extends AnimationPlayer


@export var sprite_path: NodePath
@export var player_path: NodePath
@export var skin: AnimationSkinSet              # assegnalo per personaggio

var clip_id: StringName set = set_clip_id       # la proprietà che keyerai in Library





func set_clip_id(v: StringName) -> void:
	clip_id = v
	_apply_clip(v)

func _on_anim_started(name: StringName) -> void:
	# fallback utile: se non hai key "clip_id" nell'anim, prova a usare il nome animazione
	if clip_id == &"":
		_apply_clip(StringName(name))

func _apply_clip(id: StringName) -> void:
	if not is_instance_valid(_sprite) or skin == null:
		return
	var e := skin.get(id)
	if e == null or e.texture == null:
		return
	_sprite.texture = e.texture
	# opzionale: reset frame se usi track su "frame"
	# _sprite.frame = 0
