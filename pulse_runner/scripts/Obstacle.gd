extends Area2D

# Speed at which the obstacle travels down the screen.  This value will be
# overridden by the spawner in MainGame when the obstacle is instantiated.
var speed: float = 400.0

func _ready() -> void:
    """Connect relevant signals on creation.

    Connect the `body_entered` signal to detect collisions with the player
    and the `screen_exited` signal on the VisibleOnScreenNotifier2D child
    to destroy the obstacle once it leaves the viewport.  Doing this
    programmatically avoids the need to set up connections in the editor.
    """
    connect("body_entered", Callable(self, "_on_body_entered"))
    var notifier := $VisibleOnScreenNotifier2D
    if notifier:
        notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))


func _process(delta: float) -> void:
    """Move the obstacle downwards every frame.

    Obstacles simply translate along the y axis.  The speed is multiplied
    by delta to ensure frame‑rate independent movement.
    """
    position.y += speed * delta


func _on_screen_exited() -> void:
    """Free the obstacle when it is no longer visible.

    This prevents unused obstacles from accumulating off screen and
    consuming memory which improves robustness.
    """
    queue_free()


func _on_body_entered(body: Node) -> void:
    """Handle collisions with the player.

    When the obstacle collides with a node named "Player" the current
    scene's `game_over()` method is called.  This signals the end of
    the current run.  If the node does not have a game_over method the
    call is ignored.
    """
    if body.name == "Player":
        var root := get_tree().current_scene
        if root and root.has_method("game_over"):
            root.game_over()