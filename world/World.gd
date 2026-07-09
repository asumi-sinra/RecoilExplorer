extends Node

@onready var generator = $WorldGenerator


func _ready():

	generator.generate()
