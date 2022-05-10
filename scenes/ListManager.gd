class_name ListManager
## Create and object with self.d as a dictionary d[id]=Object_with_id
var arr=[]

func size():
	return self.arr.size()
	
## object must hava an id attribute
func append(o):
	self.arr.append(o)

func get_by_id(id):
	for o in self.arr:
		if self.id==id:
			return o
	return null
