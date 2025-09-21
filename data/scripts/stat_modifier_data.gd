# StatModifier.gd
class_name StatModifierData
extends Resource

enum Op { ADD, MUL, FINAL_MUL, OVERRIDE }

@export var stat: int = StatsIds.Stat.ATK
@export var op: Op = Op.ADD
@export var value: float = 0.0
@export var source: StringName = &""         # es. &"Equipment/Sword01" o &"Buff/Haste"
@export var duration_sec: float = -1.0       # < 0 = infinito (nessun decay)
@export var stack_key: StringName = &""      # facoltativo: per rimpiazzo 1:1 (es. &"Haste")
