extends Control

const SAVE_PATH := "user://progress.cfg"
const GAME_SCENE := "res://scenes/game.tscn"
const LOGO_TEXTURE: Texture2D = preload("res://assets/ui/logo/logo_main.png")
const START_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_start.png")
const START_PRESSED_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_start_pressed.png")
const SHOP_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_shop.png")
const SETTINGS_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_settings.png")
const SLOT_TEXTURE: Texture2D = preload("res://assets/ui/panels/inventory_slot.png")
const COIN_TEXTURE: Texture2D = preload("res://assets/ui/icons/icon_coin.png")
const FEATURED_PRODUCTS := [
	preload("res://assets/items/onigiri/item_onigiri_salmon.png"),
	preload("res://assets/items/drinks/item_drink_tea.png"),
	preload("res://assets/items/sweets/item_pudding.png"),
]

var popup: ColorRect
var popup_title: Label
var popup_body: Label
var popup_content: VBoxContainer
var coin_label: Label
const TEXT_COLOR := Color("#65452f")


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#fff3db")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 82)
	margin.add_theme_constant_override("margin_bottom", 100)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	margin.add_child(layout)

	var top_bar := HBoxContainer.new()
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	layout.add_child(top_bar)

	var coin_icon := PanelContainer.new()
	coin_icon.custom_minimum_size = Vector2(48, 48)
	var coin_style := StyleBoxFlat.new()
	coin_style.bg_color = Color("#ffb83d")
	coin_style.border_color = Color("#b17a48")
	coin_style.set_border_width_all(3)
	coin_style.set_corner_radius_all(24)
	coin_icon.add_theme_stylebox_override("panel", coin_style)
	top_bar.add_child(coin_icon)

	var coin_mark := TextureRect.new()
	coin_mark.texture = COIN_TEXTURE
	coin_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin_icon.add_child(coin_mark)

	coin_label = Label.new()
	coin_label.text = str(_saved_coins())
	coin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coin_label.add_theme_font_size_override("font_size", 25)
	coin_label.add_theme_color_override("font_color", Color("#65452f"))
	top_bar.add_child(coin_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)

	var logo := TextureRect.new()
	logo.texture = LOGO_TEXTURE
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(0, 340)
	logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(logo)

	var tagline := Label.new()
	tagline.text = "お店の商品を楽しく整理しよう！"
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.add_theme_font_size_override("font_size", 24)
	tagline.add_theme_color_override("font_color", Color("#65452f"))
	layout.add_child(tagline)

	var featured_row := HBoxContainer.new()
	featured_row.alignment = BoxContainer.ALIGNMENT_CENTER
	featured_row.add_theme_constant_override("separation", 20)
	featured_row.custom_minimum_size = Vector2(0, 96)
	layout.add_child(featured_row)
	for product_texture in FEATURED_PRODUCTS:
		var product := TextureRect.new()
		product.texture = product_texture
		product.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		product.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		product.custom_minimum_size = Vector2(84, 84)
		product.mouse_filter = Control.MOUSE_FILTER_IGNORE
		featured_row.add_child(product)

	var middle_spacer := Control.new()
	middle_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(middle_spacer)

	var start_button := _texture_button(START_TEXTURE, Vector2(480, 128))
	start_button.texture_pressed = START_PRESSED_TEXTURE
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.pressed.connect(_start_game)
	layout.add_child(start_button)

	var secondary_buttons := HBoxContainer.new()
	secondary_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	secondary_buttons.add_theme_constant_override("separation", 18)
	layout.add_child(secondary_buttons)

	var shop_button := _texture_button(SHOP_TEXTURE, Vector2(230, 104))
	shop_button.pressed.connect(_show_shop)
	secondary_buttons.add_child(shop_button)

	var settings_button := _texture_button(SETTINGS_TEXTURE, Vector2(230, 104))
	settings_button.pressed.connect(_show_settings)
	secondary_buttons.add_child(settings_button)

	var daily_button := Button.new()
	daily_button.text = "🎁  デイリーボーナスを受け取る"
	daily_button.custom_minimum_size = Vector2(0, 64)
	daily_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	daily_button.add_theme_font_size_override("font_size", 20)
	daily_button.add_theme_color_override("font_color", TEXT_COLOR)
	_style_button(daily_button, Color("#ff91aa"))
	daily_button.pressed.connect(_claim_daily_bonus)
	layout.add_child(daily_button)

	_build_popup()


