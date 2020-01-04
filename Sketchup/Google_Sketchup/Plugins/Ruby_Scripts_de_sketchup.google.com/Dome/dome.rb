# Name :          Dome 1.0
# Description :   constructs a dome based on a circle (and interior)
# Author :        Frank Wiesner
# Usage :         1. select circle (and face)
#                 2. run script
# Note:           - a selected face defines the "up" direction
#                 - works with polygons and exploded circle lines
#                 - set @smoothFaces = false if you do not want smooth faces
# Date :          5.Sep.2oo4
# Type :          script
# History:        
#                 1.o (3.Aug.2oo4) - first version

require 'sketchup.rb'

class Dome

def initialize
    @smoothFaces = true
end

def dome_construct
	mo=Sketchup.active_model()
	ss = mo.selection()

	if ss.empty? 
		UI.messagebox("Nothing selected")
	else
		mo.start_operation "dome"
		circleInterior = nil
		edgeArray = Array.new()
		
		ss.each {|e| 
			if (e.kind_of? Sketchup::Edge)
				edgeArray.push(e) 
			end
			circleInterior = e if e.kind_of? Sketchup::Face
		}

		e1 = edgeArray[0]
		p1 = e1.start.position
		p2 = e1.end.position
		
		# get adjacent edge
		vs = e1.end.edges
		if (vs[0] == e1)
			e2 = vs[1]
		else
			e2 = vs[0]
		end

		# get adjacent edge
		p3 = e2.other_vertex(e1.end).position

		# center and normal
		v = p2-p1
		v.length = v.length/2
		mid1 = p1+v
		v = p3-p2
		v.length = v.length/2
		mid2 = p2+v

		# 3 planes
		plane1 = [mid1, e1.line[1]] 
		plane2 = [mid2, e2.line[1]]
		cNormal =  Geom.intersect_plane_plane(plane1,plane2) # gives the normal of the circle through the center
		plane3 = [p1, e1.line[1].cross(e2.line[1])]
		c = Geom.intersect_line_plane(cNormal,plane3)
		
		if (circleInterior != nil)
			normalVec = circleInterior.normal
		else
			normalVec = cNormal[1]
		end

		segments = edgeArray.length/4
		pointsArray = Array.new()
		newEdges = Array.new()
		
		for i in 0..(segments) 
			pt = Geom::Point3d.new(p1.x ,p1.y ,p1.z)
			rot = Geom::Transformation.rotation(c, normalVec.cross(c-p1), i*(90.degrees/segments))
			pt.transform!(rot) 
			pointsArray.push(pt)
		end

		for i in 1..(pointsArray.length-1) 
			newEdges.push(mo.entities.add_edges(pointsArray[i-1], pointsArray[i]).first)
		end

		oldPointsArray = pointsArray
		for k in 1..(edgeArray.length) 
			newPointsArray = Array.new()
			rot = Geom::Transformation.rotation(c, cNormal[1], k*(360.degrees/edgeArray.length))
			for i in 0..(pointsArray.length-1) 
				pt = Geom::Point3d.new(pointsArray[i].x ,pointsArray[i].y ,pointsArray[i].z)
				pt.transform!(rot) 
				newPointsArray.push(pt)
			end
			for i in 0..(newPointsArray.length-2) 
				newEdges.push(mo.entities.add_edges(newPointsArray[i], newPointsArray[i+1]).first)
				newEdges.push(mo.entities.add_edges(oldPointsArray[i], newPointsArray[i]).first)
			end
			for i in 0..(newPointsArray.length-3) 
				mo.entities.add_face(oldPointsArray[i+1], oldPointsArray[i], newPointsArray[i], newPointsArray[i+1])
			end
			mo.entities.add_face(oldPointsArray[oldPointsArray.length-2], newPointsArray[newPointsArray.length-2], newPointsArray[newPointsArray.length-1])
			oldPointsArray = newPointsArray
		end

		if (@smoothFaces) 
			newEdges.each do |e|
				e.smooth=true
				e.soft=true
			end
		end
		mo.commit_operation
	end
end

end #class


domeTool = Dome.new

if( not file_loaded?("dome.rb") )
	UI.menu("Plugins").add_item("Dome") { domeTool.dome_construct }
end

file_loaded("dome.rb")


