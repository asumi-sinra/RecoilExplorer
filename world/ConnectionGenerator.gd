extends Node


func generate(chunks:Array):

	for row in chunks:

		for chunk in row:

			chunk.connection = Enums.Connection.LEFT | Enums.Connection.RIGHT
