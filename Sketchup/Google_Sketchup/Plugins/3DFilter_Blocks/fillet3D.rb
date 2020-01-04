#-----------------------------------------------------------------------------
# Name:           fillet3D.rb
# Description:    Makes filleted blocks.
# Parameters:     The block width, length, and height, and the fillet radius.
# Usage:          Fill in the dialog box that opens.
# Menu Item:      Draw -> Filleted Block
#                 Draw -> Filleted Panel
#                 Draw -> Filleted Post
#                 Draw -> Sphere
# Context Menu:   None
# Type:           Dialog Box
# Date:           8/27/2006
# Author:         Doug Herrmann
#-----------------------------------------------------------------------------

require 'sketchup.rb'


#=============================================================================
class Filleted_Block

	@@numseg = 9  # in 90 degree fillet arc

	# Default parameters used for block dialog box
	@@block_width = 1.75.feet     # x direction
	@@block_length = 1.75.feet    # y direction
	@@block_height = 1.5.feet     # z direction
	@@block_radius = 6.inch


	# Use class method to prompt for parameters
	def Filleted_Block.dialog
		# Inputbox 
		prompts = ["Block Width: ", "Block Length: ", "Block Height: ", "Fillet Radius: "]
		values = [@@block_width, @@block_length, @@block_height, @@block_radius]
		results = inputbox prompts, values, "Filleted Block Parameters"

		# This means that the user cancelled the operation
		return if not results

		#create new Filleted Block
		width, length, height, radius = results
		Filleted_Block.new width, length, height, radius
	end


	def validate_parameters
		# let's make the smallest fillet radius 1/16 inch - otherwise no fillet
		@radius = 0.inch  if (@radius < 0.0625.inch) 

		# smallest length is 1/8 inch
		@width = 0.125.inch  if (@width < 0.125.inch)
		@length = 0.125.inch  if (@length < 0.125.inch)
		@height = 0.125.inch  if (@height < 0.125.inch)

		# adjust the radius to not exceed half the shortest length
		radius = [@radius, @width/2.0, @length/2.0, @height/2.0].min.inch
		if (@radius != radius)
			@radius = radius
			msg = "The Fillet Radius was shortened to #{@radius}."
			UI.messagebox(msg, MB_OK, "Filleted Block")
		end

		@numseg = 2  if (@numseg < 2)

		true
	end


	def update_default_parameters
		@@block_width  = @width
		@@block_length = @length
		@@block_height = @height
		@@block_radius = @radius
		@@numseg = @numseg
	end


	def initialize(width, length, height, radius, numseg=@@numseg)
		@width=width; @length=length; @height=height; @radius=radius; @numseg = numseg;
		return  if not validate_parameters
		update_default_parameters

		@X = @width/2.0
		@Y = @length/2.0
		@Z = @height/2.0
		@x = @width/2.0 - @radius
		@y = @length/2.0 - @radius
		@z = @height/2.0 - @radius

		model = Sketchup.active_model

		# Bracket everything for a single UNDO operation.
		model.start_operation "Create 3-D Fillet"

		group_entity = model.active_entities.add_group
		@entities = group_entity.entities

		create_entities

		# Translate everything to the +x+y+z octant
		t = Geom::Transformation.new [@X, @Y, @Z]
		group_entity.transform! t

		model.commit_operation
	end


	def create_entities
		if @radius > 0
			draw_edges
			draw_caps
		end

		draw_faces
	end


	def draw_caps
		mesh = quarter_dome([@x, @y, @z], X_AXIS, Z_AXIS)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([@x, -@y, @z], Y_AXIS.reverse, Z_AXIS)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([@x, @y, -@z], Y_AXIS, Z_AXIS.reverse)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([@x, -@y, -@z], X_AXIS, Z_AXIS.reverse)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([-@x, @y, @z], Y_AXIS, Z_AXIS)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([-@x, -@y, @z], X_AXIS.reverse, Z_AXIS)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([-@x, @y, -@z], X_AXIS.reverse, Z_AXIS.reverse)
		@entities.add_faces_from_mesh mesh

		mesh = quarter_dome([-@x, -@y, -@z], Y_AXIS.reverse, Z_AXIS.reverse)
		@entities.add_faces_from_mesh mesh
	end


	def quarter_dome(center, xaxis, raxis)
		center = Geom::Point3d.new(center)
		pts = quarter_arc center, xaxis, raxis

		# create a mesh
		numpts = (@numseg + 1)*@numseg + 1
		numpoly = @numseg**2
		mesh = Geom::PolygonMesh.new(numpts, numpoly)

		# Create a transformation that will revolve the points
		delta = Math::PI / (2 * @numseg);
		t = Geom::Transformation.rotation(center, raxis, delta)

		# Add the points to the mesh
		index_array = []
		for i in 0...@numseg do
			indices = []
			for j in 0..@numseg do
				pt = pts[i]
				indices.push( mesh.add_point(pt) )
				pt.transform!(t)
			end
			index_array.push indices
		end

		# Add last point -- on axis of rotation
		last_point = mesh.add_point(pts.last)

		# Now create polygons using the point indices
		i1 = index_array[0]
		for i in 1...@numseg do
			i2 = index_array[i]
			
			for j in 0...@numseg do
				mesh.add_polygon i1[j], i1[j+1], i2[j+1], i2[j]
			end
			
			i1 = i2
		end

		# Last row of polygons
		for j in 0...@numseg do
			mesh.add_polygon i1[j], i1[j+1], last_point
		end

		mesh
	end


	def draw_edges
		# 180 degree Rotations about ther principle axii
		rx = Geom::Transformation.rotation ORIGIN, X_AXIS, Math::PI
		ry = Geom::Transformation.rotation ORIGIN, Y_AXIS, Math::PI
		rz = Geom::Transformation.rotation ORIGIN, Z_AXIS, Math::PI

		# Edges in z-direction
		if @z > 0
			pts = quarter_arc [@x, @y, -@z], X_AXIS, Y_AXIS
			v = Geom::Vector3d.new(0, 0, 2*@z)
			mesh = extrude_points(pts, v)

			@entities.add_faces_from_mesh mesh
			@entities.add_faces_from_mesh mesh.transform!(ry)
			@entities.add_faces_from_mesh mesh.transform!(rx)
			@entities.add_faces_from_mesh mesh.transform!(ry)
		end

		# Edges in x-direction
		if @x > 0
			pts = quarter_arc [-@x, @y, @z], Y_AXIS, Z_AXIS
			v = Geom::Vector3d.new(2*@x, 0, 0)
			mesh = extrude_points(pts, v)

			@entities.add_faces_from_mesh mesh
			@entities.add_faces_from_mesh mesh.transform!(rz)
			@entities.add_faces_from_mesh mesh.transform!(ry)
			@entities.add_faces_from_mesh mesh.transform!(rz)
		end

		# Edges in y-direction
		if @y > 0
			pts = quarter_arc [@x, -@y, @z], Z_AXIS, X_AXIS
			v = Geom::Vector3d.new(0, 2*@y, 0)
			mesh = extrude_points(pts, v)

			@entities.add_faces_from_mesh mesh
			@entities.add_faces_from_mesh mesh.transform!(rx)
			@entities.add_faces_from_mesh mesh.transform!(rz)
			@entities.add_faces_from_mesh mesh.transform!(rx)
		end
	end


	def extrude_points(pts, v)
		# Create mesh
		numpts = 2*pts.length
		numpoly = pts.length - 1
		mesh = Geom::PolygonMesh.new(numpts, numpoly)

		# Add the points to the mesh
		indices1 = []
		indices2 = []
		for pt in pts do
			indices1.push( mesh.add_point(pt) )
			indices2.push( mesh.add_point(pt + v) )
		end

		 # Add the polygons to the mesh
		for i in 1..numpoly do
			mesh.add_polygon indices1[i-1], indices1[i], indices2[i], indices2[i-1]
		end

		mesh
	end


	# Function for generating points on a circular arc
	def quarter_arc(center, xaxis, yaxis)
		pts = [];
		center = Geom::Point3d.new(center)
		delta = Math::PI / (2 * @numseg)
		for i in 0..@numseg do
			phi = i * delta;
			x = @radius * Math.cos(phi)
			y = @radius * Math.sin(phi)
			r = Geom::Vector3d.linear_combination(x, xaxis, y, yaxis)
			pts.push(center + r)
		end
		
		pts
	end


	def draw_faces
		if (@x > 0 && @y > 0)
			# top face
			pts = [[@x, @y, @Z], [-@x, @y, @Z], [-@x, -@y, @Z], [@x, -@y, @Z]]
			@entities.add_face pts

			# bottom face
			pts = [[@x, @y, -@Z], [@x, -@y, -@Z], [-@x, -@y, -@Z], [-@x, @y, -@Z]]
			@entities.add_face pts
		end

		if (@y > 0 && @z > 0)
			# right face
			pts = [[@X, @y, @z], [@X, -@y, @z], [@X, -@y, -@z], [@X, @y, -@z]]
			@entities.add_face pts

			# left face
			pts = [[-@X, @y, @z], [-@X, @y, -@z], [-@X, -@y, -@z], [-@X, -@y, @z]]
			@entities.add_face pts
		end

		if (@x > 0 && @z > 0)
			# front face
			pts = [[@x, -@Y, @z], [-@x, -@Y, @z], [-@x, -@Y, -@z], [@x, -@Y, -@z]]
			@entities.add_face pts

			# back face
			pts = [[@x, @Y, @z], [@x, @Y, -@z], [-@x, @Y, -@z], [-@x, @Y, @z]]
			@entities.add_face pts
		end
	end

