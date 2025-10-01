class_name TurnManager
extends Node

signal round_started(round_index: int, order: Array)               # Array[Unit] all'inizio round (live)
signal order_changed(round_index: int, order: Array)               # Array[Unit] rimanenti (preview live)
signal next_round_preview_changed(next_round_index: int, order: Array) # Array[Unit] preview del round successivo (live)

signal turn_started(unit : Unit, round_index: int, turn_index: int)
signal turn_ended(unit : Unit, round_index: int, turn_index: int)

var _turn_order: Array[Unit] = []
var _active: Unit = null
var _round: int = 0
var _turn_index: int = -1
var _acted: Dictionary = {}                 # set: unit -> true (ha già agito nel round)

# cleanup segnali
var _death_handlers: Dictionary = {}        # unit -> Callable
var _exit_handlers: Dictionary = {}         # unit -> Callable
var auto_advance_on_active_death := false

# -----------------------------------------------------------------------------
# REGISTRAZIONE
# -----------------------------------------------------------------------------
func register_unit(unit: Unit) -> void:
	if _turn_order.has(unit):
		_connect_unit_signals(unit)
		return
	_turn_order.append(unit)
	_connect_unit_signals(unit)
	# aggiornare preview al volo può essere utile in setup dinamici
	_emit_remaining_order_changed()
	_emit_next_round_preview_changed()

func unregister_unit(unit: Unit) -> void:
	_disconnect_unit_signals(unit)
	var index := _turn_order.find(unit)
	if index != -1:
		_turn_order.remove_at(index)

	if _active == unit:
		emit_signal("turn_ended", unit, _round, max(_turn_index, 0))
		_active = null

	_acted.erase(unit)

	_emit_remaining_order_changed()
	_emit_next_round_preview_changed()

# -----------------------------------------------------------------------------
# CICLO BATTAGLIA
# -----------------------------------------------------------------------------
func start_battle() -> void:
	_round = 0
	_start_new_round()

# Sceglie la prossima unit (speed live) e la ritorna.
func start_turn() -> Unit:
	var candidates := _get_candidates_remaining()
	if candidates.is_empty():
		_start_new_round()
		candidates = _get_candidates_remaining()
		if candidates.is_empty():
			return null

	candidates.sort_custom(_cmp_turn_order_live)

	_turn_index += 1
	_active = candidates[0]
	emit_signal("turn_started", _active, _round, _turn_index)

	# Preview dei restanti (dopo l’attivo) + preview round successivo
	_emit_remaining_order_changed(true)
	_emit_next_round_preview_changed()
	return _active

func end_turn() -> void:
	if _active != null and is_instance_valid(_active):
		_acted[_active] = true
		emit_signal("turn_ended", _active, _round, _turn_index)
	_active = null
	# Aggiorna entrambe le preview
	_emit_remaining_order_changed()
	_emit_next_round_preview_changed()

func current_active_unit() -> Unit:
	return _active

# Chiamala quando un buff/debuff modifica speed (per aggiornare subito la UI)
func notify_speed_changed(_unit: Node = null) -> void:
	_emit_remaining_order_changed()
	_emit_next_round_preview_changed()

# Preview rimanenti del round corrente (live), esclude chi ha già agito e l’eventuale attivo
func get_remaining_order_preview() -> Array:
	var arr := _get_candidates_remaining()
	if _active != null:
		arr.erase(_active)
	arr.sort_custom(Callable(self, "_cmp_turn_order_live"))
	return arr

# Preview del PROSSIMO round (live): include tutte le unit vive, ignorando `_acted`
func get_next_round_order_preview() -> Array:
	var arr: Array[Unit] = []
	for unit in _turn_order:
		if is_instance_valid(unit) and unit.is_alive():
			arr.append(unit)
	arr.sort_custom(Callable(self, "_cmp_turn_order_live"))
	return arr

# (Comodo) Timeline di due righe: corrente + prossimo
func get_two_round_timeline() -> Dictionary:
	return {
		"current": get_remaining_order_preview(),
		"next": get_next_round_order_preview(),
	}

