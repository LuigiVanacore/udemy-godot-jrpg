class_name BattleHUD
extends CanvasLayer


signal start_battle

@onready var ui_character_status_menu : UI_CharacterStatusMenu = %UI_CharacterStatusMenu
	
	
func _on_btn_start_battle_pressed() -> void:
	start_battle.emit()



func bind_character_status_menu_to_party(player_party : Array[Unit]):
	ui_character_status_menu.bind_player_party(player_party)
