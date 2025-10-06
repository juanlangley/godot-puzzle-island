extends Node
class_name Rect2iExtensions

static func to_tiles(rect: Rect2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i]
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			tiles.append(Vector2i(x, y))
	return tiles

static func to_rect_2f(rect: Rect2i) -> Rect2:
	return Rect2(rect.position, rect.size)