end


#=============================================================================
class Filleted_Panel < Filleted_Block

	# Default parameters used for panel dialog box
	@@panel_thickness = 2.inch    # x direction
	@@panel_length = 6.feet       # y direction
	@@panel_height = 3.5.feet     # z direction


	# Use class method to prompt for parameters
	def Filleted_Panel.dialog
		# Inputbox 
		prompts = ["Panel Length: ", "Panel Height: ", "Panel Thickness: "]
		values = [@@panel_length, @@panel_height, @@panel_thickness]
		results = inputbox prompts, values, "Filleted Panel Parameters"

		# This means that the user cancelled the operation
		return if not results

		#create new Filleted Block
		length, height, thickness = results
		Filleted_Panel.new length, height, thickness
	end


	def validate_parameters
		if (@width >= @length || @width >= @height)
			UI.beep
			return false
		end
		super
	end


	def update_default_parameters
		@@panel_thickness  = @width
		@@panel_length = @length
		@@panel_height = @height
		@@numseg = @numseg
	end


	def initialize(length, height, thickness, numseg=@@numseg)
		super(thickness, length, height, thickness/2.0, numseg)
	end

end


#=============================================================================
class Filleted_Post < Filleted_Block

	# Default parameters used for post dialog box
	@@post_height = 2.5.feet
	@@post_diameter = 1.feet


	# Use class method to prompt for parameters
	def Filleted_Post.dialog
		# Inputbox 
		prompts = ["Post Height: ", "Post Diameter: "]
		values = [@@post_height, @@post_diameter]
		results = inputbox prompts, values, "Filleted Post Parameters"

		# This means that the user cancelled the operation
		return if not results

		#create new Filleted Block
		height, diameter = results
		Filleted_Post.new height, diameter
	end


	def validate_parameters
		if (@width >= @height || @length >= @height)
			UI.beep
			return false
		end
		super
	end


	def update_default_parameters
		@@post_diameter  = @width
		@@post_height = @height
		@@numseg = @numseg
	end


	def initialize(height, diameter, numseg=@@numseg)
		super(diameter, diameter, height, diameter/2.0, numseg)
	end