# -----------------------------------------------------------------------------
# INTERNO
# -----------------------------------------------------------------------------
func _start_new_round() -> void:
	_round += 1
	_turn_index = -1
	_acted.clear()

	# Ordine iniziale del nuovo round (live) per UI
	var all_alive: Array[Unit] = []
	for unit in _turn_order:
		if is_instance_valid(unit) and unit.is_alive():
			all_alive.append(unit)
	all_alive.sort_custom(_cmp_turn_order_live)
	emit_signal("round_started", _round, all_alive)

	# All'inizio round: rimanenti == all_alive
	emit_signal("order_changed", _round, all_alive)
	# E anche il preview del round SUCCESSIVO (che in pratica coincide con "se partisse adesso")
	_emit_next_round_preview_changed()

func _emit_remaining_order_changed(exclude_active := false) -> void:
	var arr := _get_candidates_remaining()
	if exclude_active and _active != null:
		arr.erase(_active)
	arr.sort_custom(_cmp_turn_order_live)
	emit_signal("order_changed", _round, arr)

func _emit_next_round_preview_changed() -> void:
	var next := get_next_round_order_preview()
	emit_signal("next_round_preview_changed", _round + 1, next)

func _get_candidates_remaining() -> Array[Unit]:
	var arr : Array[Unit] = []
	for unit in _turn_order:
		if is_instance_valid(unit) and unit.is_alive() and !_acted.has(unit):
			arr.append(unit)
	return arr

# Ordinamento LIVE: speed desc, party first, poi instance_id asc (deterministico)
func _cmp_turn_order_live(a: Unit, b: Unit) -> bool:
	var speed_a := _read_speed(a)
	var speed_b := _read_speed(b)
	if speed_a != speed_b:
		return speed_a > speed_b
	var pa := a.is_party_member()
	var pb := b.is_party_member()
	if pa != pb:
		return pa
	return a.get_instance_id() < b.get_instance_id()

# -----------------------------------------------------------------------------
func _read_speed(unit: Unit) -> int:
	return unit.get_stat(StatsIds.Stat.SPEED)

# -----------------------------------------------------------------------------
# HOOK MORTE / USCITA
# -----------------------------------------------------------------------------
func _connect_unit_signals(u: Node) -> void:
	if !is_instance_valid(u): return

	if !_death_handlers.has(u):
		var death_cb := Callable(self, "_on_unit_died").bind(u)
		if u.has_signal("unit_died"):
			u.unit_died.connect(death_cb)
			_death_handlers[u] = death_cb
		elif u.has_signal("died"):
			u.died.connect(death_cb)
			_death_handlers[u] = death_cb

	if !_exit_handlers.has(u):
		var exit_cb := Callable(self, "_on_unit_tree_exiting").bind(u)
		u.tree_exiting.connect(exit_cb)
		_exit_handlers[u] = exit_cb

	# opzionale: subscribe a cambi statistiche per aggiornare subito le preview
	if u.has_signal("speed_changed"):
		u.speed_changed.connect(Callable(self, "notify_speed_changed").bind(u))
	elif u.has_signal("stats_changed"):
		u.stats_changed.connect(Callable(self, "notify_speed_changed").bind(u))

func _disconnect_unit_signals(u: Node) -> void:
	if is_instance_valid(u):
		if _death_handlers.has(u):
			var cb: Callable = _death_handlers[u]
			if u.has_signal("unit_died") and u.unit_died.is_connected(cb):
				u.unit_died.disconnect(cb)
			elif u.has_signal("died") and u.died.is_connected(cb):
				u.died.disconnect(cb)
		if _exit_handlers.has(u):
			var cb2: Callable = _exit_handlers[u]
			if u.tree_exiting.is_connected(cb2):
				u.tree_exiting.disconnect(cb2)
		if u.has_signal("speed_changed"):
			var c := Callable(self, "notify_speed_changed").bind(u)
			if u.speed_changed.is_connected(c): u.speed_changed.disconnect(c)
		elif u.has_signal("stats_changed"):
			var c2 := Callable(self, "notify_speed_changed").bind(u)
			if u.stats_changed.is_connected(c2): u.stats_changed.disconnect(c2)

	_death_handlers.erase(u)
	_exit_handlers.erase(u)

func _on_unit_died(u: Unit) -> void:
	var was_active := (_active == u)
	unregister_unit(u)
	if was_active and auto_advance_on_active_death:
		start_turn()
