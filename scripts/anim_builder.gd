class_name AnimBuilder
extends RefCounted


static func _get_texture_from_anim_clip(anim_name : StringName, clips : Array[AnimClipData])->Texture2D:
	for clip in clips:
		if anim_name == clip.id:
			return clip.texture as Texture2D
	return null

static func apply_textures_to_library(
	player: AnimationPlayer,
	animationSet : AnimSetData,
	sprite_node_name: StringName,               # es. &"Sprite"
) -> void:
	var lib : AnimationLibrary = animationSet.animlibrary
	var library_name : StringName = animationSet.animLibrary_name
	var tex_map : Array[AnimClipData] = animationSet.tex_map
	if lib == null:
		push_error("AnimationLibrary '%s' non trovata.")
		return

	# Duplica per non toccare la risorsa condivisa
	if not lib.resource_local_to_scene:
		lib = lib.duplicate(true) as AnimationLibrary
		lib.resource_local_to_scene = true
		player.add_animation_library(library_name, lib)

	var target := "%s:texture" % sprite_node_name

	for anim_name in lib.get_animation_list():
		var tex : Texture2D = _get_texture_from_anim_clip(anim_name, tex_map)
		if tex == null:
			continue

		var a : Animation = lib.get_animation(anim_name)
		var track_idx := -1

		# Cerca la VALUE track "Sprite:texture"
		for t in range(a.get_track_count()):
			if a.track_get_type(t) == Animation.TYPE_VALUE and String(a.track_get_path(t)) == target:
				track_idx = t
				break

		# Se non c'è, creala e inserisci una chiave a t=0
		if track_idx == -1:
			track_idx = a.add_track(Animation.TYPE_VALUE)
			a.track_set_path(track_idx, NodePath(target))

		var kc := a.track_get_key_count(track_idx)
		if kc == 0:
			a.track_insert_key(track_idx, 0.0, tex)          
		else:
			for k in range(kc):
				a.track_set_key_value(track_idx, k, tex)  



static func save_library(lib: AnimationLibrary, out_path: String) -> int:
	var err := ResourceSaver.save(lib, out_path)
	if err != OK:
		push_error("Save failed: %s" % error_string(err))
	return err
	
	
static func retarget_library_nodes(lib: AnimationLibrary, old_node: String, new_node: String) -> void:
	for anim_name in lib.get_animation_list():
		var a := lib.get_animation(anim_name)
		for t in range(a.get_track_count()):
			var p := String(a.track_get_path(t))        # es. "Sprite:texture"
			var colon := p.find(":")
			var node_part := p if colon == -1 else p.substr(0, colon)
			if node_part == old_node:
				var suffix := "" if colon == -1 else p.substr(colon)  # ":texture", ":frame", ecc.
				a.track_set_path(t, NodePath(new_node + suffix))	
