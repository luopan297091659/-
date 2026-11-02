extends Control

enum GameState { PLAYING, MATCHING, WON, LOST, PAUSED }

const SAVE_PATH := "user://progress.cfg"
const LEVELS_PATH := "res://data/levels.json"
const SLOT_LIMIT := 7
const PRODUCT_NAMES := [
	"鮭おにぎり",
	"ツナごはん",
	"カレー",
	"オレンジ",
	"牛乳",
	"お菓子",
	"バナナ",
	"コーラ",
]
const PRODUCT_TEXTURES := [
	preload("res://assets/items/onigiri/item_onigiri_salmon.png"),
	preload("res://assets/items/onigiri/item_onigiri_tuna.png"),
	preload("res://assets/items/bento/item_bento_curry.png"),
	preload("res://assets/items/drinks/item_drink_juice.png"),
	preload("res://assets/items/drinks/item_drink_milk.png"),
	preload("res://assets/items/drinks/item_drink_tea.png"),
	preload("res://assets/items/sweets/item_cake.png"),
	preload("res://assets/items/sweets/item_dorayaki.png"),
]
const GAME_BACKGROUND: Texture2D = preload("res://assets/ui/backgrounds/bg_game.png")
const SLOT_TEXTURE: Texture2D = preload("res://assets/ui/panels/inventory_slot.png")
const HINT_TEXTURE: Texture2D = preload("res://assets/ui/icons/icon_hint.png")
const UNDO_TEXTURE: Texture2D = preload("res://assets/ui/icons/icon_undo.png")
const SHUFFLE_TEXTURE: Texture2D = preload("res://assets/ui/icons/icon_shuffle.png")
const STAR_TEXTURE: Texture2D = preload("res://assets/ui/icons/icon_star.png")
const NEXT_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_next.png")
const RETRY_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_retry.png")
const TEXT_COLOR := Color("#65452f")

var levels: Array[Dictionary] = []
var board: Array[Dictionary] = []
var tray: Array[int] = []
var history: Array[Dictionary] = []
var current_level := 1
var max_unlocked_level := 1
var coins := 100
var powerups := {"hint": 0, "undo": 0, "shuffle": 0}
var game_state: GameState = GameState.PLAYING
var hint_item_id := -1

var level_label: Label
var coin_label: Label
var progress_label: Label
var message_label: Label
var shelf_grid: GridContainer
var tray_row: HBoxContainer
var overlay: ColorRect
var overlay_title: Label
var overlay_message: Label
var overlay_stars: HBoxContainer
var overlay_primary: TextureButton
var overlay_secondary: TextureButton
var overlay_home: Button
var action_captions: Dictionary = {}


func _ready() -> void:
	_load_levels()
	_load_progress()
	_build_interface()
	_start_level(current_level)


func _load_levels() -> void:
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file == null:
		push_error("レベルデータを開けません: " + LEVELS_PATH)
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("levels"):
		push_error("レベルデータの形式が正しくありません: " + LEVELS_PATH)
		return

	var raw_levels: Variant = parsed["levels"]
	if typeof(raw_levels) != TYPE_ARRAY or raw_levels.is_empty():
		push_error("レベルデータが空です: " + LEVELS_PATH)
		return

	for raw_level in raw_levels:
		if typeof(raw_level) != TYPE_DICTIONARY:
			push_error("レベル設定は辞書形式である必要があります")
			return
		var groups := int(raw_level.get("groups", 0))
		var types := int(raw_level.get("types", 0))
		if groups < 1 or types < 1 or types > PRODUCT_TEXTURES.size():
			push_error("レベル設定の groups または types が範囲外です")
			return
		levels.append({"groups": groups, "types": types})


func _load_progress() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return
	if error != OK:
		push_error("セーブデータを読み込めません: " + error_string(error))
		return

	coins = maxi(0, int(config.get_value("progress", "coins", 100)))
	for powerup_name in powerups:
		powerups[powerup_name] = maxi(0, int(config.get_value("powerups", powerup_name, 0)))
	max_unlocked_level = clampi(
		int(config.get_value("progress", "max_unlocked_level", 1)),
		1,
		maxi(1, levels.size())
	)
	current_level = max_unlocked_level


