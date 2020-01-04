=begin
# Author:         tomot
# Name:           MullionTool 
# Description:    Create simple window mullions, screens, or grilles
# Usage:          click 3 points, on an EXISTING OPENING, creates window mullions, or screens or grilles
# Date:           2008 
# Type:           Tool
# Revised:        2008,09,15 Thanks to Jim Foltz for coding the initial upto routine 
#                 2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#                 2008,11,24 revised Window Tools 1.1
#------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools1.1/3PointTool'

class MullionTool < ThreePointTool

def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    $tyVF29 = 0.inch if not $tyVF29         # frame width
    $msVD86 = 3 if not $msVD86              # no. of horiz panes
    $kcFH83 = 3 if not $kcFH83              # no. of vert panes
    $spPB28 = 2.inch if not $spPB28         # mullion width
    $wxGY45 = 1.inch if not $wxGY45         # mullion thickness
    $kqZO71 = 0.inch if not $kqZO71         # mullion setback


    $msVD86 = 1 if $msVD86 < 1
    $kcFH83 = 1 if $kcFH83 < 1
    #$tyVF29 = 0.25.inch if $tyVF29 <= 0.inch
    $spPB28 = 0.25.inch if $spPB28 <= 0.inch
    $wxGY45 = 0.25.inch if $wxGY45 <= 0.inch
    
    # Set the layer names
    $wnWN00= "Windows" if not $drDR00       #layer for windows
     
    # Dialog box
    prompts = ["Default Layer", "No. of Horiz. Panes ", "No. of Vert. Panes", "Mullion Width", "Mullion Thickness", "Mullion Setback from face "]
    values = [$wnWN00, $msVD86, $kcFH83, $spPB28, $wxGY45, $kqZO71]
    results = inputbox prompts, values, "Window - Mullion parameters"

    return if not results
    $wnWN00, $msVD86, $kcFH83, $spPB28, $wxGY45, $kqZO71 = results
    
end # initialize
#----------------------
def create_geometry
#----------------------

    model=Sketchup.active_model
    #------Set and activate the windows layer
    layers = model.layers
    layers.add ($wnWN00)
    activelayer = model.active_layer=layers[$wnWN00]
    layer=model.active_layer

    model.start_operation "Create Mullions"
    entities=model.active_entities

    # creates a new point from p1 in the direction of p2-p3 with length d
    # params are Point3d, 2 vertices, a length, returns a Point3d
    def translate(p1, p2, p3, d)
        v = p3 - p2
        v.length = d
        trans=Geom::Transformation.translation(v)
        return p1.transform(trans)
    end   
    
    #------create a new set of points from the original 3 point pick
    @pt0=Geom::Point3d.new(@pts[0][0], @pts[0][1], @pts[0][2])
    @pt1=Geom::Point3d.new(@pts[1][0], @pts[1][1], @pts[1][2])
    @pt2=Geom::Point3d.new(@pts[2][0], @pts[2][1], @pts[2][2])
    @pt3=Geom::Point3d.new(@pts[3][0], @pts[3][1], @pts[3][2])
    
    @pt0j=translate(@pt0, @pt0, @pt3, $tyVF29)
    @pt1j=translate(@pt1, @pt1, @pt2, $tyVF29)
    @pt2j=translate(@pt2, @pt2, @pt1, $tyVF29)
    @pt3j=translate(@pt3, @pt3, @pt0, $tyVF29)
    @pt0jj=translate(@pt0j, @pt0j, @pt1j, $tyVF29)
    @pt3jj=translate(@pt3j, @pt3j, @pt2j, $tyVF29)
    @pt1jj=translate(@pt1j, @pt1j, @pt0j, $tyVF29)
    @pt2jj=translate(@pt2j, @pt2j, @pt3j, $tyVF29)

    #------width of opening minus framewidth ($tyVF29)
    @vLength=@pt0jj.distance @pt3jj
    #------height of opening minus framewidth ($tyVF29)
    @hLength=@pt1jj.distance @pt0jj 
    #------width of pane
    @vPane=(@vLength - ($msVD86 -1) * $spPB28)/$msVD86
    #------height of pane
    @hPane=(@hLength - ($kcFH83 -1) * $spPB28)/$kcFH83

    #------create a mullion mask over opening minus framewidth ($tyVF29)
    group=entities.add_group
    entities=group.entities 
    #base=entities.add_face(@pt0,@pt1,@pt2,@pt3)
    base=entities.add_face(@pt0jj,@pt1jj,@pt2jj,@pt3jj)
    base.pushpull $wxGY45
    
    #------points required to create the 1st pane
    @pt4jj=translate(@pt3jj, @pt3jj, @pt2jj, @hPane)
    @pt6jj=translate(@pt3jj, @pt3jj, @pt0jj, @vPane)
    @pt7jj=translate(@pt0jj, @pt0jj, @pt1jj, @hPane)
    @pt5jj=translate(@pt4jj, @pt4jj, @pt7jj, @vPane)
        
    # The first pane is in the correct location regardless of the values of
    # $tyVF29 or $spPB28, and it also has the right proportional size
    # set by $msVD86 & $kcFH83
    #entities.add_cpoint @pt3jj
    #entities.add_cpoint @pt4jj
    #entities.add_cpoint @pt5jj
    #entities.add_cpoint @pt6jj

    @hVec = @pt4jj - @pt3jj
    @vVec = @pt6jj - @pt3jj
   
    1.upto($msVD86) do |i|
      x = (@vPane*i)+(i*$spPB28)  
      1.upto($kcFH83) do |j|
	    y = (@hPane*j)+(j*$spPB28) 
        
	o = @pt3jj.offset(@hVec, y - $spPB28).offset(@vVec, x - $spPB28)
    pt1 = o.offset(@hVec, -@hPane)
	pt2 = o.offset(@vVec, -@vPane)
	pt3 = pt1.offset(@vVec, -@vPane)
	#entities.add_cpoint o
	#entities.add_cpoint pt1
	#entities.add_cpoint pt2
	#entities.add_cpoint pt3
    face = entities.add_face o, pt1, pt3, pt2
	face.pushpull -$wxGY45
    
	#entities.add_text( "(#{x}, #{y})", [x, y] )
      end
    end
    
    #------Reset the layer back to default layer [0]
	layers = model.layers
    activelayer = model.active_layer=layers[0]
	layer=model.active_layer

    model.commit_operation
end
  
end # class MullionTool


  
  
  