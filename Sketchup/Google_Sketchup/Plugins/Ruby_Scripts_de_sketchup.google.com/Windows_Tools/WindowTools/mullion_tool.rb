=begin
# Author:         tomot
# Name:           MullionTool 
# Description:    Create simple window mullions, screens, or grilles
# Usage:          click 3 points, on an EXISTING OPENING, creates window mullions, or screens or grilles
# Date:           2008 
# Type:           Tool
# Revised:        2008,09,15 Thanks to Jim Foltz for coding the initial upto routine 
#                 2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools/3PointTool'
require 'windowtools/draw_mullion'

module WindowTools
class MullionTool < ThreePointTool

  def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    @mfwidth = 2.inch if not @mfwidth
    @mvpanes = 3 if not @mvpanes
    @mhpanes = 3 if not @mhpanes 
    @mwidth = 2.inch if not @mwidth  
    @mthick = 1.inch if not @mthick
    @mset = 0.inch if not @mset


    @mvpanes = 1 if @mvpanes < 1
    @mhpanes = 1 if @mhpanes < 1
    @mfwidth = 0.25.inch if @mfwidth <= 0.inch
    @mwidth = 0.25.inch if @mwidth <= 0.inch
    @mthick = 0.25.inch if @mthick <= 0.inch
   
   
    # Dialog box
    prompts = ["Frame Width", "No. of Horiz. Panes ", "No. of Vert. Panes", "Mullion Width", "Mullion Thickness", "Mullion Setback from face "]
    values = [@mfwidth, @mvpanes, @mhpanes, @mwidth, @mthick, @mset]
    results = inputbox prompts, values, "Window - Mullion parameters"

    return if not results
    @mfwidth, @mvpanes, @mhpanes, @mwidth, @mthick, @mset = results
  end
   
  def create_geometry
    WindowTools.draw_mullion( @mfwidth, @mvpanes, @mhpanes, @mwidth, @mthick, @mset, @pts )
    reset
  end
  
end # class MullionTool

end
  
  
  