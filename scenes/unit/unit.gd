class_name Unit
extends Node2D


signal action_started(action_type : ActionTypes.BattleAction)
signal action_ended()
signal damage_taken(damage_value : int)
signal died

@export var anim_set: AnimSetData    
@export var character_data : CharacterData

var unit_name : StringName 
var stats_instance : StatsInstance

var msg_attack : StringName = &"attack"
var msg_dead : StringName = &"dead"
var msg_idle : StringName = &"idle"
var msg_damage : StringName = &"damage"

var _is_alive : bool = true

@onready var body : Sprite2D = %Body
@onready var weapon : Sprite2D = %Weapon

@onready var anim: AnimationPlayer = $Anim
@onready var life_bar : Control = %UI_UnitLifeBar
@onready var target_marker : Marker2D = %TargetMarker

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
		body.flip_h = true
		weapon.flip_h = true
		target_marker.position.x = -target_marker.position.x
		
	# Applica texture e griglie per questo personaggio
	AnimBuilder.apply_textures_to_library(anim, anim_set, &"Pivot/Body")
 
	anim.play("character_battle_animation/idle")

func get_unit_name()->StringName:
	return unit_name

func is_alive()->bool:
	return _is_alive

func is_party_member()->bool:
	return character_data.is_party_member
	
	
func get_stat(stat_id : StatsIds.Stat)->int:
	return stats_instance.total(stat_id)
	
func get_target_marker()->Marker2D:
	return target_marker


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

# Applicazione “shell” dei delta + sync allo snapshot aggiornato
func apply_delta(delta : Dictionary, updated_state: Dictionary[StringName, int]) -> void:
	# HP
	if delta.has("hp"):
		var new_hp : int = int(updated_state.get("hp", stats_instance.current_hp))
		var old_hp : int = stats_instance.current_hp
		stats_instance.current_hp = new_hp
		if !is_equal_approx(old_hp, new_hp):
			stats_instance.hp_changed.emit(old_hp, new_hp)
			if old_hp > new_hp:
				damage_taken.emit(new_hp)

	# MP
	if delta.has("mp"):
		var new_mp : int = int(updated_state.get("mp", stats_instance.current_mp))
		var old_mp : int = stats_instance.current_mp
		stats_instance.current_mp = new_mp
		if !is_equal_approx(old_mp, new_mp):
			stats_instance.mp_changed.emit(old_mp, new_mp)

	# KO?
	if updated_state.get("hp", 1) <= 0:
		_is_alive = false
		died.emit()
		hsm.dispatch(msg_dead)



## (Opzionale) coroutine per le animazioni “di azione”
#func play_action_anim(action_id: StringName, target_ids: Array) -> GDScriptFunctionState:
	#if has_node("AnimationPlayer"):
		#var ap: AnimationPlayer = $AnimationPlayer
		#var anim_name := action_id == &"ATTACK" ? "attack" : "cast"
		#if ap.has_animation(anim_name):
			#ap.play(anim_name)
			#await ap.animation_finished
	#return get_tree().process_frame  # no-op, ma mantiene la signature awaitable
 
