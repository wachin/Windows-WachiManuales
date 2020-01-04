#-----------------------------------------------------------------------------
# Name:           fillet.rb
# Description:    Makes fillets joining adjacent edges with a circular arc.
# Parameters:     The fillet radius.
# Usage:          1.  Select edges you want to fillet using the select tool.
#                 2.  Activate the tool by chosing Fillet from the Tool menu.
#                 3.  Type the fillet radius in the VCB, and hit enter.
#                 The edges can meet at any angle.
#                 They can form a closed loop or a connected path.
#                 There can be multiple loops and paths.
#                 Lone unconnected edges are ignored.
#                 The only restriction is that the edges you want to fillet
#                 meet at a vertex that does NOT intersect any other edges.
# Menu Item :     Tool -> Fillet
# Context Menu:   None
# Type:           Tool
# Date:           8/21/2006
# Author:         Doug Herrmann
#-----------------------------------------------------------------------------

require 'sketchup.rb'


#=============================================================================
class Fillet

	def initialize
		@model = Sketchup.active_model
		@entities = @model.active_entities
		@selection = @model.selection
	end


	def activate
		@state = 0
		find_verts

		if @verts.length > 0
			increment_state
		else
			msg = "Use the select tool to select some edges."
			Sketchup::set_status_text msg, SB_PROMPT
		end
	end


	# Find vertices to be replaced by fillets
	def find_verts
		@verts = []
		edges = @selection.find_all {|e| e.kind_of?(Sketchup::Edge)}

		# No edges were selected
		if ( edges.length < 2 )
			UI.messagebox("Please select 2 or more edges first.", MB_OK, "Fillet Tool")
			return
		end

		# vertices connecting two or more selected edges
		edges.each {|e|  
			e.vertices.each {|v|  @verts.push(v)  if (v.edges & edges).length >= 2}
		}
		@verts.uniq!

		# No adjacent edges selected
		if ( @verts.length == 0 )
			UI.messagebox("Please select some CONNECTED edges.", MB_OK, "Fillet Tool")
			return
		end

		# vertices that connect 3 or more edges are bad
		badverts = @verts.find_all {|v|  v.edges.length > 2}
		@verts -= badverts

		# Can't make fillet if more than 2 edges meet at the same vertex
		if ( badverts.length > 0 )
			msg = "Corners where 3 or more edges meet can not be filleted."
			UI.messagebox(msg, MB_OK, "Fillet Tool")
			return
		end
	end


	def increment_state
		@state += 1

		case @state
		when 1
			# Good to go, just need the radius
			@count = @verts.length
			Sketchup::set_status_text "", SB_VCB_VALUE
			Sketchup::set_status_text "Radius", SB_VCB_LABEL
			Sketchup::set_status_text("Type the fillet radius and hit Enter.", SB_PROMPT)

		when 2
			# Encapsulate for single UNDO
			@model.start_operation "Create Fillets"
			create_fillets
			@model.commit_operation

			# All done, report the number of fillets made
			Sketchup::set_status_text "", SB_VCB_VALUE
			Sketchup::set_status_text "", SB_VCB_LABEL
			Sketchup::set_status_text("Done!  Total of #{@count} fillets made.", SB_PROMPT)

			@selection.clear
		end
	end


	def onUserText(text, view)
		return  if not @state == 1

		# Assign radius
		begin
			@r = text.to_l
		rescue
			# Error parsing text as a length
			UI.beep
			puts "#{text} cannot be converted to a Length"
			Sketchup::set_status_text "", SB_VCB_VALUE
			return
		end

		# radius is good, moving on...
		increment_state
	end


	# Warning:  There is a fair amount of vector math involved to 
	# orient the arc so that it intersects tangentially with the edges.
	def create_fillets
		@verts.each {|v|  
			# The adjacent edges
			e1 = v.edges[0]
			e2 = v.edges[1]

			# Unit vectors along edges
			u1 = (e1.other_vertex v).position - v.position;  u1.normalize!
			u2 = (e2.other_vertex v).position - v.position;  u2.normalize!

			# Their unit normal
			n = (u2 * u1).normalize

			# theta is the angle between the edges
			theta = u1.angle_between u2

			# w is the offset from v to the center of the arc
			w = Geom::Vector3d.linear_combination(@r/Math.sin(theta), u1, @r/Math.sin(theta), u2)
			center = v.position + w

			# The direction in which the arc starts
			x = (n * u1).normalize

			# The angle the arc passes through
			ang = Math::PI - theta

			# Create the arc
			@entities.add_arc center, x, n, @r, 0, ang

			# erase the vestiges of the old edges
			v.edges.each {|e|  e.erase!}
		}
	end


	def resume(view)
	end

end


#=============================================================================
# User Interface Stuff
if( not file_loaded?("fillet.rb") )

	# Add a separator to the Tool menu
	add_separator_to_menu("Tool")
	
	# Add a Fillet item to the Tool menu
	UI.menu("Tool").add_item("Fillet") { Sketchup.active_model.select_tool Fillet.new }

end

#-----------------------------------------------------------------------------
file_loaded("fillet.rb")