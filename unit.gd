class_name Unit
extends Node2D




@export var character_data : CharacterData

var stats_instance : StatsInstance

@onready var body : Sprite2D = $Body

@export var anim_set: AnimSetData    # assegna il tuo .tres con library + clip array


@onready var anim: AnimationPlayer = $Anim
@onready var life_bar : Control = %UI_UnitLifeBar

@onready var hsm : LimboHSM = $LimboHSM
@onready var idleState : LimboState = $LimboHSM/IdleState
@onready var attackState : LimboState = $LimboHSM/AttackState
@onready var blockState : LimboState = $LimboHSM/BlockState
@onready var itemState : LimboState = $LimboHSM/ItemState
@onready var dodgeState : LimboState = $LimboHSM/DodgeState
@onready var weakState : LimboState = $LimboHSM/BlockState
@onready var damageState : LimboState = $LimboHSM/DamageState


func _ready() -> void:

	stats_instance = StatsInstance.new()
	if character_data != null:
		stats_instance.base = character_data.base_stats
	
	stats_instance.init_current_full()
	
	if not character_data.is_party_member:	
		life_bar.visible = true
		
	# Applica texture e griglie per questo personaggio
	AnimBuilder.apply_textures_to_library(anim, anim_set, &"Pivot/Body")
 
	anim.play("character_battle_animation/idle")
 


func get_stat(stat_id : StatsIds.Stat)->float:
	return stats_instance.total(stat_id)

