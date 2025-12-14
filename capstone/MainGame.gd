extends Node2D

@export var obstacle_scene: PackedScene
@export var bpm: int = 120

var beat_interval: float = 0.0
var time_tracker: float = 0.0
var score: int = 0

enum GameState { TITLE, TUTORIAL, PLAYING, GAME_OVER }
var state: GameState = GameState.TITLE

@onready var road: Sprite2D = $Road


func _ready() -> void:
	randomize()
	add_to_group("game_manager")
	beat_interval = 60.0 / float(bpm)
	_set_state(GameState.TITLE)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("restart"):
		return

	match state:
		GameState.TITLE:
			_set_state(GameState.TUTORIAL)
		GameState.TUTORIAL:
			start_game()
		GameState.GAME_OVER:
			_set_state(GameState.TITLE)
		GameState.PLAYING:
			pass


func _process(delta: float) -> void:
	if state != GameState.PLAYING:
		return

	time_tracker += delta
	if time_tracker >= beat_interval:
		time_tracker -= beat_interval
		spawn_obstacle()
		score += 1
		$CanvasLayer/ScoreLabel.text = str(score)


func _set_state(new_state: GameState) -> void:
	state = new_state

	$CanvasLayer/TitleUI.visible = (state == GameState.TITLE)
	$CanvasLayer/TutorialUI.visible = (state == GameState.TUTORIAL)
	$CanvasLayer/GameOverUI.visible = (state == GameState.GAME_OVER)
	$CanvasLayer/ScoreLabel.visible = (state == GameState.PLAYING)

	$Player.visible = (state == GameState.PLAYING)
	$Player.set_process_input(state == GameState.PLAYING)

	_show_world(state == GameState.PLAYING)

	if state != GameState.PLAYING:
		$MusicPlayer.stop()


func _show_world(visible: bool) -> void:
	get_tree().call_group("world", "set_visible", visible)


# ---- NEW: lane math based on Road sprite ----
func get_lane_centers() -> Array[float]:
	if road.texture == null:
		# fallback if something is wrong
		return [90.0, 270.0, 450.0]

	var tex_w := float(road.texture.get_width())
	var road_w := tex_w * road.scale.x

	# Road's left edge in global coords
	var left := road.global_position.x - (road_w * 0.5)

	# 3 lane centers evenly spaced across road width (1/6, 3/6, 5/6)
	return [
		left + road_w * (1.0/6.0),
		left + road_w * (3.0/6.0),
		left + road_w * (5.0/6.0)
	]


func start_game() -> void:
	score = 0
	time_tracker = 0.0
	$CanvasLayer/ScoreLabel.text = "0"

	get_tree().call_group("obstacles", "queue_free")

	# Reset Player lane and position using NEW lane centers
	var lanes := get_lane_centers()
	$Player.current_lane = 1
	$Player.set_lane_centers(lanes)

	if $MusicPlayer.stream:
		$MusicPlayer.play()

	_set_state(GameState.PLAYING)


func spawn_obstacle() -> void:
	var obs = obstacle_scene.instantiate()

	var lanes := get_lane_centers()
	var lane_idx := randi() % 3
	var x_pos := lanes[lane_idx]

	# optional small jitter inside lane (keeps it natural)
	x_pos += randf_range(-20.0, 20.0)

	obs.position = Vector2(x_pos, -100)
	add_child(obs)


func game_over() -> void:
	$MusicPlayer.stop()
	get_tree().call_group("obstacles", "queue_free")
	_set_state(GameState.GAME_OVER)
