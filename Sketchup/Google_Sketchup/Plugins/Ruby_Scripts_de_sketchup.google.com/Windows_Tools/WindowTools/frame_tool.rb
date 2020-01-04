=begin
# Author:         tomot
# Name:           FrameTool
# Description:    Create a simple Window, with Frame, & Glazing 
# Usage:          click 3 points, on an EXISTING OPENING, creates a window frame with glazing
# Date:           2008 
# Type:           Tool
# Revised:        2008,09,13 Thanks to Jim Foltz for the normal statement
#                 2008,09,16 Made the terminology in the Dialog Box more consistant with my other window rubies
#                 2008,09,17 removed the Exterior Trim option, It now becomes its own ruby.  
#                 2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#---------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools/3PointTool'
require 'windowtools/draw_frame'

module WindowTools
class FrameTool < ThreePointTool

  def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    @fwidth = 2.inch if not @fwidth
    @fthick = 6.inch if not @fthick 
    @gthick = 0.inch if not @gthick
    @ginset = 3.inch if not @ginset
       
        
    # Dialog box
    prompts = ["Frame/Wall Thickness","Frame Width", "Glass Thickness", "Glass Inset"]
    values = [@fthick, @fwidth, @gthick, @ginset]
    results = inputbox prompts, values, "Window - Frame & Glass parameters"

    return if not results
    @fthick, @fwidth, @gthick, @ginset = results
  end

  def create_geometry
    WindowTools.draw_frame( @fthick, @fwidth, @gthick, @ginset, @pts )
    reset
  end

end # class FrameTool

end