func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "coins", coins)
	config.set_value("progress", "max_unlocked_level", max_unlocked_level)
	for powerup_name in powerups:
		config.set_value("powerups", powerup_name, powerups[powerup_name])
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("セーブデータを保存できません: " + error_string(error))


func _build_interface() -> void:
	var background := TextureRect.new()
	background.texture = GAME_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var top_bar := HBoxContainer.new()
	_set_anchors(top_bar, 0.06, 0.055, 0.94, 0.155)
	top_bar.add_theme_constant_override("separation", 14)
	add_child(top_bar)

	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 32)
	level_label.add_theme_color_override("font_color", TEXT_COLOR)
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(level_label)

	var coin_icon := PanelContainer.new()
	coin_icon.custom_minimum_size = Vector2(56, 56)
	coin_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	coin_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var coin_style := StyleBoxFlat.new()
	coin_style.bg_color = Color("#ffb83d")
	coin_style.border_color = Color("#b17a48")
	coin_style.set_border_width_all(3)
	coin_style.set_corner_radius_all(24)
	coin_icon.add_theme_stylebox_override("panel", coin_style)
	top_bar.add_child(coin_icon)

	var coin_mark := Label.new()
	coin_mark.text = "¥"
	coin_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coin_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coin_mark.add_theme_font_size_override("font_size", 23)
	coin_mark.add_theme_color_override("font_color", TEXT_COLOR)
	coin_icon.add_child(coin_mark)

	coin_label = Label.new()
	coin_label.add_theme_font_size_override("font_size", 25)
	coin_label.add_theme_color_override("font_color", TEXT_COLOR)
	coin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coin_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_bar.add_child(coin_label)

	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.custom_minimum_size = Vector2(72, 72)
	pause_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pause_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pause_button.add_theme_font_size_override("font_size", 30)
	pause_button.add_theme_color_override("font_color", TEXT_COLOR)
	_style_button(pause_button, Color("#fff0cc"))
	pause_button.pressed.connect(_pause_game)
	top_bar.add_child(pause_button)

	var shelf_area := CenterContainer.new()
	_set_anchors(shelf_area, 0.075, 0.225, 0.925, 0.72)
	add_child(shelf_area)

	shelf_grid = GridContainer.new()
	shelf_grid.add_theme_constant_override("h_separation", 2)
	shelf_grid.add_theme_constant_override("v_separation", 2)
	shelf_area.add_child(shelf_grid)

	progress_label = Label.new()
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_color_override("font_color", TEXT_COLOR)
	_set_anchors(progress_label, 0.1, 0.735, 0.9, 0.765)
	add_child(progress_label)

	tray_row = HBoxContainer.new()
	tray_row.add_theme_constant_override("separation", 5)
	_set_anchors(tray_row, 0.055, 0.765, 0.945, 0.875)
	add_child(tray_row)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	action_row.add_theme_constant_override("separation", 42)
	_set_anchors(action_row, 0.08, 0.88, 0.92, 0.97)
	add_child(action_row)

	_add_action(action_row, HINT_TEXTURE, "hint", "ヒント", "15", _use_hint)
	_add_action(action_row, UNDO_TEXTURE, "undo", "もどす", "10", _undo_move)
	_add_action(action_row, SHUFFLE_TEXTURE, "shuffle", "シャッフル", "20", _shuffle_items)

	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", TEXT_COLOR)
	_set_anchors(message_label, 0.05, 0.18, 0.95, 0.205)
	add_child(message_label)

	_build_overlay()
	_refresh_interface()


