extends Node2D

# Exported variables allow you to tweak gameplay from the editor.
@export var obstacle_scene: PackedScene # Reference to Obstacle.tscn
@export var bpm: int = 120               # Beats per minute of the soundtrack
@export var obstacle_speed: float = 600.0 # Movement speed for obstacles

# Internal state variables.
var _time_tracker: float = 0.0
var _beat_interval: float = 0.5
var _game_running: bool = false
var _score: int = 0

func _ready() -> void:
    """Initialize the game state and connect UI signals.

    The beat interval is calculated from the BPM.  UI elements are shown
    or hidden according to the starting state.  A connection is set up
    for the retry button to reload the current scene on press.
    """
    randomize()
    if bpm > 0:
        _beat_interval = 60.0 / float(bpm)
    # Ensure the RetryButton and TutorialLabel exist before configuring them.
    if $CanvasLayer.has_node("RetryButton"):
        $CanvasLayer/RetryButton.visible = false
        $CanvasLayer/RetryButton.connect("pressed", Callable(self, "_on_retry_button_pressed"))
    if $CanvasLayer.has_node("TutorialLabel"):
        $CanvasLayer/TutorialLabel.visible = true
    if $CanvasLayer.has_node("ScoreLabel"):
        $CanvasLayer/ScoreLabel.text = "Score: 0"


func _process(delta: float) -> void:
    """Advance the beat timer and spawn obstacles while the game is running."""
    if not _game_running:
        return
    _time_tracker += delta
    if _time_tracker >= _beat_interval:
        _time_tracker -= _beat_interval
        _spawn_obstacle()
        _increment_score()


func _unhandled_input(event: InputEvent) -> void:
    """Start the game on the first player input.

    When the game is not yet running any left/right key press will
    trigger `start_game()`.  After the game has started input is
    handled by the Player node.
    """
    if not _game_running:
        if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
            start_game()


func start_game() -> void:
    """Transition from the tutorial state into active play."""
    _game_running = true
    _time_tracker = 0.0
    _score = 0
    # Hide tutorial instructions and reset score.
    if $CanvasLayer.has_node("TutorialLabel"):
        $CanvasLayer/TutorialLabel.visible = false
    if $CanvasLayer.has_node("ScoreLabel"):
        $CanvasLayer/ScoreLabel.text = "Score: 0"
    if $CanvasLayer.has_node("RetryButton"):
        $CanvasLayer/RetryButton.visible = false
    # Reset position of the player to the center lane.
    var player := $Player
    if player and player.has_method("change_lane"):
        player.current_lane = 1
        player.position = Vector2(player.lane_positions[1], 800.0)
    # Start music playback if configured.
    if $AudioStreamPlayer and $AudioStreamPlayer.stream:
        $AudioStreamPlayer.play()


func _spawn_obstacle() -> void:
    """Instantiate an obstacle and add it to the scene."""
    if obstacle_scene == null:
        return
    var obstacle := obstacle_scene.instantiate()
    # Choose a random lane position matching the player's lane positions.
    var lanes: Array = [100.0, 270.0, 440.0]
    var lane_idx: int = randi() % lanes.size()
    obstacle.position = Vector2(lanes[lane_idx], -50.0)
    obstacle.speed = obstacle_speed
    add_child(obstacle)


func _increment_score() -> void:
    """Increase the score and update the UI."""
    _score += 1
    if $CanvasLayer.has_node("ScoreLabel"):
        $CanvasLayer/ScoreLabel.text = "Score: " + str(_score)


func game_over() -> void:
    """Handle the end of a run.

    Stops obstacle spawning, displays the final score, and shows a retry
    button allowing the player to restart the scene.  Music playback is
    halted if it was active.
    """
    _game_running = false
    if $AudioStreamPlayer and $AudioStreamPlayer.playing:
        $AudioStreamPlayer.stop()
    if $CanvasLayer.has_node("TutorialLabel"):
        $CanvasLayer/TutorialLabel.text = "Game Over! Final Score: " + str(_score)
        $CanvasLayer/TutorialLabel.visible = true
    if $CanvasLayer.has_node("RetryButton"):
        $CanvasLayer/RetryButton.visible = true


func _on_retry_button_pressed() -> void:
    """Reload the current scene to start fresh."""
    get_tree().reload_current_scene()