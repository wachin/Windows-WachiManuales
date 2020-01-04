=begin
# Author:         tomot
# Name:           GlassTool
# Description:    Create a simple glazing 
# Usage:          click 3 points, into an EXISTING OPENING, creates glazing with offset
# Date:           2008 
# Type:           Tool
# Revised:        2008,09,17 fixed  single pane 'O' glass thickness
#                 2008,09,18 added vertical and horizontal offset, for use in Glass Railings
#                 2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#--------------------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools/3PointTool'
require 'windowtools/draw_glass'

module WindowTools
class GlassTool < ThreePointTool

  def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    @vertoff = 0.0.inch if not @vertoff
    @horizoff = 0.0.inch if not @horizoff
    @gthick = 0.inch if not @pthick
    @glinset = 2.inch if not @glinset

    # Dialog box
    prompts = ["Glass Vert Offset", "Glass Horiz Offset", "Glass Thickness ", "Glass Inset from Face "]
    values = [@vertoff, @horizoff, @gthick, @glinset]
    results = inputbox prompts, values, "Window - Glass parameters"

    return if not results
    @vertoff, @horizoff, @gthick, @glinset= results
  end

  def create_geometry
    WindowTools.draw_glass( @vertoff, @horizoff, @gthick, @glinset, @pts )
    reset
  end

end # class GlassTool

end
