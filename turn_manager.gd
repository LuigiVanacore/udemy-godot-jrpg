# res://battle/TurnOrderService.gd
class_name TurnManager
extends Node

enum Side { PLAYER, ENEMY }

signal round_started(round_index: int, order: Array)   # Array di Node (solo la vista dei battler)
signal turn_started(actor: Unit)
signal turn_ended(actor: Unit)

@export var randomize_same_side_ties: bool = false  # se false → usa slot_index per pari-speed stesso lato

# ----------------------
#  Token per l'ordine
# ----------------------
class TurnToken:
	var unit: Unit
	var side: TurnManager.Side
	var base_speed: float
	var slot_index: int = 0
	var alive: bool = true
	var tie_roll: int = 0  # usato se randomize_same_side_ties = true

	func _init(n: Unit, s: TurnManager.Side, spd: float, slot: int) -> void:
		unit = n
		side = s
		base_speed = max(0.0, spd)
		slot_index = slot

# ----------------------
#  Stato
# ----------------------
var _units: Array[TurnToken] = []
var _order: Array[TurnToken] = []
var _ix: int = -1
var _round: int = 0
var _active: TurnToken = null

# ----------------------
#  API
# ----------------------
func register_battler(unit: Unit, side: TurnManager.Side, speed: float, slot_index: int = 0) -> void:
	var t := TurnToken.new(unit, side, speed, slot_index)
	_units.append(t)

func set_alive(unit: Unit, alive: bool) -> void:
	for i in _units.size():
		if _units[i].unit == unit:
			_units[i].alive = alive
			break

func refresh_speed_from_node(unit: Unit, new_speed: float) -> void:
	# usa questa se cambi la speed a runtime
	for i in _units.size():
		if _units[i].unit == unit:
			_units[i].base_speed = max(0.0, new_speed)
			break

func start_battle() -> void:
	_round = 0
	_start_new_round()

func current_actor() -> Unit:
	return _active.unit if _active != null else null

func preview_next(n: int = 8) -> Array:
	# Ritorna i prossimi N attori (Node) a partire dal turno corrente (senza mutare lo stato).
	var out: Array = []
	if _order.is_empty():
		return out
	var idx : int = max(0, _ix)
	while out.size() < n:
		idx += 1
		if idx >= _order.size():
			# simuliamo il prossimo round con la stessa fotografia (NB: se dinamico, chiama _build_order() esterno)
			idx = 0
		out.append(_order[idx].unit)
	return out

func end_turn(actor: Node2D) -> void:
	# Chiama questa quando l'azione (giocatore o IA) è completamente risolta
	if _active == null or _active.unit != actor:
		return
	var ended := _active
	_active = null
	emit_signal("turn_ended", ended.unit)
	_advance_turn()

# ----------------------
#  Internals
# ----------------------
func _start_new_round() -> void:
	_round += 1
	_build_order()
	_ix = -1
	emit_signal("round_started", _round, _order.map(func(t): return t.unit))
	_advance_turn()  # parte il primo turno

func _advance_turn() -> void:
	# trova il prossimo vivo; se finita la lista → nuovo round
	var tries := 0
	while tries < _order.size():
		_ix += 1
		if _ix >= _order.size():
			_start_new_round()
			return
		var t := _order[_ix]
		if t.alive and is_instance_valid(t.unit):
			_active = t
			emit_signal("turn_started", t.unit)
			return
		tries += 1
	# nessuno disponibile (battaglia finita?)
	_active = null

func _effective_speed(t: TurnToken) -> float:
	# Se il nodo espone get_battle_speed(), usalo; altrimenti base_speed
	if is_instance_valid(t.unit) and t.unit.has_method("get_battle_speed"):
		var v = t.unit.call("get_battle_speed")
		return float(v)
	return t.base_speed

func _build_order() -> void:
	# prepara tie-roll se richiesto
	if randomize_same_side_ties:
		for i in _units.size():
			_units[i].tie_roll = randi() % 100000

	# snapshot vivi
	var alive_list: Array[TurnToken] = []
	for t in _units:
		if t.alive and is_instance_valid(t.unit):
			alive_list.append(t)

	# ordina: speed desc, PLAYER prima di ENEMY a pari speed, poi slot_index (o tie_roll)
	alive_list.sort_custom(Callable(self, "_less_token"))
	_order = alive_list

func _less_token(a: TurnToken, b: TurnToken) -> bool:
	var sa := _effective_speed(a)
	var sb := _effective_speed(b)
	if sa != sb:
		return sa > sb  # speed più alta prima
	# pari speed → PLAYER prima
	var ap := a.side == Side.PLAYER
	var bp := b.side == Side.PLAYER
	if ap != bp:
		return ap  # true se a è player (quindi prima)
	# stesso lato → usa slot_index oppure tie_roll
	if randomize_same_side_ties:
		return a.tie_roll < b.tie_roll
	return a.slot_index < b.slot_index
