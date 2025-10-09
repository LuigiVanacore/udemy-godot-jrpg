class_name AnimSetData
extends Resource

@export var animLibrary_name : StringName = &""
@export var animlibrary : AnimationLibrary

# Spritesheet con più frame (Sprite2D usa hframes/vframes/frame)
@export var animClips : Array[AnimClipData]





func get_animName(type : AnimationTypes.Types) -> StringName:
	for clip in animClips:
		if clip.anim_type == type:
			return StringName("%s/%s" % [animLibrary_name, clip.id])
	return ""


