# DrawHelix13.rb  Peter Brown 4/8/2004
# I've now opted to load it into 'Draw' as you use it to 'draw'
# a helix and the 'draw' menu is only short.  Change it if you want.
# For a parallel helix make the end and start radii the same.
# version 12
# In this version the points are put into an array to create a curve
# rather than lines.
# version 13
# code tidied up a bit

require 'sketchup.rb'

def drawhelix

	prompts = ["End Radius","Start Radius", "Pitch", "No of Rotations", "Sections per Rotation "]
	values = [300.mm, 300.mm, 100.mm, 5, 24]
	results = inputbox prompts, values, "Helix Dimensions"
	return if not results
	eradius, sradius, pitch, rotations, sections = results

 	totalsec = sections * rotations
 	angle = 2*3.14159/sections
	cosangle = Math.cos(angle)
	sinangle = Math.sin(angle)

	section = 1
	z0 = pitch / sections
	
	r1 = sradius
	dr = (eradius - sradius) / totalsec

	pts = []
	x1 = r1
	y1 = 0
	z1 = 0
	pts[pts.length] = [x1,y1,z1]

	while section < (totalsec + 1)
		x2 = (r1 + (dr * section)) * Math.cos(section * angle)
		y2 = (r1 + (dr * section)) * Math.sin(section * angle)
		z2 = section * z0
		pts[pts.length] = [x2,y2,z2]
		section += 1
	end

	model = Sketchup.active_model
	entities = model.active_entities
	group = entities.add_group
	entities = group.entities
	model.start_operation "DrawHelix"	
	entities.add_curve(pts)
	model.commit_operation

end

if( not file_loaded?("DrawHelix13.rb") ) 
    add_separator_to_menu("Draw")
    UI.menu("Draw").add_item("DrawHelix13") { drawhelix }
end

#-----------------------------------------------------------------------------
file_loaded("DrawHelix13.rb")