func _build_overlay() -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0.20, 0.15, 0.10, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 470)
	var panel_style := StyleBoxTexture.new()
	panel_style.texture = SLOT_TEXTURE
	panel_style.texture_margin_left = 28
	panel_style.texture_margin_right = 28
	panel_style.texture_margin_top = 28
	panel_style.texture_margin_bottom = 28
	panel_style.draw_center = true
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 34)
	overlay_title.add_theme_color_override("font_color", TEXT_COLOR)
	content.add_child(overlay_title)

	overlay_message = Label.new()
	overlay_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_message.add_theme_font_size_override("font_size", 22)
	overlay_message.add_theme_color_override("font_color", TEXT_COLOR)
	content.add_child(overlay_message)

	overlay_stars = HBoxContainer.new()
	overlay_stars.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay_stars.add_theme_constant_override("separation", 12)
	content.add_child(overlay_stars)
	for _star_index in range(3):
		var star := TextureRect.new()
		star.texture = STAR_TEXTURE
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(62, 62)
		overlay_stars.add_child(star)
	overlay_stars.visible = false

	overlay_primary = _result_button()
	content.add_child(overlay_primary)
	overlay_secondary = _result_button()
	content.add_child(overlay_secondary)

	overlay_home = Button.new()
	overlay_home.text = "ホームへ"
	overlay_home.custom_minimum_size = Vector2(0, 58)
	overlay_home.add_theme_font_size_override("font_size", 21)
	overlay_home.add_theme_color_override("font_color", TEXT_COLOR)
	_style_button(overlay_home, Color("#fff0cc"))
	overlay_home.pressed.connect(_go_home)
	content.add_child(overlay_home)


func _start_level(level_number: int) -> void:
	if levels.is_empty():
		game_state = GameState.LOST
		message_label.text = "レベルデータを読み込めませんでした"
		return

	current_level = clampi(level_number, 1, levels.size())
	game_state = GameState.PLAYING
	history.clear()
	tray.clear()
	hint_item_id = -1
	message_label.text = "商品をタップしてトレーに入れよう"

	var config: Dictionary = levels[current_level - 1]
	var random := RandomNumberGenerator.new()
	random.seed = current_level * 1009 + 1
	var groups: int = int(config["groups"])
	var types: int = int(config["types"])
	var group_types: Array[int] = []
	for product_type in range(types):
		group_types.append(product_type)
	while group_types.size() < groups:
		group_types.append(random.randi_range(0, types - 1))
	_shuffle_with_rng(group_types, random)

	var product_pool: Array[int] = []
	for product_type in group_types:
		for _copy in range(3):
			product_pool.append(product_type)
	_shuffle_with_rng(product_pool, random)

	board.clear()
	for item_id in range(product_pool.size()):
		board.append({
			"id": item_id,
			"type": product_pool[item_id],
			"cleared": false,
		})
	_refresh_interface()


