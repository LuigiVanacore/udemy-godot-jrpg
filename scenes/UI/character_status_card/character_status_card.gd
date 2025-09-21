class_name CharacterStatusCard
extends Control


 

@onready var name_label : Label = %NameLabel
@onready var lv_label : Label = %LvLabel

@onready var hp_bar : TextureProgressBar = %HpBar
@onready var mp_bar : TextureProgressBar = %MpBar




func bind_unit(unit : Unit):
	name_label.text = unit.character_data.character_name
	lv_label.text = "Lv.: " + str(unit.character_data.level)
	
	hp_bar.max_value = unit.character_data.base_stats.HP_MAX
	mp_bar.max_value = unit.character_data.base_stats.MP_MAX
	
	set_hp_bar_value(unit.stats_instance.current_hp, unit.stats_instance.current_hp)
	set_mp_bar_value(unit.stats_instance.current_mp, unit.stats_instance.current_mp)
	
	unit.stats_instance.hp_changed.connect(set_hp_bar_value)
	unit.stats_instance.mp_changed.connect(set_mp_bar_value)




func set_hp_bar_value(_old_value: float, new_value: float):
	hp_bar.value = clamp(new_value, 0, hp_bar.max_value)


func set_mp_bar_value(_old_value: float, new_value: float):
	mp_bar.value = clamp(new_value, 0, mp_bar.max_value)
