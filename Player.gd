extends KinematicBody2D

export (int) var speed = 200
export (int) var waterDrag = 5
var target
export(float) var targetError = 1

var isJumping = false
var isInWater = false
var jumpTimer = 0
export(float) var jumptDuration = 1

var velocity = Vector2()


var isCarryingFood = true
var isCarryingPup = true

#func _ready():
	#target = position

func _input(event):
	if event.is_action_pressed('click') and !isJumping:
		target = get_global_mouse_position()
	if event.is_action_pressed('enter'):
		if isCarryingPup:
			dropPup()
		elif isCarryingFood:
			dropFood()


func dropPup():
	if(isCarryingPup):
		get_parent().createPup(position)
		isCarryingPup = false


func catchFood():
	isCarryingFood = true
	
func dropFood():
	if isCarryingFood:
		isCarryingFood = false
		get_parent().dropFood(position)
	
	
func _on_exited_land():
	isJumping = true
	print("on exited land player")

func handleJumpTimer(delta):
	jumpTimer += delta
	if(jumpTimer>=jumptDuration):
		isInWater = true
		isJumping = false
		jumpTimer = 0


func _on_entered_land():
	isJumping = false
	jumpTimer = 0
	isInWater = false

func _physics_process(delta):
	setVelocityToMoveToTarget()
		
	if(isJumping):
		handleJumpTimer(delta)
		
	if(!isCloseToTarget()):
		move(delta)
	else:
		velocity = Vector2(0,0)
	$BearSprite.handleAnimation(velocity, isJumping, isInWater)

func setVelocityToMoveToTarget():
	velocity = (target - position).normalized() * speed


func move(delta):	
	if(isInWater):
		var collision = move_and_collide(velocity*delta/waterDrag)
		if(collision != null):
			var collider = collision.collider
			print("hit ",collider.name)
			collider.pickedUpByPlayer()
	else:
		move_and_slide(velocity)


func isCloseToTarget():
	return (target - position).length() < 5


func onCaughtPrey():
	catchFood()
	
func pickUpPup(pup):
	if pup.isInWater:
		isCarryingPup = true
		
		