func _shuffle_with_rng(values: Array[int], random: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var other_index := random.randi_range(0, index)
		var temporary := values[index]
		values[index] = values[other_index]
		values[other_index] = temporary


func _refresh_interface() -> void:
	if level_label == null:
		return
	level_label.text = "ステージ %02d" % current_level
	coin_label.text = str(coins)
	progress_label.text = "整理トレー　%d / %d" % [tray.size(), SLOT_LIMIT]
	for powerup_name in action_captions:
		var caption: Label = action_captions[powerup_name]
		var display_name: String = str({"hint": "ヒント", "undo": "もどす", "shuffle": "シャッフル"}.get(powerup_name, ""))
		var price: int = int({"hint": 15, "undo": 10, "shuffle": 20}.get(powerup_name, 0))
		caption.text = "%s  所持 %d / %d" % [display_name, int(powerups[powerup_name]), price]
	_render_board()
	_render_tray()


func _render_board() -> void:
	for child in shelf_grid.get_children():
		child.queue_free()
	if board.is_empty():
		return

	var column_count := 4
	if board.size() >= 30:
		column_count = 6
	elif board.size() >= 20:
		column_count = 5
	shelf_grid.columns = column_count
	var row_count := int(ceil(float(board.size()) / column_count))
	var cell_width := floori((612.0 - (column_count - 1) * 8) / column_count)
	var cell_height := floori((620.0 - (row_count - 1) * 6) / row_count)
	var icon_height := maxi(42, cell_height - 25)

	for item in board:
		var item_id: int = int(item["id"])
		var product_type: int = int(item["type"])
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(cell_width, cell_height)
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color("#fff6e6")
		card_style.border_color = Color("#b17a48")
		card_style.set_border_width_all(2)
		card_style.set_corner_radius_all(12)
		card_style.content_margin_left = 3
		card_style.content_margin_right = 3
		card_style.content_margin_top = 3
		card_style.content_margin_bottom = 3
		card.add_theme_stylebox_override("panel", card_style)
		shelf_grid.add_child(card)

		var card_content := VBoxContainer.new()
		card_content.add_theme_constant_override("separation", 0)
		card.add_child(card_content)

		if bool(item["cleared"]):
			card.modulate = Color(1, 1, 1, 0.18)
			card_content.add_child(Control.new())
			continue

		var product_button := TextureButton.new()
		product_button.texture_normal = PRODUCT_TEXTURES[product_type]
		product_button.ignore_texture_size = true
		product_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		product_button.custom_minimum_size = Vector2(cell_width - 8, icon_height)
		product_button.tooltip_text = PRODUCT_NAMES[product_type]
		if item_id == hint_item_id:
			product_button.modulate = Color("#fff0a8")
		product_button.pressed.connect(_select_item.bind(item_id))
		card_content.add_child(product_button)

		var item_label := Label.new()
		item_label.text = PRODUCT_NAMES[product_type]
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.clip_text = true
		item_label.add_theme_font_size_override("font_size", 12)
		item_label.add_theme_color_override("font_color", TEXT_COLOR)
		card_content.add_child(item_label)


func _render_tray() -> void:
	for child in tray_row.get_children():
		child.queue_free()

	for slot_index in range(SLOT_LIMIT):
		var slot := Control.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.custom_minimum_size = Vector2(72, 92)
		tray_row.add_child(slot)

		var frame := TextureRect.new()
		frame.texture = SLOT_TEXTURE
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_SCALE
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(frame)

		if slot_index < tray.size():
			var item_icon := TextureRect.new()
			item_icon.texture = PRODUCT_TEXTURES[tray[slot_index]]
			item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_icon.anchor_left = 0.12
			item_icon.anchor_top = 0.12
			item_icon.anchor_right = 0.88
			item_icon.anchor_bottom = 0.88
			item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(item_icon)


func _add_action(
	parent: HBoxContainer,
	texture: Texture2D,
	powerup_name: String,
	title: String,
	price: String,
	action: Callable
) -> void:
	var action_column := VBoxContainer.new()
	action_column.alignment = BoxContainer.ALIGNMENT_CENTER
	action_column.add_theme_constant_override("separation", 0)
	parent.add_child(action_column)

	var button := TextureButton.new()
	button.texture_normal = texture
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = Vector2(88, 76)
	button.pressed.connect(action)
	action_column.add_child(button)

	var caption := Label.new()
	caption.text = "%s %s" % [title, price]
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 15)
	caption.add_theme_color_override("font_color", TEXT_COLOR)
	action_column.add_child(caption)
	action_captions[powerup_name] = caption


func _select_item(item_id: int) -> void:
	if game_state != GameState.PLAYING:
		return

	var item_index := -1
	for index in range(board.size()):
		if int(board[index]["id"]) == item_id and not bool(board[index]["cleared"]):
			item_index = index
			break
	if item_index < 0:
		return

	history.append({"board": board.duplicate(true), "tray": tray.duplicate()})
	board[item_index]["cleared"] = true
	var product_type: int = int(board[item_index]["type"])
	tray.append(product_type)
	hint_item_id = -1

	var matching_slots: Array[int] = []
	for index in range(tray.size()):
		if tray[index] == product_type:
			matching_slots.append(index)
	var matched := matching_slots.size() == 3
	if matched:
		game_state = GameState.MATCHING
		message_label.text = "%sが3つそろった！" % PRODUCT_NAMES[product_type]
		_refresh_interface()
		await get_tree().process_frame
		if not is_inside_tree():
			return
		for slot_index in matching_slots:
			var matched_slot := tray_row.get_child(slot_index) as Control
			matched_slot.pivot_offset = matched_slot.size / 2
			var tween := matched_slot.create_tween()
			tween.tween_property(matched_slot, "scale", Vector2(1.14, 1.14), 0.1)
			tween.tween_property(matched_slot, "scale", Vector2.ONE, 0.12)
		await get_tree().create_timer(0.23).timeout
		if not is_inside_tree():
			return
		for index in range(matching_slots.size() - 1, -1, -1):
			tray.remove_at(matching_slots[index])
		game_state = GameState.PLAYING
	else:
		message_label.text = "%sをトレーに入れたよ" % PRODUCT_NAMES[product_type]

	if _all_items_cleared():
		_finish_level(true)
	elif tray.size() >= SLOT_LIMIT:
		_finish_level(false)
	else:
		_refresh_interface()


