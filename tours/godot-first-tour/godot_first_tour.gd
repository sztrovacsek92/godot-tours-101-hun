extends "res://addons/godot_tours/core/tour.gd"

const TEXTURE_BUBBLE_BACKGROUND := preload("res://assets/bubble-background.png")
const TEXTURE_GDQUEST_LOGO := preload("res://assets/gdquest-logo.svg")

const CREDITS_FOOTER_GDQUEST := "[center]Godot Interactive Tours · Made by [url=https://www.gdquest.com/][b]GDQuest[/b][/url] · [url=https://github.com/GDQuest][b]Github page[/b][/url][/center]"

const LEVEL_RECT := Rect2(Vector2.ZERO, Vector2(1920, 1080))
const LEVEL_CENTER_AT := Vector2(960, 540)

# TODO: rather than being constant, these should probably scale with editor scale, and probably.
# be calculated relative to the position of some docks etc. in Godot. So that regardless of their
# resolution, people get the windows roughly in the same place.
# We should write a function for that.
#
# Position we set to popup windows relative to the editor's top-left. This helps to keep the popup
# windows outside of the bubble's area.
const POPUP_WINDOW_POSITION := Vector2i(150, 150)
# We limit the size of popup windows
const POPUP_WINDOW_MAX_SIZE := Vector2i(860, 720)

const ICONS_MAP = {
	node_position_unselected = "res://assets/icon_editor_position_unselected.svg",
	node_position_selected = "res://assets/icon_editor_position_selected.svg",
	script_signal_connected = "res://assets/icon_script_signal_connected.svg",
	script = "res://assets/icon_script.svg",
	script_indent = "res://assets/icon_script_indent.svg",
	zoom_in = "res://assets/icon_zoom_in.svg",
	zoom_out = "res://assets/icon_zoom_out.svg",
	open_in_editor = "res://assets/icon_open_in_editor.svg",
	node_signal_connected = "res://assets/icon_signal_scene_dock.svg",
}

var scene_completed_project := "res://completed_project.tscn"
var scene_start := "res://start.tscn"
var scene_player := "res://player/player.tscn"
var script_player := "res://player/player.gd"
var script_health_bar := "res://interface/bars/ui_health_bar.gd"
var room_scenes: Array[String] = [
	"res://levels/rooms/room_a.tscn",
	"res://levels/rooms/room_b.tscn",
	"res://levels/rooms/room_c.tscn",
]
var scene_background_sky := "res://levels/background/background_blue_sky.tscn"
var scene_health_bar := "res://interface/bars/ui_health_bar.tscn"
var scene_chest := "res://levels/rooms/chests/chest.tscn"
var script_chest := "res://levels/rooms/chests/chest.gd"


func _build() -> void:
	# Set editor state according to the tour's needs.
	queue_command(func reset_editor_state_for_tour():
		interface.canvas_item_editor_toolbar_grid_button.button_pressed = false
		interface.canvas_item_editor_toolbar_smart_snap_button.button_pressed = false
		interface.bottom_button_output.button_pressed = false
	)

	steps_010_intro()
	steps_020_first_look()
	steps_030_opening_scene()
	steps_040_scripts()
	steps_050_signals()
	steps_090_conclusion()


