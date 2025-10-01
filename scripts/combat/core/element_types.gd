# ElementTypes.gd
class_name ElementTypes
extends RefCounted

enum Element { PHYSICAL, FIRE, ICE, LIGHTNING, WATER, WIND, EARTH, HOLY, DARK, POISON }

static func to_key(e: int) -> StringName:
	match e:
		Element.PHYSICAL: return &"PHYSICAL"
		Element.FIRE: return &"FIRE"
		Element.ICE: return &"ICE"
		Element.LIGHTNING: return &"LIGHTNING"
		Element.WATER: return &"WATER"
		Element.WIND: return &"WIND"
		Element.EARTH: return &"EARTH"
		Element.HOLY: return &"HOLY"
		Element.DARK: return &"DARK"
		Element.POISON: return &"POISON"
		_: return &"PHYSICAL"
