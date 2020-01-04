=begin
# Author          tomot 
# Name:           TrimTool
# Description:    Create a simple Exterior or Interior Window, Trim
# Usage:          click 3 points, on an EXISTING OPENING, creates a Window Trim
# Date:           2008,09,17 
# Type:           Tool
# Revised:        2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#--------------------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools/3PointTool'
require 'windowtools/draw_trim'

module WindowTools
class TrimTool < ThreePointTool

  def initialize
  
    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    @etthick = 1.inch if not @etthick
    @etwidth = 4.inch if not @etwidth
    
    # Dialog box
    prompts = ["Exterior Trim Thickness ", "Exterior Trim Width"]
    values = [@etthick, @etwidth]
    results = inputbox prompts, values, "Window - Exterior Trim parameters"

    return if not results
    @etthick, @etwidth = results
  end
  
  def create_geometry
    WindowTools.draw_trim( @etthick, @etwidth, @pts )
    reset
  end

end # class TrimTool

end