func _all_items_cleared() -> bool:
	for item in board:
		if not bool(item["cleared"]):
			return false
	return true


func _finish_level(is_win: bool) -> void:
	if is_win:
		game_state = GameState.WON
		var reward := 25 + current_level * 5
		coins += reward
		if current_level < levels.size():
			max_unlocked_level = maxi(max_unlocked_level, current_level + 1)
		_save_progress()
		_refresh_interface()
		if current_level < levels.size():
			_show_overlay(
				"ステージクリア！",
				"おめでとう！\n%dコインを獲得しました。" % reward,
				NEXT_TEXTURE,
				_next_level,
				RETRY_TEXTURE,
				_restart_level,
				true
			)
		else:
			_show_overlay(
				"全ステージクリア！",
				"20ステージ達成！\n%dコインを獲得しました。" % reward,
				RETRY_TEXTURE,
				_restart_level,
				NEXT_TEXTURE,
				_restart_first_level,
				true
			)
	else:
		game_state = GameState.LOST
		_show_overlay(
			"トレーがいっぱい！",
			"同じ商品を3つそろえて、もう一度挑戦しよう。",
			RETRY_TEXTURE,
			_restart_level,
			NEXT_TEXTURE,
			_restart_first_level
		)


func _use_hint() -> void:
	if game_state != GameState.PLAYING:
		return
	var used_powerup: bool = int(powerups["hint"]) > 0
	if used_powerup:
		powerups["hint"] -= 1
	elif coins < 15:
		message_label.text = "コインが足りません（ヒントは15コイン）"
		return

	var suggested_type := -1
	var best_count := 0
	for item in board:
		if bool(item["cleared"]):
			continue
		var product_type: int = int(item["type"])
		var count_in_tray := 0
		for tray_type in tray:
			if tray_type == product_type:
				count_in_tray += 1
		if count_in_tray > best_count:
			best_count = count_in_tray
			suggested_type = product_type
	if suggested_type < 0:
		for item in board:
			if not bool(item["cleared"]):
				suggested_type = int(item["type"])
				break

	if suggested_type < 0:
		return
	for item in board:
		if not bool(item["cleared"]) and int(item["type"]) == suggested_type:
			hint_item_id = int(item["id"])
			break
	if not used_powerup:
		coins -= 15
	_save_progress()
	message_label.text = "%sを選ぶと整理しやすいよ" % PRODUCT_NAMES[suggested_type]
	_refresh_interface()


func _undo_move() -> void:
	if game_state != GameState.PLAYING:
		return
	if history.is_empty():
		message_label.text = "もどせる操作がありません"
		return
	var used_powerup: bool = int(powerups["undo"]) > 0
	if used_powerup:
		powerups["undo"] -= 1
	elif coins < 10:
		message_label.text = "コインが足りません（やり直しは10コイン）"
		return

	var previous: Dictionary = history.pop_back()
	board = previous["board"]
	tray = previous["tray"]
	if not used_powerup:
		coins -= 10
	hint_item_id = -1
	message_label.text = "ひとつ前の操作にもどしました"
	_save_progress()
	_refresh_interface()