func _build_popup() -> void:
	popup = ColorRect.new()
	popup.color = Color(0.20, 0.15, 0.10, 0.52)
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.visible = false
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 520)
	var style := StyleBoxTexture.new()
	style.texture = SLOT_TEXTURE
	style.texture_margin_left = 28
	style.texture_margin_right = 28
	style.texture_margin_top = 28
	style.texture_margin_bottom = 28
	style.draw_center = true
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	popup_content = VBoxContainer.new()
	popup_content.add_theme_constant_override("separation", 16)
	panel.add_child(popup_content)

	popup_title = Label.new()
	popup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_title.add_theme_font_size_override("font_size", 30)
	popup_title.add_theme_color_override("font_color", Color("#65452f"))
	popup_content.add_child(popup_title)

	popup_body = Label.new()
	popup_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_body.add_theme_font_size_override("font_size", 21)
	popup_body.add_theme_color_override("font_color", Color("#65452f"))
	popup_content.add_child(popup_body)

	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "とじる"
	close_button.custom_minimum_size = Vector2(0, 64)
	close_button.add_theme_font_size_override("font_size", 22)
	close_button.add_theme_color_override("font_color", Color("#65452f"))
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("#ffb83d")
	button_style.set_corner_radius_all(20)
	close_button.add_theme_stylebox_override("normal", button_style)
	close_button.pressed.connect(_close_popup)
	popup_content.add_child(close_button)


func _show_popup(title_text: String, body_text: String) -> void:
	_clear_popup_options()
	popup_title.text = title_text
	popup_body.text = body_text
	popup.visible = true


func _close_popup() -> void:
	popup.visible = false


func _show_shop() -> void:
	_show_popup("ショップ", "コインで便利な道具をストックできます。\nゲーム中は所持アイテムが優先して使われます。")
	_add_popup_option("💡 ヒント ×1　15 コイン", _purchase.bind("hint", 15))
	_add_popup_option("↩ もどす ×1　10 コイン", _purchase.bind("undo", 10))
	_add_popup_option("🔀 シャッフル ×1　20 コイン", _purchase.bind("shuffle", 20))


func _show_settings() -> void:
	_show_popup("設定", "オン／オフの設定はこの端末に保存されます。")
	var config := _load_config()
	_add_popup_option("BGM: %s" % ("オン" if bool(config.get_value("settings", "bgm", true)) else "オフ"), _toggle_setting.bind("bgm"))
	_add_popup_option("効果音: %s" % ("オン" if bool(config.get_value("settings", "sfx", true)) else "オフ"), _toggle_setting.bind("sfx"))
	_add_popup_option("バイブレーション: %s" % ("オン" if bool(config.get_value("settings", "vibration", true)) else "オフ"), _toggle_setting.bind("vibration"))


func _claim_daily_bonus() -> void:
	var config := _load_config()
	var today := Time.get_date_string_from_system()
	if str(config.get_value("rewards", "last_daily", "")) == today:
		_show_popup("デイリーボーナス", "今日はもう受け取り済みです。\nまた明日、遊びに来てね！")
		return
	var new_coins := maxi(0, int(config.get_value("progress", "coins", 100))) + 30
	config.set_value("progress", "coins", new_coins)
	config.set_value("rewards", "last_daily", today)
	_save_config(config)
	coin_label.text = str(new_coins)
	_show_popup("デイリーボーナス", "30コインを受け取りました！")


func _purchase(powerup_name: String, price: int) -> void:
	var config := _load_config()
	var current_coins := maxi(0, int(config.get_value("progress", "coins", 100)))
	if current_coins < price:
		_show_popup("コインが足りません", "この道具には%dコイン必要です。" % price)
		return
	config.set_value("progress", "coins", current_coins - price)
	config.set_value("powerups", powerup_name, int(config.get_value("powerups", powerup_name, 0)) + 1)
	_save_config(config)
	coin_label.text = str(current_coins - price)
	_show_popup("購入しました！", "ゲーム画面で「%s」を使えます。" % {"hint": "ヒント", "undo": "もどす", "shuffle": "シャッフル"}[powerup_name])


func _toggle_setting(setting_name: String) -> void:
	var config := _load_config()
	config.set_value("settings", setting_name, not bool(config.get_value("settings", setting_name, true)))
	_save_config(config)
	_show_settings()


func _add_popup_option(label_text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0, 54)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", TEXT_COLOR)
	_style_button(button, Color("#7bd99a"))
	button.pressed.connect(action)
	popup_content.add_child(button)
	popup_content.move_child(button, popup_content.get_child_count() - 2)


func _clear_popup_options() -> void:
	for child in popup_content.get_children():
		if child.name == "CloseButton" or child == popup_title or child == popup_body:
			continue
		popup_content.remove_child(child)
		child.queue_free()


func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_error("セーブデータを読み込めません: " + error_string(error))
	return config


func _save_config(config: ConfigFile) -> void:
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("セーブデータを保存できません: " + error_string(error))


func _start_game() -> void:
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		push_error("ゲーム画面を開けません: " + error_string(error))
		_show_popup("ゲームを開けません", "画面の読み込みに失敗しました。\nエラー: %s" % error_string(error))


func _saved_coins() -> int:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return 100
	if error != OK:
		push_error("セーブデータを読み込めません: " + error_string(error))
		return 100
	return maxi(0, int(config.get_value("progress", "coins", 100)))


func _texture_button(texture: Texture2D, size: Vector2) -> TextureButton:
	var button := TextureButton.new()
	button.texture_normal = texture
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = size
	return button


func _style_button(button: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.border_color = Color("#b17a48")
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(18)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.06)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", normal)
