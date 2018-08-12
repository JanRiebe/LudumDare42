extends Area2D


var timer = 0
export (float) var lifespan = 10

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	handleTimer(delta)

func handleTimer(delta):
	timer+=delta
	if(timer>lifespan):
		queue_free()
	

func _on_body_entered_prey(body):
	if(body.name == "Player"):
		queue_free()