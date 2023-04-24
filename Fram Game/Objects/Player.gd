class_name Player
extends KinematicBody2D

export var speed = 300
var can_move = true
var screen_size
var player_size
var interactables
var times_disabled = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	player_size = $Sprite.get_rect().size / 2
	interactables = []
	
	# Small delay on movement on creation
	disable()
	yield(get_tree().create_timer(0.25), "timeout")
	enable()
	#$AnimationPlayer.player("idle")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	# Prevent movement if player movement is disabled
	if !can_move:
		return
	
	# Movement direction
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$AnimatedSprite.play("WalkRight")
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$AnimatedSprite.play("WalkLeft")
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		$AnimatedSprite.play("WalkDown")
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		$AnimatedSprite.play("WalkUp")
		
	if velocity == Vector2.ZERO:
		$AnimatedSprite.play("idle")
	velocity = velocity.normalized() * speed

	# Move player
	move_and_slide(velocity)
	
	# Interaction
	var interactable = get_interactable()
	if interactable != null:
		if Input.is_action_just_pressed("Interact"):
			interactable.interact()

func get_interactable():
	if interactables.size() < 1:
		# disable E label
		$InteractLabel.hide()
		return null
	else:
		# enable E label
		$InteractLabel.show()
		return interactables[0]
		
func disable():
	# Disable _process
	times_disabled += 1
	set_physics_process(false)
	can_move = false

func enable():
	# Enable _process
	times_disabled -= 1
	if (times_disabled == 0):
		set_physics_process(true)
		can_move = true
	elif (times_disabled < 0):
		print("ERROR: times_disabled = " + str(times_disabled))
