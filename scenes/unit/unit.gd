class_name Unit
extends Node2D


signal action_started(action_type : ActionTypes.BattleAction)
signal action_ended()
signal damage_taken(damage_value : int)
signal died

@export var anim_set: AnimSetData    
@export var character_data : CharacterData


var floating_text_scene : PackedScene = preload("uid://bxp2a03d0wbr")

var unit_name : StringName 
var stats_instance : StatsInstance

var msg_attack : StringName = &"attack"
var msg_dead : StringName = &"dead"
var msg_idle : StringName = &"idle"
var msg_damage : StringName = &"damage"

var bb_action_result : StringName = &"action_result"

var _is_alive : bool = true

@onready var pivot : Marker2D = %Pivot
@onready var body : Sprite2D = %Body
@onready var weapon : Sprite2D = %Weapon

@onready var animation_manager : AnimationManager = %AnimationManager
@onready var animPlayer: AnimationPlayer = $Anim
@onready var life_bar : LifeBar = %UI_UnitLifeBar
@onready var target_marker : Marker2D = %TargetMarker
@onready var floating_text_marker : Marker2D = %FloatingTextMarker

@onready var hsm : LimboHSM = $LimboHSM
@onready var idleState : LimboState = $LimboHSM/IdleState
@onready var attackState : LimboState = $LimboHSM/AttackState
@onready var blockState : LimboState = $LimboHSM/BlockState
@onready var itemState : LimboState = $LimboHSM/ItemState
@onready var dodgeState : LimboState = $LimboHSM/DodgeState
@onready var weakState : LimboState = $LimboHSM/BlockState
@onready var damageState : LimboState = $LimboHSM/DamageState
@onready var deadState : LimboState = $LimboHSM/DeadState


func _ready() -> void:
	unit_name = character_data.character_name
 	
	stats_instance = StatsInstance.new()
	if character_data != null:
		stats_instance.base = character_data.base_stats
	
	stats_instance.init_current_full()
	
	if not character_data.is_party_member:	
		life_bar.visible = true
		life_bar.bind_to_unit(self) 
		body.flip_h = true
		weapon.flip_h = true
		target_marker.position.x = -target_marker.position.x
		
	
	hsm.add_transition(idleState, attackState, msg_attack)
	hsm.add_transition(hsm.ANYSTATE, idleState, msg_idle)  
	hsm.add_transition(hsm.ANYSTATE, damageState, msg_damage) 
	
	hsm.initialize(self)
	hsm.set_active(true)   
	
	hsm.change_active_state(idleState)
		
	# Applica texture e griglie per questo personaggio
	#AnimBuilder.apply_textures_to_library(animPlayer, anim_set, &"Pivot/Body")
 #
	#animPlayer.play("character_battle_animation/idle")

func get_unit_name()->StringName:
	return unit_name

func is_alive()->bool:
	return _is_alive

func is_party_member()->bool:
	return character_data.is_party_member

func get_stats_instance() -> StatsInstance:
	return stats_instance
	
func get_stat(stat_id : StatsIds.Stat)->int:
	return stats_instance.total(stat_id)
	
func get_target_marker()->Marker2D:
	return target_marker
	
func execute_action(action_id: ActionTypes.BattleAction, result : ActionResult):
	hsm.blackboard.set_var(bb_action_result, result)
	hsm.dispatch(msg_attack)

func change_hp(value : int):
	stats_instance.change_hp(value)

	hsm.dispatch(msg_damage)
	var floating_text : FloatingText2D = floating_text_scene.instantiate()
	add_child(floating_text)
	floating_text.popup_amount(value, floating_text_marker.global_position, FloatingText2D.MESSAGE_TYPE.DAMAGE)
		
func change_mp(value : int):
	pass
	

func get_stats_state() -> Dictionary[StringName, int]:
	# Richiede StatsIds nel progetto (come già usi altrove) 
	return {
		"id": get_instance_id(),
		"team":  1 if is_party_member() else 0,
		"hp": int(stats_instance.current_hp),
		"hp_max": int(stats_instance.total(StatsIds.Stat.HP_MAX)),
		"mp": int(stats_instance.current_mp),
		"mp_max": int(stats_instance.total(StatsIds.Stat.MP_MAX)),
		"atk": int(stats_instance.total(StatsIds.Stat.ATK)),
		"def": int(stats_instance.total(StatsIds.Stat.DEF)),
		"matk": int(stats_instance.total(StatsIds.Stat.MATK)),
		"mdef": int(stats_instance.total(StatsIds.Stat.MDEF)),
		"acc": int(stats_instance.total(StatsIds.Stat.ACC)),
		"eva": int(stats_instance.total(StatsIds.Stat.EVA)),
		"crit_rate": int(stats_instance.total(StatsIds.Stat.CRIT_RATE)),
		"crit_dmg": int(stats_instance.total(StatsIds.Stat.CRIT_DMG)),
		"speed": int(stats_instance.total(StatsIds.Stat.SPEED)),
	}
	
func get_inventory_state()-> Dictionary[StringName, int]:
	return {}	





## (Opzionale) coroutine per le animazioni “di azione”
#func play_action_anim(action_id: StringName, target_ids: Array) -> GDScriptFunctionState:
	#if has_node("AnimationPlayer"):
		#var ap: AnimationPlayer = $AnimationPlayer
		#var anim_name := action_id == &"ATTACK" ? "attack" : "cast"
		#if ap.has_animation(anim_name):
			#ap.play(anim_name)
			#await ap.animation_finished
	#return get_tree().process_frame  # no-op, ma mantiene la signature awaitable
 
