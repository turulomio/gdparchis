class_name DictionaryManager
## Create and object with self.d as a dictionary d[id]=Object_with_id
var d={}

func size():
	return self.d.size()
	
## object must hava an id attribute
func append(o):
	d[o.id]=o
