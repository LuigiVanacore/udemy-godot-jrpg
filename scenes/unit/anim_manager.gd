class_name AnimationManager
extends Node


@export var attack_pos_offset : int = 30

var anim_set_data : AnimSetData


@onready var anim : AnimationPlayer = $%Anim
@onready var body : Sprite2D = $%Body
@onready var weapon : Sprite2D = $%Weapon
@onready var pivot : Marker2D = $%Pivot


func _ready():
	anim_set_data = (get_parent() as Unit).anim_set
	AnimBuilder.apply_textures_to_library(anim, anim_set_data, &"Pivot/Body")

 

func play(anim_type : AnimationTypes.Types): 
	anim.play(anim_set_data.get_animName(anim_type))
	 
func move_attack() -> void:
	var offset = attack_pos_offset
	var start : float = pivot.position.x
	var t := pivot.create_tween()
	if not (get_parent() as Unit).is_party_member():
		offset = -offset
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(pivot, "position:x", start + offset, 0.4)
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(pivot, "position:x", start,  1.6)
	await t.finished  # opzionale: aspetta la fine