end


#=============================================================================
class Sphere < Filleted_Block

	# Default parameters used for sphere dialog box
	@@sphere_diameter = 24.inch


	# Use class method to prompt for parameters
	def Sphere.dialog
		# Inputbox 
		prompts = ["Sphere Diameter: "]
		values = [@@sphere_diameter]
		results = inputbox prompts, values, "Sphere Parameters"

		# This means that the user cancelled the operation
		return if not results

		#create new Filleted Block
		diameter = results[0]
		Sphere.new diameter
	end


	def validate_parameters
		super
	end


	def update_default_parameters
		@@sphere_diameter  = @width
		@@numseg = @numseg
	end


	def initialize(diameter, numseg=@@numseg)
		super(diameter, diameter, diameter, diameter/2.0, numseg)
	end

end


#=============================================================================
# User Interface Stuff
if( not file_loaded?("fillet3D.rb") )

	# This will add a separator to the menu, but only once
	add_separator_to_menu("Draw")
	
	# Add items to Draw menu
	UI.menu("Draw").add_item("Filleted Block") { Filleted_Block.dialog }
	UI.menu("Draw").add_item("Filleted Panel") { Filleted_Panel.dialog }
	UI.menu("Draw").add_item("Filleted Post") { Filleted_Post.dialog }
	UI.menu("Draw").add_item("Sphere") { Sphere.dialog }

end

#-----------------------------------------------------------------------------
file_loaded("fillet3D.rb")