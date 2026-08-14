extends Control
class_name GameHistory


## Scene entry point initializing history list and window resize handler.
func _ready():
	get_tree().get_root().size_changed.connect(self.resize)
	self.resize()
	self.populate_history()


## Populates scrollable list with cards for each recorded match in Globals.game_history.
func populate_history() -> void:
	var list_container = $MarginContainer/VBoxContainer/ScrollContainer/ListContainer
	for child in list_container.get_children():
		child.queue_free()
		
	if Globals.game_history.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = tr("No games logged yet")
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.custom_minimum_size = Vector2(0, 150)
		empty_lbl.add_theme_font_size_override("font_size", 24)
		list_container.add_child(empty_lbl)
		return

	for entry in Globals.game_history:
		var card = PanelContainer.new()
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.12, 0.14, 0.18, 0.95)
		card_style.corner_radius_top_left = 12
		card_style.corner_radius_top_right = 12
		card_style.corner_radius_bottom_left = 12
		card_style.corner_radius_bottom_right = 12
		card_style.content_margin_left = 16
		card_style.content_margin_top = 14
		card_style.content_margin_right = 16
		card_style.content_margin_bottom = 14
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 2
		
		var winner_id = entry.get("winner_id", 0)
		var winner_color = Globals.ePlayer2Color(winner_id)
		card_style.border_color = winner_color.lerp(Color.WHITE, 0.3)
		card.add_theme_stylebox_override("panel", card_style)
		
		var main_vbox = VBoxContainer.new()
		main_vbox.add_theme_constant_override("separation", 10)
		
		# --- Header Row: Date/Time, Max Players & Duration ---
		var header_hbox = HBoxContainer.new()
		var datetime_lbl = Label.new()
		datetime_lbl.text = "📅  " + str(entry.get("datetime", ""))
		datetime_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		datetime_lbl.add_theme_font_size_override("font_size", 18)
		header_hbox.add_child(datetime_lbl)
		
		var max_players = entry.get("max_players", 4)
		var board_lbl = Label.new()
		board_lbl.text = "🎯  " + str(max_players) + " " + tr("players board") + "   "
		board_lbl.add_theme_font_size_override("font_size", 18)
		board_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		header_hbox.add_child(board_lbl)
		
		var duration_lbl = Label.new()
		duration_lbl.text = "⏱️  " + tr("Duration: {0}").format([str(entry.get("duration_str", "00:00"))])
		duration_lbl.add_theme_font_size_override("font_size", 18)
		duration_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
		header_hbox.add_child(duration_lbl)
		main_vbox.add_child(header_hbox)
		
		# --- Winner Banner Row ---
		var winner_hbox = HBoxContainer.new()
		var winner_badge = PanelContainer.new()
		var winner_style = StyleBoxFlat.new()
		winner_style.bg_color = winner_color.darkened(0.2)
		winner_style.corner_radius_top_left = 8
		winner_style.corner_radius_top_right = 8
		winner_style.corner_radius_bottom_left = 8
		winner_style.corner_radius_bottom_right = 8
		winner_style.content_margin_left = 12
		winner_style.content_margin_top = 6
		winner_style.content_margin_right = 12
		winner_style.content_margin_bottom = 6
		winner_badge.add_theme_stylebox_override("panel", winner_style)
		
		var winner_lbl = Label.new()
		winner_lbl.text = "🏆 " + tr("Winner") + ": " + str(entry.get("winner_name", ""))
		winner_lbl.add_theme_font_size_override("font_size", 18)
		winner_lbl.add_theme_color_override("font_color", Color.WHITE)
		winner_badge.add_child(winner_lbl)
		winner_hbox.add_child(winner_badge)
		main_vbox.add_child(winner_hbox)
		
		# --- Graphical Composition Row ---
		var comp_lbl = Label.new()
		comp_lbl.text = tr("Composition") + ":"
		comp_lbl.add_theme_font_size_override("font_size", 14)
		comp_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
		main_vbox.add_child(comp_lbl)
		
		var comp_hbox = HBoxContainer.new()
		comp_hbox.add_theme_constant_override("separation", 8)
		
		var composition = entry.get("composition", [])
		for p_data in composition:
			var p_id = p_data.get("id", 0)
			var p_name = p_data.get("name", "")
			var p_ia = p_data.get("ia", false)
			var p_plays = p_data.get("plays", true)
			var p_color = Globals.ePlayer2Color(p_id)
			
			var slot_badge = PanelContainer.new()
			var slot_style = StyleBoxFlat.new()
			if p_plays:
				slot_style.bg_color = p_color.darkened(0.5)
				slot_style.border_color = p_color
				slot_style.border_width_left = 1
				slot_style.border_width_top = 1
				slot_style.border_width_right = 1
				slot_style.border_width_bottom = 1
			else:
				slot_style.bg_color = Color(0.18, 0.18, 0.22, 0.5)
				slot_style.border_color = Color(0.3, 0.3, 0.35)
				
			slot_style.corner_radius_top_left = 6
			slot_style.corner_radius_top_right = 6
			slot_style.corner_radius_bottom_left = 6
			slot_style.corner_radius_bottom_right = 6
			slot_style.content_margin_left = 10
			slot_style.content_margin_top = 4
			slot_style.content_margin_right = 10
			slot_style.content_margin_bottom = 4
			slot_badge.add_theme_stylebox_override("panel", slot_style)
			
			var slot_lbl = Label.new()
			if not p_plays:
				slot_lbl.text = p_name + " (❌ " + tr("Disabled") + ")"
				slot_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
			elif p_ia:
				slot_lbl.text = p_name + " (🤖 IA)"
				slot_lbl.add_theme_color_override("font_color", Color.WHITE)
			else:
				slot_lbl.text = p_name + " (👤 " + tr("Human") + ")"
				slot_lbl.add_theme_color_override("font_color", Color.WHITE)
				
			slot_lbl.add_theme_font_size_override("font_size", 14)
			slot_badge.add_child(slot_lbl)
			comp_hbox.add_child(slot_badge)
			
		main_vbox.add_child(comp_hbox)
		card.add_child(main_vbox)
		list_container.add_child(card)


## Return button click handler navigating back to Main.tscn.
func _on_Return_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Window resize callback.
func resize():
	pass
