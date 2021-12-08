extends Node

func delete_children(node):
	for n in node.get_children():
		if n.is_class("Sprite"):
			node.remove_child(n)
			n.queue_free()