func _shuffle_items() -> void:
	if game_state != GameState.PLAYING:
		return
	var used_powerup: bool = int(powerups["shuffle"]) > 0
	if used_powerup:
		powerups["shuffle"] -= 1
	elif coins < 20:
		message_label.text = "コインが足りません（シャッフルは20コイン）"
		return

	var active_indices: Array[int] = []
	var active_types: Array[int] = []
	for index in range(board.size()):
		if not bool(board[index]["cleared"]):
			active_indices.append(index)
			active_types.append(int(board[index]["type"]))
	if active_indices.size() < 2:
		return

	history.append({"board": board.duplicate(true), "tray": tray.duplicate()})
	var random := RandomNumberGenerator.new()
	random.randomize()
	_shuffle_with_rng(active_types, random)
	for index in range(active_indices.size()):
		board[active_indices[index]]["type"] = active_types[index]

	if not used_powerup:
		coins -= 20
	hint_item_id = -1
	message_label.text = "商品をシャッフルしました"
	_save_progress()
	_refresh_interface()


func _restart_level() -> void:
	_hide_overlay()
	_start_level(current_level)


func _restart_first_level() -> void:
	_hide_overlay()
	_start_level(1)


func _next_level() -> void:
	_hide_overlay()
	_start_level(mini(current_level + 1, levels.size()))


func _pause_game() -> void:
	if game_state != GameState.PLAYING:
		return
	game_state = GameState.PAUSED
	_show_overlay(
		"一時停止",
		"ひと休みして、また整理を続けよう。",
		null,
		_resume_game,
		RETRY_TEXTURE,
		_restart_level
	)


func _resume_game() -> void:
	game_state = GameState.PLAYING
	_hide_overlay()


func _show_overlay(
	title_text: String,
	body_text: String,
	primary_texture: Texture2D,
	primary_action: Callable,
	secondary_texture: Texture2D,
	secondary_action: Callable,
	show_stars := false
) -> void:
	overlay_title.text = title_text
	overlay_message.text = body_text
	overlay_stars.visible = show_stars
	_set_result_button(overlay_primary, primary_texture, primary_action, "つづける")
	_set_result_button(overlay_secondary, secondary_texture, secondary_action, "やり直す")
	overlay_home.visible = true
	overlay.visible = true


func _set_result_button(
	target: TextureButton,
	texture: Texture2D,
	action: Callable,
	fallback_text: String
) -> void:
	for connection in target.pressed.get_connections():
		target.pressed.disconnect(connection["callable"])
	target.texture_normal = texture
	target.get_node("FallbackBackground").visible = texture == null
	var caption: Label = target.get_node("Caption")
	caption.text = fallback_text if texture == null else ""
	target.pressed.connect(action)
	target.visible = true


func _result_button() -> TextureButton:
	var button := TextureButton.new()
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = Vector2(400, 96)
	var fallback_background := PanelContainer.new()
	fallback_background.name = "FallbackBackground"
	fallback_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fallback_style := StyleBoxFlat.new()
	fallback_style.bg_color = Color("#ffb83d")
	fallback_style.border_color = Color("#b17a48")
	fallback_style.set_border_width_all(3)
	fallback_style.set_corner_radius_all(24)
	fallback_background.add_theme_stylebox_override("panel", fallback_style)
	fallback_background.visible = false
	button.add_child(fallback_background)
	var caption := Label.new()
	caption.name = "Caption"
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 22)
	caption.add_theme_color_override("font_color", TEXT_COLOR)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(caption)
	return button


func _hide_overlay() -> void:
	overlay.visible = false


func _go_home() -> void:
	var error := get_tree().change_scene_to_file("res://scenes/home.tscn")
	if error != OK:
		push_error("ホーム画面を開けません: " + error_string(error))


func _set_anchors(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	control.anchor_left = left
	control.anchor_top = top
	control.anchor_right = right
	control.anchor_bottom = bottom


func _style_button(button: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#b17a48")
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	button.add_theme_stylebox_override("normal", style)
	var hover_style := style.duplicate()
	hover_style.bg_color = color.lightened(0.06)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", style)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if game_state == GameState.PLAYING:
			_pause_game()
		elif game_state == GameState.PAUSED:
			_resume_game()
