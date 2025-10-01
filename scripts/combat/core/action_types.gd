# ActionTypes.gd
class_name ActionTypes
extends RefCounted

enum TargetMode { SELF, SINGLE_ENEMY, SINGLE_ALLY, ALL_ENEMIES, ALL_ALLIES, EVERYONE }

enum BattleAction { NONE, ATTACK, SKILL, ITEM, DEFEND, ESCAPE }

enum DamageKind  { PHYSICAL, MAGICAL }
