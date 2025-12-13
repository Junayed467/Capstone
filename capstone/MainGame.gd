extends Node2D

@export var obstacle_scene: PackedScene # Drag Obstacle.tscn here
@export var bpm: int = 120 # Matches your music

var beat_interval: float = 0.0
var time_tracker: float = 0.0
var score: int = 0
var game_active: bool = false

# NEW: tracks whether we're currently on the tutorial screen
var tutorial_active: bool = false

func _ready():
	randomize()
	# Register this node to the "game_manager" group so Obstacles can find it
	add_to_group("game_manager")
	
	beat_interval = 60.0 / float(bpm)
	
	# SETUP UI FOR START
	$CanvasLayer/GameOverUI.hide()
	$CanvasLayer/StartUI.show()
	$CanvasLayer/TutorialUI.hide()
	$Player.hide()

func _process(delta):
	if !game_active:
		# If tutorial is showing, Space should start the game
		if tutorial_active:
			if Input.is_action_just_pressed("restart"):
				start_game()
			return
		
		# GAME START LOGIC (first input)
		if Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			$CanvasLayer/TitleUI.hide()
			$CanvasLayer/StartUI.hide()
			$CanvasLayer/TutorialUI.show()
			tutorial_active = true
		return

	# GAMEPLAY LOOP
	time_tracker += delta
	
	# Spawn on the Beat
	if time_tracker >= beat_interval:
		time_tracker -= beat_interval
		spawn_obstacle()
		score += 1
		$CanvasLayer/ScoreLabel.text = str(score)

func start_game():
	# Hide tutorial now that we're starting gameplay
	$CanvasLayer/TutorialUI.hide()
	tutorial_active = false
	
	game_active = true
	score = 0
	time_tracker = 0.0
	
	# Reset UI
	$CanvasLayer/GameOverUI.hide()
	$CanvasLayer/ScoreLabel.text = "0"
	$CanvasLayer/ScoreLabel.show()
	
	# Reset Player
	$Player.show()
	$Player.current_lane = 1
	$Player.update_position()
	
	# Play Music
	if $MusicPlayer.stream:
		$MusicPlayer.play()

func spawn_obstacle():
	var obs = obstacle_scene.instantiate()
	
	# Pick random lane
	var lane_idx = randi() % 3
	var x_pos = [90, 270, 450][lane_idx] # Must match Player.gd positions
	
	obs.position = Vector2(x_pos, -100)
	add_child(obs)

func game_over():
	game_active = false
	$MusicPlayer.stop()
	
	# Clear existing obstacles
	get_tree().call_group("obstacles", "queue_free")
	
	$CanvasLayer/GameOverUI.show()
	$CanvasLayer/ScoreLabel.hide()
