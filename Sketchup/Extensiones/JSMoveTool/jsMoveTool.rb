# Name: 		jsMoveTool
# Author: 	Jan Sandstrom   www.pixero.com
# Description: 	Moves a selection with the arrow keys.
# Usage: 	1. Select a object or group of objects. 
# 		2. Select the JS MoveTool and enter a distance in the VCB. Press Return/Enter.
# 		3. Now move with arrow keys.
# 		4. Use Alt + Up/Down to move in Z axis.
# 		5. You can enter a new distance at any time.
#
#		Version 1.1 
#		Added:
#		6. Press Ctrl (Apple Key on Mac) for distance * 0.1
#		6. Press Shift for distance * 10
### 20140319 TIG updated to suit v2014 & in JS module

require('sketchup.rb')

module JS

	unless file_loaded?(__FILE__)
		UI.menu("Plugins").add_item("JS MoveTool"){ Sketchup.active_model.select_tool(JS::MoveTool.new()) } 
	end
	file_loaded(__FILE__)

class MoveTool

    @@leftArrow  = VK_LEFT  # Arrow Left Key 
    @@upArrow    = VK_UP    # Arrow Up Key 
    @@rightArrow = VK_RIGHT # Arrow Right Key 
    @@downArrow  = VK_DOWN  # Arrow Down Key 
    @@altKey     = VK_ALT   # Alt/Option Key 
    @@shiftKey   = VK_SHIFT	# Shift Key
	
	if (RUBY_PLATFORM.downcase =~ /darwin/) != nil # Mac OSX 
		@@controlKey = VK_COMMAND # Command (Apple) Key
	else # WIN PC
		@@controlKey = VK_CONTROL # Control Key
	end #if
	
	@@value = 0.0.mm
	
	def initialize()
		@@value = 0.0.mm unless @@value
		Sketchup::set_status_text(@@value.to_s, SB_VCB_VALUE)
		@msg="JS MoveTool: Type in Move Distance + <enter>: Press Arrows Left/Right = X, Up/Down = Y, Holding Alt/Opt + Up/Down = Z: Holding Cmd/Ctrl = x0.1 or Shift = x10"
		Sketchup::status_text=@msg
		@count = 0
	end

	def resume(view)
		Sketchup::status_text=@msg
		Sketchup::set_status_text(@@value.to_s, SB_VCB_VALUE)
	end
	
	def deactivate(view)
		Sketchup::status_text=""
		Sketchup::set_status_text("", SB_VCB_LABEL)
		Sketchup::set_status_text("", SB_VCB_VALUE)
	end
	
    def onCancel(flag, view)
		if flag == 2 && @count > 0
			###
			@count-=1
		else
			Sketchup::status_text=""
			Sketchup::set_status_text("", SB_VCB_LABEL)
			Sketchup::set_status_text("", SB_VCB_VALUE)
			Sketchup.send_action("selectSelectionTool:")
			return nil
		end
	end	
	
	def activate   
		# This sets the label for the VCB
		Sketchup::set_status_text("Distance", SB_VCB_LABEL)
		@model = Sketchup.active_model 
		@entities = @model.active_entities
		@ss = @model.selection
		unless @ss[0]
			UI.messagebox("JS MoveTool:\n\nNo Selection to Move !")
			self.onCancel(nil, nil)
		end
		Sketchup::status_text=@msg
		Sketchup::set_status_text(@@value.to_s, SB_VCB_VALUE)
	end
	
	def enableVCB?
		return true
	end
  
    def onUserText(text, view)
		# The user may type in something that we can't parse as a length
		# so we set up some exception handling to trap that
		begin
			@@value = text.to_l
		rescue
			# Error parsing the text
			UI.beep
			puts "Cannot convert #{text} to a Length"
			@@value = 0.0.mm
			Sketchup::set_status_text("", SB_VCB_VALUE)
		end
		###
		Sketchup::set_status_text(@@value.to_s, SB_VCB_VALUE)
		###
    end
	
  
    def onKeyDown(key, repeat, flags, view)
        # puts key   # For debug - finding the right keycodes

        if key == @@altKey
         	@altDown = true
        end #if
        if key == @@shiftKey
         	@shiftDown = true
        end #if
        if key == @@controlKey
         	@controlDown = true
        end #if
		 
		distance = 0.0.mm
		distance = @@value
		vector = Geom::Vector3d.new(distance, 0, 0)
		#
		# X axis
		if key == @@rightArrow # Right 
			vector = Geom::Vector3d.new(distance, 0, 0)
		end#if
		if @controlDown && key == @@rightArrow # Right * 0.1
			vector = Geom::Vector3d.new(distance*0.1, 0, 0)
		end#if
		if @shiftDown && key == @@rightArrow # Right * 10
			vector = Geom::Vector3d.new(distance*10, 0, 0)
		end#if
		if key == @@leftArrow # Left 
			vector = Geom::Vector3d.new(-distance, 0, 0)
		end#if
		if @controlDown && key == @@leftArrow # Left * 0.1
			vector = Geom::Vector3d.new(-distance*0.1, 0, 0)
		end#if
		if @shiftDown && key == @@leftArrow # Left * 10
			vector = Geom::Vector3d.new(-distance*10, 0, 0)
		end #if

		# Y axis 
		if key == @@upArrow # Up
			vector = Geom::Vector3d.new(0, distance, 0)
		end #if
		if @controlDown && key == @@upArrow && !@altDown # Up * 0.1
			vector = Geom::Vector3d.new(0, distance*0.1, 0)
		end #if
		if @shiftDown && key == @@upArrow && !@altDown # Up * 10
			vector = Geom::Vector3d.new(0, distance*10, 0)
		end #if
		if key == @@downArrow # Down
			vector = Geom::Vector3d.new(0, -distance, 0)
		end #if
		if @controlDown && key == @@downArrow && !@altDown # Down * 0.1
			vector = Geom::Vector3d.new(0, -distance*0.1, 0)
		end #if
		if @shiftDown && key == @@downArrow && !@altDown # Down * 10
			vector = Geom::Vector3d.new(0, -distance*10, 0)
		end #if

		# Z axis
		if @altDown && key == @@upArrow # Alt + Up
			vector = Geom::Vector3d.new(0, 0, distance)
		end #if
		if @controlDown && @altDown && key == @@upArrow # Alt + Up * 0.1
			vector = Geom::Vector3d.new(0, 0, distance*0.1)
		end #if
		if @shiftDown && @altDown && key == @@upArrow # Alt + Up * 10
			vector = Geom::Vector3d.new(0, 0, distance*10)
		end #if
		if @altDown && key == @@downArrow # Alt + Down
			vector = Geom::Vector3d.new(0, 0, -distance)
		end #if
		if @controlDown && @altDown && key == @@downArrow # Alt + Down * 0.1
			vector = Geom::Vector3d.new(0, 0, -distance*0.1)
		end #if
		if @shiftDown && @altDown && key == @@downArrow # Alt + Down * 10
			vector = Geom::Vector3d.new(0, 0, -distance*10)
		end #if

		# Now move selection !
		if [@@upArrow,@@downArrow,@@rightArrow,@@leftArrow].include?(key) && vector.length != 0
			begin
				@model.start_operation("JS MoveTool", true)
			rescue
				@model.start_operation("JS MoveTool")
			end
			###
			tr = Geom::Transformation.translation(vector)
			@entities.transform_entities(tr, @ss.to_a)
			###
			@model.commit_operation
			@count+=1
		end
		#
		
    end #onKeyDown
    
    def onKeyUp(key, repeat, flags, view)
         if key == @@altKey
         	@altDown = false
         end #if
          if key == @@shiftKey
         	@shiftDown = false
         end #if
         if key == @@controlKey
         	@controlDown = false
         end #if
		 
    end #def     
    
  
end # end of js MoveTool


end#JS