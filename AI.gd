extends KinematicBody2D


export (int) var speed = 200
export(float) var targetError = 1
export(float) var streyRadius = 500

var isInWater = false
var isTargetSet = false

var target = Vector2()
var velocity = Vector2()

var recentPosition = Vector2()
var recentPositionTimer = 0
var recentPositionCheckFrequency = rand_range(.5,3)
var recentPositionCheckThreshold = 0.3
var hasRecentlyMoved = true

#export(Vector2) var worldSize

export(float) var timeBeforeDeath = 3
var deathTimer = 0

#var foodsToGoFor = []

func _ready():
	setTarget()

func _process(delta):
	if(!isInWater):
		setTarget()
	else:
		updateDeathTimer(delta)

func setTarget():
	if get_parent().food.size()>0:
		target = get_parent().food.back().position
		isTargetSet = false
	elif isCloseToTarget() or !isTargetSet:
		rand_seed(position.x)
		var radius = streyRadius # get_viewport().size.y/2
		target = Vector2(rand_range(0,radius)-radius/2, rand_range(0,radius)-radius/2) + get_parent().landCenter
		isTargetSet = true

func updateDeathTimer(delta):
	deathTimer+=delta
	if(deathTimer > timeBeforeDeath):
		die()

func die():
	get_parent().onPupDied(self)
	queue_free()

func foodSpottet(food):
	#foodsToGoFor.append(food)
	pass

func _on_exited_land():
	isInWater = true
	


	
	
func _physics_process(delta):
	recentPositionCheck(delta)
	
	if(!isInWater):
		setVelocityToMoveToTarget()
	if(!isCloseToTarget() or isInWater):
		move(delta)
		
	$BearSprite.handleAnimation(velocity,false,isInWater)
		
func setVelocityToMoveToTarget():
	velocity = (target - position).normalized() * speed
	
func move(delta):	
	if !hasRecentlyMoved:
		move_and_slide(-velocity)
	elif(isInWater):
		var collision = move_and_collide(velocity*delta/3)
		if(collision != null):
			var collider = collision.collider
			print("hit ",collider.name)
			if(collider.name=="Player"):
				pickedUpByPlayer()
	else:
		move_and_slide(velocity)

func isCloseToTarget():
	return (target - position).length() < 5


func recentPositionCheck(delta):
	recentPositionTimer+=delta*recentPositionCheckFrequency
	var neededProgress = 1
	if !hasRecentlyMoved:
		neededProgress = 3
	
	if recentPositionTimer>neededProgress:
		recentPositionTimer=0
		var dist = (position-recentPosition).length()
		recentPosition = position
		if dist < recentPositionCheckThreshold:
			hasRecentlyMoved = false
			print ("has not recently moved")
		else:
			hasRecentlyMoved = true
	
	

func pickedUpByPlayer():
	get_parent().playerPickedUpPut(self)
	queue_free()