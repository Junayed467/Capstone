extends Node2D

@export var obstacle_scene: PackedScene
@export var bpm: int = 120

var beat_interval := 0.0
var time_tracker := 0.0
var score := 0

enum State { TITLE, TUTORIAL, PLAYING, GAME_OVER }
var state: State = State.TITLE

@onready var title_ui: Control = $CanvasLayer/TitleUI
@onready var tutorial_ui: Control = $CanvasLayer/TutorialUI
@onready var game_over_ui: Control = $CanvasLayer/GameOverUI
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var player: Node = $Player

func _ready() -> void:
	randomize()
	add_to_group("game_manager")
	beat_interval = 60.0 / float(bpm)

	_set_state(State.TITLE)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("restart"): # your Space action
		return

	match state:
		State.TITLE:
			_set_state(State.TUTORIAL)
		State.TUTORIAL:
			start_game()
		State.GAME_OVER:
			_set_state(State.TITLE)
		State.PLAYING:
			pass

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	time_tracker += delta
	if time_tracker >= beat_interval:
		time_tracker -= beat_interval
		spawn_obstacle()
		score += 1
		score_label.text = str(score)

func _set_state(new_state: State) -> void:
	state = new_state

	title_ui.visible = (state == State.TITLE)
	tutorial_ui.visible = (state == State.TUTORIAL)
	game_over_ui.visible = (state == State.GAME_OVER)
	score_label.visible = (state == State.PLAYING)

	player.visible = (state == State.PLAYING)
	player.set_process_input(state == State.PLAYING)

	if state != State.PLAYING:
		$MusicPlayer.stop()

func start_game() -> void:
	# reset gameplay
	score = 0
	time_tracker = 0.0
	score_label.text = "0"

	get_tree().call_group("obstacles", "queue_free")

	# reset player
	$Player.current_lane = 1
	$Player.update_position()

	if $MusicPlayer.stream:
		$MusicPlayer.play()

	_set_state(State.PLAYING)

func spawn_obstacle() -> void:
	var obs = obstacle_scene.instantiate()
	var lane_idx = randi() % 3
	var x_pos = [90, 270, 450][lane_idx]
	obs.position = Vector2(x_pos, -100)
	add_child(obs)

func game_over() -> void:
	get_tree().call_group("obstacles", "queue_free")
	$MusicPlayer.stop()
	_set_state(State.GAME_OVER)
