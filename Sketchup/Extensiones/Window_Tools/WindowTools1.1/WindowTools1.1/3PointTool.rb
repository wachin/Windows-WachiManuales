=begin
# Copyright 2004, @Last Software, Inc.
# The code related to click 3 points was reused here from an original
# example titled rectangle.rb by @Last Software, Inc. 
# To it I added the window code.
# Name:           3 Point Rectangle  
# Usage:          click 3 points, into an EXISTING OPENING, for use with WindowTools
# Date:           2008 
# Type:           Tool
# Revised:        2008,09,20 Thanks to Jim Foltz for rewriting this routine
#------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'

class ThreePointTool

    def initialize
      @ip = Sketchup::InputPoint.new
      @ip1 = Sketchup::InputPoint.new
      reset
    end

    def reset
      @pts = []
      @state = 0
      @ip1.clear
      @drawn = false
      Sketchup::set_status_text "", SB_VCB_LABEL
      Sketchup::set_status_text "", SB_VCB_VALUE
      Sketchup::set_status_text "Click Top Left to start"
      @shift_down_time = Time.now
    end

    def activate
      self.reset
    end

    def deactivate(view)
      view.invalidate if @drawn
    end

    def set_current_point(x, y, view)
      if( !@ip.pick(view, x, y, @ip1) )
	return false
      end
      need_draw = true

      # Set the tooltip that will be displayed
      view.tooltip = @ip.tooltip

      # Compute points
      case @state
      when 0
	@pts[0] = @ip.position
	@pts[4] = @pts[0]
	need_draw = @ip.display? || @drawn
      when 1
	@pts[1] = @ip.position
	@length = @pts[0].distance @pts[1]
	Sketchup::set_status_text @length.to_s, SB_VCB_VALUE
      when 2
	pt1 = @ip.position
	pt2 = pt1.project_to_line @pts
	vec = pt1 - pt2

	@pt1 = @ip.position
	@pt2 = pt1.project_to_line @pts
	@vec = @pt1 - @pt2


	@width = vec.length
	if( @width > 0 )
	  # test for a square
	  square_point = pt2.offset(vec, @length)
	  if( view.pick_helper.test_point(square_point, x, y) )
	    @width = @length
	    @pts[2] = @pts[1].offset(vec, @width)
	    @pts[3] = @pts[0].offset(vec, @width)
	    view.tooltip = "Square"
	  else
	    @pts[2] = @pts[1].offset(vec)
	    @pts[3] = @pts[0].offset(vec)
	  end
	else
	  @pts[2] = @pts[1]
	  @pts[3] = @pts[0]
	end
	Sketchup::set_status_text @width.to_s, SB_VCB_VALUE
      end

      view.invalidate if need_draw
    end

    def onMouseMove(flags, x, y, view)
      self.set_current_point(x, y, view)
    end

    def increment_state
      @state += 1
      case @state
      when 1
	@ip1.copy! @ip
	Sketchup::set_status_text "Click Top Right for 2nd point"
	Sketchup::set_status_text "", SB_VCB_LABEL
	Sketchup::set_status_text "", SB_VCB_VALUE
      when 2
	@ip1.clear
	Sketchup::set_status_text "Click Btm Right for 3rd point"
	Sketchup::set_status_text "", SB_VCB_LABEL
	Sketchup::set_status_text "", SB_VCB_VALUE
      when 3
	self.create_geometry #refers back to the main drawing routines that use > def create_geometry
      end
    end

    def onLButtonDown(flags, x, y, view)
      self.set_current_point(x, y, view)
      self.increment_state
      view.lock_inference
    end

    def onCancel(flag, view)
      view.invalidate if @drawn
      self.reset
    end

    # This is called when the user types a value into the VCB
    def onUserText(text, view)
      # The user may type in something that we can't parse as a length
      # so we set up some exception handling to trap that
      begin
	value = text.to_l
      rescue
	# Error parsing the text
	UI.beep
	value = nil
	Sketchup::set_status_text "", SB_VCB_VALUE
      end
      return if !value

      case @state
      when 1
	# update the width
	vec = @pts[1] - @pts[0]
	if( vec.length > 0.0 )
	  vec.length = value
	  @pts[1] = @pts[0].offset(vec)
	  view.invalidate
	  self.increment_state
	end
      when 2
	# update the height
	vec = @pts[3] - @pts[0]
	if( vec.length > 0.0 )
	  vec.length = value
	  @pts[2] = @pts[1].offset(vec)
	  @pts[3] = @pts[0].offset(vec)
	  self.increment_state
	end
      end
    end

    def getExtents
      bb = Geom::BoundingBox.new
      case @state
      when 0
	# We are getting the first point
	if( @ip.valid? && @ip.display? )
	  bb.add @ip.position
	end
      when 1
	bb.add @pts[0]
	bb.add @pts[1]
      when 2
	bb.add @pts
      end
      bb
    end

    def draw(view)
      @drawn = false

      # Show the current input point
      if( @ip.valid? && @ip.display? )
	@ip.draw(view)
	@drawn = true
      end

      # show the rectangle
      if( @state == 1 )
	# just draw a line from the start to the end point
	view.set_color_from_line(@ip1, @ip)
	inference_locked = view.inference_locked?
	view.line_width = 3 if inference_locked
	view.draw(GL_LINE_STRIP, @pts[0], @pts[1])
	view.line_width = 1 if inference_locked
	@drawn = true
      elsif( @state > 1 )
	# draw the curve
	view.drawing_color = "black"
	view.draw(GL_LINE_STRIP, @pts)
	@drawn = true
      end
    end

    def onKeyDown(key, rpt, flags, view)
      if( key == CONSTRAIN_MODIFIER_KEY && rpt == 1 )
	@shift_down_time = Time.now

	# if we already have an inference lock, then unlock it
	if( view.inference_locked? )
	  view.lock_inference
	elsif( @state == 0 )
	  view.lock_inference @ip
	elsif( @state == 1 )
	  view.lock_inference @ip, @ip1
	end
      end
    end

    def onKeyUp(key, rpt, flags, view)
      if( key == CONSTRAIN_MODIFIER_KEY &&
	 view.inference_locked? &&
	 (Time.now - @shift_down_time) > 0.5 )
	view.lock_inference
      end
    end

end # class ThreePointTool

