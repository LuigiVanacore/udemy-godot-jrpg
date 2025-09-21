# SkillData.gd
class_name SkillData
extends Resource

@export var id: StringName
@export var label: String = "Skill"
@export var target_mode: int = ActionTypes.TargetMode.SINGLE_ENEMY
@export var mp_cost: int = 5
@export var power: float = 1.2
# stat su cui scala (usa chiave dello snapshot: "atk", "def", "matk", ecc.)
@export var scaling_stat: StringName = &"atk"
# "damage" o "heal"
@export var effect_kind: StringName = &"damage"