func steps_010_intro() -> void:

	# 0010: introduction
	context_set_2d()
	scene_open(scene_completed_project)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_background(TEXTURE_BUBBLE_BACKGROUND)
	bubble_add_texture(TEXTURE_GDQUEST_LOGO)
	bubble_set_title("")
	bubble_add_text([bbcode_wrap_font_size("[center][b]Üdvözöl a Godot Engine![/b][/center]", 32)])
	bubble_add_text(
		["[center]Ez a túra segít megtenni az első lépéseket\na [b]Godot Engine[/b]-ben.[/center]",
		"[center]Kapsz egy áttekintést a 4 alappillérről,\nmelyek a következők:\n[b]Scene[/b]-ek, [b]Node[/b]-ok, [b]Script[/b]-ek, és [b]Signal[/b]-ok.[/center]",
	"[center]A következő túrán majd létrehozod az első saját játékod, előre elkészített elemekből,\nhogy mindezt a gyakorlatban is lásd.[/center]",
	"[center][b]Vágjunk is bele![/b][/center]",]
	)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	queue_command(bubble.avatar.do_wink)
	complete_step()


	# 0020: First look at game you'll make
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title("Próbáld ki a játékot")
	bubble_add_text(
		["Ha először nyitsz meg egy projektet a Godot Engine-ben, akkor a [b]Main Scene[/b] lesz aktív. Ez a Godot játékok belépőpontja.",
		"Kattints a [b]Play[/b] ikonra az [b]Editor[/b] jobb felső sarkában, hogy elindítsd a játékot.",
		"Ezután nyomd meg az [b]F8[/b]-at a billentyűzeten, vagy zárd be az ablakot, hogy leállítsd a játékot.",]
	)
	complete_step()


	# 0030: Start of editor tour
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Az Editor")
	bubble_add_text(
		["Nagyszerű! Most járjuk körbe az [b]Editor[/b]-t.",]
	)
	queue_command(func():
		interface.bottom_button_output.button_pressed = false
	)
	complete_step()


func steps_020_first_look() -> void:
	# 0040: central viewport
	highlight_controls([interface.canvas_item_editor])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("A Viewport")
	bubble_add_text(
		["Az [b]Editor[/b] központi része a kékkel keretezett [b]Viewport[/b]. Itt láthatod az éppen nyitott [b]scene[/b]-t.",]
	)
	complete_step()


	# 0041: scene explanation
	highlight_controls([interface.canvas_item_editor])
	bubble_set_title("A scene egy sablon")
	bubble_add_text(
		["A Godot Engine-ben, a [b]scene[/b] egy sablon, ami lényegében bármi lehet: egy karakter, egy kincsesláda, egy pálya, egy menü, vagy akár egy egész játék!",
		"Jelenleg, egy [b]" + scene_completed_project.get_file() + "[/b] nevű [b]scene[/b]-t látunk. Ez a [b]scene[/b] egy egész játékot tartalmaz.",]
	)
	complete_step()

	# 0041: looking around
	highlight_controls([interface.scene_dock, interface.filesystem_dock, interface.inspector_dock, interface.context_switcher, interface.run_bar, interface.bottom_buttons])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Nézzünk körül")
	bubble_add_text(
		["Most nézzük a kezelőfelületet, hogy otthonosan tudj mozogni.",]
	)
	complete_step()


	# 0042: playback controls/game preview buttons
	highlight_controls([interface.run_bar], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Futtató gombok")
	bubble_add_text(["A jobb felső sarokban lévő gombok a futtató gombok. Segítségükkel elindíthatod ([b]F5 - Play[/b]) vagy leállíthatod ([b]F8 - Stop[/b]) a játékot."])
	complete_step()


	# 0042: main screen buttons / "context switcher"
	highlight_controls([interface.context_switcher], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Nézet váltó")
	bubble_add_text([
		"Az [b]Editor[/b] tetején középen találod a [b]Context Switcher[/b]-t (nézet váltó).",
		"Itt az [b]Editor[/b] különböző nézetei közt válthatsz. Jelelnleg a [b]2D View[/b] aktív. Később majd megnézzük a [b]Script Editor[/b]-t is!",
	])
	complete_step()


	# 0042: scene dock
	context_set_2d()
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("Scene Dock")
	bubble_add_text(["Balra fent található a [b]Scene Dock[/b]. Itt láthatod, miből épül fel az adott [b]scene[/b].",
		"A Godot Engine-ben ezeket az építőelemeket [b]node[/b]-oknak hívjuk.",
		"Egy [b]scene[/b] egy vagy több [b]node[/b]-ból épül fel.",
		"Vannak külön [b]node[/b]-ok képek kirajzolásásra, hangok lejátszására, animációk létrehozására, és még sok másra is.",
	])
	complete_step()


	# 0042: Filesystem dock
	highlight_controls([interface.filesystem_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.BOTTOM_LEFT)
	bubble_set_title("FileSystem Dock")
	bubble_add_text(["Balra lent pedig a [b]FileSystem Dock[/b] található. Ez minden a projektedben lévő fájlt kilistáz (minden scene-t, képet, scriptet, stb)."])
	complete_step()


	# 0044: inspector dock
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Az Inspector")
	bubble_add_text([
		"Jobb oldalon található az [b]Inspector Dock[/b]. Itt láthatod és szerkesztheted a kijelölt [b]node[/b]-ok tulajdonságait.",
	])
	complete_step()


	# 0045: inspector test
	scene_deselect_all_nodes()
	highlight_controls([interface.inspector_dock, interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_avatar_surprised()
	bubble_set_title("Próbáld ki")
	bubble_add_text([
		"Próbáld ki az [b]Inspector[/b]-t! Kattints a különböző [b]node[/b]-okra bal oldalon a [b]Scene Dock[/b]-ban, hogy láthasd a tulajdonságaikat a jobb oldalon lévő [b]Inspector[/b]-ban.",
	])
	mouse_click()
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Main")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Main/Bridges")),
	)
	mouse_click()
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Main/Bridges")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Main/Player")),
	)
	mouse_click()
	complete_step()


	# 0046: bottom panels
	highlight_controls([interface.debugger])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.BOTTOM_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Alsó panelek")
	bubble_add_text([
		"Lent különböző paneleket láthatsz, mint például az [b]Output[/b] vagy a [b]Debugger[/b] panel.",
		"Itt tudsz többek közt animációkat létrehozni vagy shader kódot írni.",
		"Ezek a panelek kontextus függők. A következó túrán majd kiderül, hogy ez mit is jelent pontosan.",
	])
	queue_command(func debugger_open():
		interface.bottom_button_debugger.button_pressed = true
	)
	complete_step()

	queue_command(func debugger_close():
		interface.bottom_button_debugger.button_pressed = false
	)



