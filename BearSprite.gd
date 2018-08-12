extends AnimatedSprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func handleAnimation(velocity, isJumping, isInWater):
	var animationName	
	
	if velocity.length() < 0.1 and !isJumping:
		animationName = "idleDown"
	else:
		if isJumping:
			animationName = "jump"
		else:
			animationName = "walk"
		if velocity.abs().x > velocity.abs().y:
			if velocity.x > 0:
				animationName += "Right"
			else:
				animationName += "Left"
		else:
			if velocity.y > 0:
				animationName += "Down"
			else:
				animationName += "Up"
	
	
	if isInWater:
		animationName += "Water"
			
	animation = animationName