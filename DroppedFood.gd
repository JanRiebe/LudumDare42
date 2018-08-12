extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	pass


func _on_body_entered_food(body):
	if(body.name!="Player"):
		print(body.name," eats ",self.name)
		get_parent().onFoodDestroyed(self)
		queue_free()
		
func _on_food_exited_land(food):
	if(food.name != "Player" and food.name != "Prey"):
		print(food.name," _on_food_exited_land I'm ",self.name)
		#if food == self:
		print(food.name," falls of the ice")
		get_parent().onFoodDestroyed(food)
		food.queue_free()