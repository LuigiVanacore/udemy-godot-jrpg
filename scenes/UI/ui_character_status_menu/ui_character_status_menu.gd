class_name UI_CharacterStatusMenu
extends Control


@onready var party_status_dock : HBoxContainer = %PartyStatusDock
@onready var character_status_cards : Array[CharacterStatusCard]



func _ready():
	for child in party_status_dock.get_children():
		var character_status_card = child as CharacterStatusCard
		character_status_cards.append(character_status_card)
		


func bind_player_party(player_party : Array[Unit]):
	if player_party.size() != character_status_cards.size():
		return
	var total_character_status_cards : int = character_status_cards.size()
	for i in total_character_status_cards:
		character_status_cards[i].bind_unit(player_party[i])
