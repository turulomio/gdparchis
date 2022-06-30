class_name DictionaryManager
## Create and object with self.d as a dictionary d[id]=Object_with_id
var d={}

func size():
	return self.d.size()
	
## object must hava an id attribute
func append(o):
	d[str(o.id)]=o

func values():
	return self.d.values()

func keys():
	return self.d.keys()

func get(id):
	return self.d[str(id)]

func has(id):
	return self.d.has(str(id))