func steps_030_opening_scene() -> void:

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes(["Main", "Main/Bridges", "Main/InvisibleWalls", "Main/UILayer"])
	bubble_set_title("A teljes scene node-jai")
	bubble_add_text([
		"Ez a teljes játék [b]scene[/b] 4 [b]node[/b]-ból áll: [b]Main[/b], [b]Bridges[/b], [b]InvisibleWalls[/b], és [b]UILayer[/b].",
		"Ezt láthatjuk a [b]Scene Dock[/b]-ban, balra fent."
	])
	complete_step()


	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes(["Main/Player"])
	bubble_set_title("Scene példányok")
	bubble_add_text([
		"A többi [b]node[/b] mellett, mint például a [b]Player[/b], van egy [b]Open In Editor[/b] " +
		bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor) + " ikon.",
		"Ha ezt látod, akkor egy [b]scene példánnyal[/b] (instance) van dolgod. Ez egy már meglévő [b]scene[/b] másolata, de úgy is gondolhatsz rá, mint egy [b]scene[/b], ami egy másik [b]scene[/b]-t használ az alapjául. A Godot Engine-ben, ilyen példányok beágyazásával készítjük a játékokat.",
		"Kattints az [b]Open in Editor[/b] " + bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor) + " ikonra, a [b]Player node[/b] mellett a [b]Scene Dock[/b]-ban, hogy megnyisd a [b]Player scene[/b]-t.",
	])
	bubble_add_task(
		("Nyisd meg a [b]Player scene[/b]-t."),
		1,
		func task_open_start_scene(task: Task) -> int:
			var scene_root: Node = EditorInterface.get_edited_scene_root()
			if scene_root == null:
				return 0
			return 1 if scene_root.name == "Player" else 0
	)
	complete_step()


	context_set_2d()
	canvas_item_editor_center_at(Vector2.ZERO)
	canvas_item_editor_zoom_reset()
	highlight_controls([interface.scene_dock, interface.canvas_item_editor])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("A Player scene")
	bubble_add_text([
		"Amikor megnyitsz egy [b]scene[/b]-t, a [b]Scene Dock[/b] és a [b]Viewport[/b] is frissül, hogy az új [b]scene[/b]-t mutassa.",
		"Balra fent a [b]Scene Dock[/b]-ban láthatod az összes [b]node[/b]-ot, amiből a játékos karakter felépül.",
	])
	complete_step()



