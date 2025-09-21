# res://battle/BattleScene.gd  (estratto per il layout)
extends Node2D

# Origini e passi per la diagonale (tweakali in editor)
@export var left_origin: Vector2  = Vector2(-320, 160)  # punto del primo eroe (front)
@export var left_step: Vector2    = Vector2(-36, -22)   # va su e un po' più a sinistra
@export var right_origin: Vector2 = Vector2( 320, 160)  # punto del primo nemico (front)
@export var right_step: Vector2   = Vector2( 36, -22)   # va su e un po' più a destra

var party_nodes: Array[Unit] = []  # riempi con i tuoi battler (Node2D)
var enemy_nodes: Array[Unit] = []  # idem

@onready var formation_player_party : Node2D = %FormationPlayerParty
@onready var formation_enemy_party : Node2D = %FormationEnemyParty

@onready var turn_manager : TurnManager = $TurnManager
@onready var turn_indicator : TurnIndicator = $TurnIndicator
@onready var battle_hud : BattleHUD = %BattleHUD

func _ready() -> void:
	for child in formation_player_party.get_children():
		party_nodes.append(child.get_child(0))
	for child in formation_enemy_party.get_children():
		enemy_nodes.append(child.get_child(0))
	_place_formations()
	
	battle_hud.bind_character_status_menu_to_party(party_nodes)
	turn_manager.turn_started.connect(_on_turn_started)

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
	# 1) se il tuo BattlerView ha metodi dedicati:
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


func start_battle():
	for child : Unit in party_nodes:
		turn_manager.register_battler(child, TurnManager.Side.PLAYER, child.get_stat(StatsIds.Stat.SPEED) )
	for child : Unit in enemy_nodes:
		turn_manager.register_battler(child, TurnManager.Side.ENEMY, child.get_stat(StatsIds.Stat.SPEED) )
	turn_manager.start_battle()

func _on_btn_start_battle_pressed() -> void:
	start_battle()
	
func _on_turn_started(unit : Unit):
	turn_indicator.follow_unit(unit)


func _on_ui_start_battle() -> void:
	start_battle()
