class_name BattleHUD
extends CanvasLayer


signal start_battle
signal battle_action_selected(action_type : ActionTypes.BattleAction)

@onready var ui_character_status_menu : UI_CharacterStatusMenu = %UI_CharacterStatusMenu
@onready var ui_action_menu : UI_ActionMenu = %UI_ActionMenu

func _ready() -> void:
	ui_action_menu.battle_action_selected.connect(_on_battle_action_selected)
	
	
func _on_btn_start_battle_pressed() -> void:
	start_battle.emit()

func _on_battle_action_selected(action_type : ActionTypes.BattleAction):
	battle_action_selected.emit(action_type)
	

func bind_character_status_menu_to_party(player_party : Array[Unit]):
	ui_character_status_menu.bind_player_party(player_party)


