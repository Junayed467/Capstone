extends Node2D

@export var obstacle_scene: PackedScene
@export var bpm: int = 120

var beat_interval: float
var time_tracker: float = 0.0
var score: int = 0

enum State { TITLE, TUTORIAL, PLAYING, GAME_OVER }
var state: State = State.TITLE

func _ready() -> void:
	randomize()
	add_to_group("game_manager")

	beat_interval = 60.0 / float(bpm)

	_set_state(State.TITLE)

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	time_tracker += delta

	if time_tracker >= beat_interval:
		time_tracker -= beat_interval
		spawn_obstacle()
		score += 1
		$CanvasLayer/ScoreLabel.text = str(score)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("restart"):
		return

	match state:
		State.TITLE:
			_set_state(State.TUTORIAL)

		State.TUTORIAL:
			start_game()

		State.PLAYING:
			pass

		State.GAME_OVER:
			_set_state(State.TITLE)

func _set_state(new_state: State) -> void:
	state = new_state

	# Always explicitly set UI visibility (no accidental leftovers).
	$CanvasLayer/StartUI.visible = (state == State.TITLE)
	$CanvasLayer/TutorialUI.visible = (state == State.TUTORIAL)
	$CanvasLayer/GameOverUI.visible = (state == State.GAME_OVER)
	$CanvasLayer/ScoreLabel.visible = (state == State.PLAYING)

	# Optional: If you have TitleUI separately, show it only on TITLE:
	if has_node("CanvasLayer/TitleUI"):
		$CanvasLayer/TitleUI.visible = (state == State.TITLE)

	# Only allow lane input during gameplay (prevents “menu presses move lanes”).
	$Player.visible = (state == State.PLAYING)
	$Player.set_process_input(state == State.PLAYING)

	# Music control
	if state == State.PLAYING:
		if $MusicPlayer.stream:
			$MusicPlayer.play()
	else:
		$MusicPlayer.stop()

func start_game() -> void:
	# reset gameplay vars
	state = State.PLAYING
	score = 0
	time_tracker = 0.0
	$CanvasLayer/ScoreLabel.text = "0"

	# reset player
	$Player.current_lane = 1
	$Player.update_position()

	# clear any old obstacles (in case)
	get_tree().call_group("obstacles", "queue_free")

	_set_state(State.PLAYING)

func spawn_obstacle() -> void:
	var obs = obstacle_scene.instantiate()
	var lane_idx = randi() % 3
	var x_pos = [90, 270, 450][lane_idx]
	obs.position = Vector2(x_pos, -100)
	add_child(obs)

func game_over() -> void:
	# stop gameplay + clear obstacles
	get_tree().call_group("obstacles", "queue_free")
	_set_state(State.GAME_OVER)
