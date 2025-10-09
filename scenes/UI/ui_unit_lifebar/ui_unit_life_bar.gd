class_name LifeBar
extends Control 

@onready var _bar: TextureProgressBar  = $TextureProgressBar
 


# --- API pubblica -------------------------------------------------------------

## Collega la barra alla Unit (richiede che la Unit esponga get_stats_instance()).
func bind_to_unit(unit: Unit) -> void:
	if unit == null:
		return
	var si: StatsInstance = unit.get_stats_instance()
	_bind_to_stats(si)


## Collega direttamente una StatsInstance (se già ce l'hai).
func _bind_to_stats(si: StatsInstance) -> void:

 
	var hp_max := si.total(StatsIds.Stat.HP_MAX)
	_bar.max_value = hp_max
	_bar.value = clamp(si.current_hp, 0, hp_max)
	si.hp_changed.connect(_on_hp_changed) 





# --- Handlers segnali da StatsInstance ---------------------------------------

func _on_hp_changed(_old_value: int, new_value: int) -> void:
	# Clamp sul max attuale della barra per sicurezza
	var cap := int(_bar.max_value)
	_bar.value = clamp(new_value, 0, cap)

func _on_stat_changed(stat: int, _old_value: int, new_value: int) -> void:
	# Se è cambiato il massimale HP, aggiorna max e riclampa il valore
	if stat == StatsIds.Stat.HP_MAX:
		_bar.max_value = new_value
