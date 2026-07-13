extends Node2D

const CELL_SIZE = Vector2(64,64)


func draw_chunks(chunks):

	for child in get_children():
		child.queue_free()

	for row in chunks:

		for chunk in row:

			var label = Label.new()

			label.position = Vector2(chunk.coord) * CELL_SIZE

			var biome = chunk.biome.display_name.substr(0,1)

			var text = biome

			if chunk.connection & Enums.Connection.LEFT:
				text += "←"

			if chunk.connection & Enums.Connection.RIGHT:
				text += "→"

			if chunk.connection & Enums.Connection.UP:
				text += "↑"

			if chunk.connection & Enums.Connection.DOWN:
				text += "↓"

			label.text = text

			add_child(label)
