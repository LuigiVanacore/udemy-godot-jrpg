# ItemData.gd
class_name ItemData
extends Resource

@export var id: StringName
@export var label: String = "Item"
@export var target_mode: int = ActionTypes.TargetMode.SINGLE_ALLY
@export var heal_amount: int = 30
