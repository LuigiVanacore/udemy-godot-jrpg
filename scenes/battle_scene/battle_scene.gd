# res://battle/BattleScene.gd  (estratto per il layout)
class_name BattleScene
extends Node2D

# Origini e passi per la diagonale (tweakali in editor)
@export var left_origin: Vector2  = Vector2(-320, 160)  # punto del primo eroe (front)
@export var left_step: Vector2    = Vector2(-36, -22)   # va su e un po' più a sinistra
@export var right_origin: Vector2 = Vector2( 320, 160)  # punto del primo nemico (front)
@export var right_step: Vector2   = Vector2( 36, -22)   # va su e un po' più a destra

 
var _units : Array[Unit] = []
var _current_action_selected : ActionTypes.BattleAction = ActionTypes.BattleAction.NONE

var msg_start_turn : StringName = &"start_turn"
var msg_select_action : StringName = &"select_action"
var msg_action_selected : StringName = &"action_selected"
var msg_target_selected : StringName = &"target_selected"
var msg_end_turn : StringName = &"end_turn"

var bb_units: StringName = &"target_units"          # Array di unit (Node2D o derivati) in blackboard
var bb_cursor: StringName = &"cursor_target"        # Node2D del cursore in blackboard
var bb_target_unit: StringName = &"target_unit"    
var bb_caster_unit : StringName = &"caster_unit"
var bb_action_to_execute : StringName = &"action_to_execute"

@onready var hsm: LimboHSM = $LimboHSM
@onready var start_battle_state : LimboState = $LimboHSM/StartBattleState
@onready var start_turn_state : LimboState = $LimboHSM/StartTurnState 
@onready var select_target_state : LimboState = $LimboHSM/SelectTargetState
@onready var execute_action_state : LimboState = $LimboHSM/ExecuteActionState
@onready var select_action_state : LimboState = $LimboHSM/SelectActionState
@onready var end_turn_state : LimboState = $LimboHSM/EndTurnState
@onready var end_battle_state : LimboState = $LimboHSM/EndBattleState

@onready var formation_player_party : Node2D = %FormationPlayerParty
@onready var formation_enemy_party : Node2D = %FormationEnemyParty

@onready var turn_manager : TurnManager = $TurnManager
@onready var action_manager : ActionManager = $ActionManager
@onready var turn_indicator : TurnIndicator = $TurnIndicator
@onready var battle_hud : BattleHUD = %BattleHUD

func _ready() -> void:
	
	
	for child in formation_player_party.get_children():
		_units.append(child.get_child(0) as Unit) 
		
	battle_hud.bind_character_status_menu_to_party(_units)
	
	for child in formation_enemy_party.get_children():
		_units.append(child.get_child(0) as Unit) 
		
	_place_formations()
	
	hsm.add_transition(start_battle_state, start_turn_state, msg_start_turn)
	hsm.add_transition(start_turn_state, select_action_state, msg_select_action)
	hsm.add_transition(select_action_state, select_target_state, msg_action_selected)
	hsm.add_transition(select_target_state, execute_action_state, msg_target_selected, func ()->bool: return _current_action_selected == ActionTypes.BattleAction.ATTACK) 
	hsm.add_transition(execute_action_state, end_turn_state, msg_end_turn)
	hsm.add_transition(end_turn_state, start_turn_state, msg_start_turn)
	
	
	
	hsm.initialize(self)
	hsm.set_active(true)   
	
	hsm.change_active_state(start_battle_state)
	

func get_units()->Array[Unit]:
	return _units

func _place_formations() -> void:
	_place_line(formation_player_party, left_origin, left_step, false) # false = guarda a destra
	_place_line(formation_enemy_party, right_origin, right_step, true) # true = guarda a sinistra

func _place_line(formation_node: Node2D, origin: Vector2, step: Vector2, face_left: bool) -> void:
	
	var n: int = formation_node.get_children().size()
	for i: int in range(n):
		var node : Node2D = formation_node.get_child(i)
		if node == null or not is_instance_valid(node):
			continue
		var is_2d := node is Node2D
		if not is_2d:
			continue
		var pos: Vector2 = origin + step * float(i)
		node.global_position = pos
		node.z_index = int(pos.y)  # layering naturale (chi è più in basso “sopra”)
		_set_facing(node.get_child(0), face_left)

func _set_facing(battler: Node2D, face_left: bool) -> void:
	if battler == null:
		return
		
	if battler.has_method("face_left") and battler.has_method("face_right"):
		if face_left:
			battler.call("face_left")
		else:
			battler.call("face_right")
		return
	# 2) fallback: prova a flippare lo sprite figlio "Body"
	if battler.has_node("Body"):
		var n := battler.get_node("Body")
		if n is Sprite2D:
			(n as Sprite2D).flip_h = face_left
		elif n is AnimatedSprite2D:
			(n as AnimatedSprite2D).flip_h = face_left


 

 