func steps_040_scripts() -> void:

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("A scriptek keltik életre a node-okat")
	bubble_add_text([
		"Önmagukban a [b]scene[/b]-ek és [b]node[/b]-ok nem túl interaktívak.",
		"Ahhoz, hogy életre keltsd őket, utasításokat kell adnod, azzal, hogy kódot írsz egy [b]script[/b] fájlba és azt csatolod a [b]node[/b]-hoz vagy [b]scene[/b]-hez.",
		"Nézzünk egy példa [b]script[/b]-et.",
	])
	complete_step()


	highlight_scene_nodes(["Player"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Nyisd meg Player scriptet")
	bubble_add_text([
		"A [b]Player node[/b]-hoz hozzá van rendelve egy [b]script[/b]. Ezt az [b]Attached Script[/b] " + bbcode_generate_icon_image_string(ICONS_MAP.script) + " ikon mutatja, a [b]node[/b] neve mellett jobbra.",
		"Kattints a [b]script[/b] ikonra, hogy megnyisd a [b]Player ccript[/b]-et a [b]Script Editor[/b]-ban.",
	])
	bubble_add_task(
		"Nyisd meg a [b]Player node[/b]-hoz kapcsolt [b]script[/b]-et.",
		1,
		func(task: Task) -> int:
			if not interface.is_in_scripting_context():
				return 0
			var open_script: String = EditorInterface.get_script_editor().get_current_script().resource_path
			return 1 if open_script == script_player else 0,
	)
	complete_step()


	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("A script nézet")
	bubble_add_text([
		"Most a [b]Script[/b] nézetben vagyunk, ahol láthatód a megnyitott [b]script[/b] fájlban lévő összes kódot.",
		"Ez a kód mondja meg a számítógépnek, hogyan mozgassa a játékost, mikor játszon le hangot, és még sok mást.",
		"Használd az egér görgőt vagy fogd meg a csúszkát a jobb oldalon, hogy fel-le görgesd a [b]script[/b] fájlt.",
	])
	complete_step()


	highlight_scene_nodes(["Player", "Player/GodotArmor", "Player/WeaponHolder", "Player/ShakingCamera2D"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("Bármelyik node-nak lehet scriptje")
	bubble_add_text([
		"Ha ismét balra nézünk, a [b]Scene Dock[/b]-ra, láthatjuk, hogy több [b]node[/b] mellett is ott a [b]script[/b] ikon.",
		"Annyi [b]node[/b]-hoz adhatsz [b]script[/b]-et, amennyihez csak szeretnél.",
	])
	complete_step()


func steps_050_signals() -> void:

	highlight_controls([interface.context_switcher], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Vissza a 2D nézetbe")
	bubble_add_text([
		"Még egy fontos pillére van a Godot Engine-nek: a [b]Signal[/b]-ok.",
		"Térjünk vissza a befejezett [b]scene[/b]-hez. Először kattints a [b]2D[/b] nézetre az [b]Editor[/b] tetején, hogy visszatérj a [b]script[/b] nézetből.",
		"Ez újra a játékost fogja mutatni.",
	])
	bubble_add_task(
		"Navigálj a [b]2D[/b] nézetre.",
		1,
		func task_navigate_to_2d_view(task: Task) -> int:
			return 1 if interface.canvas_item_editor.visible else 0
	)
	complete_step()

	context_set_2d()
	highlight_controls([interface.main_screen_tabs], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("Válts aktív scene-t")
	bubble_add_text([
		"Váltsuk át az aktív [b]scene[/b]-t a kész projekt [b]scene[/b]-re.",
		"Kattints a [b]completed_project[/b] fülre, a [b]Viewport[/b] felett, hogy átválts rá.",
	])
	bubble_add_task(
		"Navigálj a [b]Completed Project scene[/b]-re.",
		1,
		func task_open_completed_project_scene(task: Task) -> int:
			var scene_root: Node = EditorInterface.get_edited_scene_root()
			if scene_root == null:
				return 0
			return 1 if scene_root.name == "Main" else 0
	)
	complete_step()

	context_set_2d()
	scene_open(scene_completed_project)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Signal-ok")
	bubble_add_text([
		"A játékokban vannak gombok, ajtók, ládák, és millió más dolog amivel kapcsolatba léphetsz, és elvárod, hogy bizonyos módon reagáljon.",
		"Ehhez, ezeknek az elemeknek jelenteniük kell az interakciót a játéknak, hogy az végrehajtsa az adott eseményt.",
		"Ezt a jelentést [b]signal[/b] küldésnek hívjuk.",
	])
	complete_step()

	queue_command(overlays.highlight_scene_node.bind("Main/Player", true))
	highlight_controls([interface.node_dock_signals_editor])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Kattints a signal ikonra")
	bubble_add_text([
		"Figyeld meg a [b]Player node[/b]-ot a [b]Scene Dock[/b]-ban.",
		"Láthatod, hogy a [b]Signal Emission[/b] " + bbcode_generate_icon_image_string(ICONS_MAP.node_signal_connected) + " ikon kis hullámokat bocsájt ki. Ez az ikon jelzi, hogy az adott [b]node[/b]-hoz be van kötve egy signal.",
		"Kattints az ikonra, hogy megnyíljon jobb oldalon a [b]Node Dock[/b].",
	])
	bubble_add_task_set_tab_to_title(
		interface.inspector_tabs,
		"Node",
		"Kattints a [b]Player node[/b] melleti [b]signal[/b] ikonra, és nyisd meg a [b]Node Dock[/b]-ot.")
	complete_step()

	highlight_controls([interface.node_dock_signals_editor], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("A Node Dock")
	bubble_add_text([
		"Jobbra láthatod a [b]Node Dock[/b]-ot. Ez listázza a kijelölt [b]node[/b] összes [b]signal[/b]-ját. Esetünkben ez a [b]Player node[/b].",
		"A [b]signal[/b] lista elég hosszú: a [b]node[/b]-ok sokféle [b]signal[/b]-t bocsáthatnak ki, mert a játékban is sokféle esemény lehet, amire reagálni kell.",
	])
	complete_step()

	highlight_signals(["health_changed"], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("A health_changed signal")
	bubble_add_text([
		"A [b]Player node[/b]-nak van egy különösen hasznos [b]signal[/b]-ja: [b]health_changed[/b].",
		"A [b]health_changed signal[/b] tudatja velünk, mikor sebződik a karakter vagy tölti vissza az életerejét.",
	])
	complete_step()

	# Highlights the signal connection line
	highlight_signals(["../UILayer"], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("A signal kapcsolat")
	bubble_add_text([
		"Figyeld meg a [b]Connected Signal[/b] " + bbcode_generate_icon_image_string(ICONS_MAP.script_signal_connected) + " ikont a [b]signal[/b] alatt: ez jelzi, hogy az adott [b]signal[/b] hozzá van kötve egy [b]script[/b]-hez.",
		"Ez azt jelent, hogy mindig, amikor a játékos életereje csökken, a Godot le fogja futtatni a kapcsolódó kódrészletet.",
		"Ha a zöld ikonra duplán kattintunk, meg is nézhetjük azt.",
	])
	bubble_add_task(
		"Kattints duplán a [b]signal[/b] kapcsolatra a [b]Node Dock[/b]-ban.",
		1,
		func task_open_health_changed_signal_connection(task: Task) -> int:
			if not interface.is_in_scripting_context():
				return 0
			var open_script: String = EditorInterface.get_script_editor().get_current_script().resource_path
			return 1 if open_script == script_health_bar else 0,
	)
	complete_step()

	highlight_code(17, 24)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("A kapcsolódó kód")
	bubble_add_text([
		"Újra megnyílik a [b]Script Editor[/b] és a [b]set_health[/b] függvényhez ugrik.",
			"A függvény (function) egy olyan név, amivel több sornyi kódot nevezhetünk el és használhatunk újra: más helyeken ezután elég csak a függvény nevét használni, hogy végrehajtassuk a benne foglalt több sornyi kódot.",
	])
	complete_step()

	# Highlight the set_health function, don't re-center on it to avoid a jump after the previous
	# slide.
	highlight_code(17, 17, 0, false, false)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title("A set_health függvény")
	bubble_add_text([
		"Ez a függvény a játékos életerő csíkját frissíti.",
		"Figyeld meg a zöld [b]Connected Signal[/b] " + bbcode_generate_icon_image_string(ICONS_MAP.script_signal_connected) + " ikont a [b]Script Editor[/b] bal margóján. Amikor kódot írsz, ez emlékeztet a már létező [b]signal[/b] kapcsolatra.",
		"Tehát, minden alkalommal, amikor a játékos életereje változik, a [b]Player node[/b] kibocsájtja a [b]health_changed signal[/b]-t, erre válaszul pedig a Godot lefuttatja a [b]set_health[/b] függvényt, ami frissíti az életerő jelző csíkot a futó játékban.",
	])
	complete_step()

	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title("Futtasd a játékot")
	bubble_add_text(
		["Indítsd el megint a játékot, és figyeld meg az életerő csíkot a bal felső sarokban.",
		"Mozgasd a játékost egy ellenfélhez, hogy megsebezze. Látni fogod, hogy az életereje 1-gyel csökken.",
		"Ez a [b]health_changed signal[/b] kapcsolatnak köszönhetően történik meg.",]
	)
	complete_step()

	queue_command(func debugger_close():
		interface.bottom_button_debugger.button_pressed = false
	)


func steps_090_conclusion() -> void:

	context_set_2d()
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title("Összegzés")
	bubble_add_text(
		[
			"A Godot engine 4 alappillére tehát:\n",
			"[b]Scene[/b]-ek: újrafelhasználható sablonok, amik bármit jelképezhetnek a játékodban.",
			"[b]Node[/b]-ok: a scene-ek építőelemei. Ezeket látod a [b]Viewport[/b]-ban.",
			"[b]Script[/b]-ek: szövegfájlok, amelyek utasításokat adnak a számítógépnek. Node-okhoz rendelheted őket, hogy irányítsd a viselkedésüket.",
			"[b]Signal[/b]-ok: olyan események, amelyeket a node-ok bocsájtanak ki, hogy tudassák, mi történik éppen a játékban. A signalokat scriptekhez kapcsolhatod, hogy lefuttass egy kódot, ha az adott esemény megtörténik.",
		]
	)
	complete_step()


	bubble_move_and_anchor(interface.main_screen)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_avatar_happy()
	bubble_set_background(TEXTURE_BUBBLE_BACKGROUND)
	bubble_add_texture(TEXTURE_GDQUEST_LOGO)
	bubble_set_title("Gratulálunk az első Godot túrádhoz!")
	bubble_add_text([("[center]Legközelebb többet is tanulunk,\negy játék elkészítésének lépésein keresztül[/center]")])
	# TODO: add video of other parts here if on free version
	bubble_set_footer((CREDITS_FOOTER_GDQUEST))
	complete_step()

