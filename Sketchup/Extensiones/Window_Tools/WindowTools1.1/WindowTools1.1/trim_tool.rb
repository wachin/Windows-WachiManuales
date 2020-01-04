=begin
# Author          tomot 
# Name:           TrimTool
# Description:    Create a simple Exterior or Interior Window, Trim
# Usage:          click 3 points, on an EXISTING OPENING, creates a Window Trim
# Date:           2008,09,17 
# Type:           Tool
# Revised:        2008,09,20 Thanks to Jim Foltz for showing me how to Write methods in a way that they are re-usable
#                 2008,11,24 Revised Window Tools 1.1
#--------------------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools1.1/3PointTool'

class TrimTool < ThreePointTool

def initialize
  
    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    $qkDJ12 = 1.inch if not $qkDJ12         # trim thickness
    $whCB16 = 4.inch if not $whCB16         # trim width
    $trTR12 = "Single" if not $trTR12       # single or both sides 
    $kqBC45 = 6.inch if not $kqBC45         # frame width
    
    # Set the layer names
    $wnWN00= "Windows" if not $drDR00       #layer for windows
    
    # Dialog box
    tside = ["Single", "Both"]
    enums = ["","", "", "", tside.join("|")]
    prompts = ["Default Layer","Wall Thickness", "Exterior Trim Thickness ", "Exterior Trim Width", "Window Trim Side"]
    values = [$wnWN00, $kqBC45, $qkDJ12, $whCB16, $trTR12]
    title = "Window - Exterior Trim parameters"
    
    results = inputbox (prompts, values, enums, title)

    return if not results
    $wnWN00, $kqBC45, $qkDJ12, $whCB16, $trTR12 = results
    
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

    model.start_operation "Create Window Trim"
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
  
    #------find the points for the head 
    @pt0tt=translate(@pt0, @pt0, @pt1, -$whCB16) 
    @pt1tt=translate(@pt1, @pt1, @pt0, -$whCB16) 
    #------find the points for the sill 
    @pt3tt=translate(@pt3, @pt3, @pt2, -$whCB16)
    @pt2tt=translate(@pt2, @pt2, @pt3, -$whCB16)
    #------find the points for the head 
    @pt0t=translate(@pt0tt, @pt0tt, @pt3tt, -$whCB16)
    @pt1t=translate(@pt1tt, @pt1tt, @pt2tt, -$whCB16)
    #------find the points for the sill 
    @pt3t=translate(@pt3tt, @pt3tt, @pt0tt, -$whCB16)
    @pt2t=translate(@pt2tt, @pt2tt, @pt1tt, -$whCB16)
    
    if( $trTR12 == "Single" ) 
        #------Draw the exterior Trim
        group=entities.add_group
        entities=group.entities
        base=entities.add_face(@pt0t, @pt1t, @pt2t, @pt3t)
        base.pushpull -$qkDJ12 
        #------Cut the opening 
        base=entities.add_face(@pt0, @pt1, @pt2, @pt3)
        base.pushpull -$qkDJ12
    end #if   

    if( $trTR12 == "Both" ) 
        #------Draw the exterior Trim
        group=entities.add_group
        entities=group.entities
        base=entities.add_face(@pt0t, @pt1t, @pt2t, @pt3t)
        base.pushpull -$qkDJ12 
        #------Cut the opening 
        base=entities.add_face(@pt0, @pt1, @pt2, @pt3)
        base.pushpull -$qkDJ12
        
        #------Make another copy
        group=entities.add_group
        entities=group.entities
        base=entities.add_face(@pt0t, @pt1t, @pt2t, @pt3t)
        base.pushpull -$qkDJ12 
        
        #------Move to opposite wall location
        normal = base.normal
        normal.length =  -$kqBC45-$qkDJ12
        tr = Geom::Transformation.translation(normal.reverse)
        group.transform! tr
        
        #------Cut the opening 
        base=entities.add_face(@pt0, @pt1, @pt2, @pt3)
        base.pushpull -$qkDJ12

    end #if 
  

    #------Reset the layer back to default layer [0]
	layers = model.layers
    activelayer = model.active_layer=layers[0]
	layer=model.active_layer

    model.commit_operation
end

end # class TrimTool

