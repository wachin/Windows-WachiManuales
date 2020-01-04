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
#                 2008,11,24 revised Window Tools 1.1
#--------------------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools1.1/3PointTool'

class GlassTool < ThreePointTool

def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    $kqBC45 = 6.inch if not $kqBC45         # frame width
    $afGH46 = 0.0.inch if not $afGH46       # vertical offset
    $hxDR18 = 0.0.inch if not $hxDR18       # horiz offset
    $wePF79 = 0.inch if not $pthick         # glass thickness
    $kmZF27 = 2.inch if not $kmZF27         # glass inset
    
    # Set the layer names
    $wnWN00= "Windows" if not $drDR00       #layer for windows
    
    # Dialog box
    prompts = ["Default Layer", "Wall Thickness","Glass Vert Offset", "Glass Horiz Offset", "Glass Thickness ", "Glass Inset from Face "]
    values = [$wnWN00, $kqBC45, $afGH46, $hxDR18, $wePF79, $kmZF27]
    results = inputbox prompts, values, "Window - Glass parameters"

    return if not results
    $wnWN00, $kqBC45, $afGH46, $hxDR18, $wePF79, $kmZF27= results
    
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

    model.start_operation "Create Glazing"
    entities=model.active_entities

    # creates a new point from p1 in the direction of p2-p3 with length d
    # params are Point3d, 2 vertices, a length, returns a Point3d
    def translate(p1, p2, p3, d)
        v = p3 - p2
        v.length = d
        trans=Geom::Transformation.translation(v)
        return p1.transform(trans)
    end   

    #------Create a new set of points from the original 3 point pick
    @pt0=Geom::Point3d.new(@pts[0][0], @pts[0][1], @pts[0][2])
    @pt1=Geom::Point3d.new(@pts[1][0], @pts[1][1], @pts[1][2])
    @pt2=Geom::Point3d.new(@pts[2][0], @pts[2][1], @pts[2][2])
    @pt3=Geom::Point3d.new(@pts[3][0], @pts[3][1], @pts[3][2])

    @pt0j=translate(@pt0, @pt0, @pt3, $hxDR18)
    @pt1j=translate(@pt1, @pt1, @pt2, $hxDR18 )
    @pt2j=translate(@pt2, @pt2, @pt1, $hxDR18)
    @pt3j=translate(@pt3, @pt3, @pt0, $hxDR18)
    @pt0jj=translate(@pt0j, @pt0j, @pt1j, $afGH46)
    @pt3jj=translate(@pt3j, @pt3j, @pt2j, $afGH46)
    @pt1jj=translate(@pt1j, @pt1j, @pt0j, $afGH46)
    @pt2jj=translate(@pt2j, @pt2j, @pt3j, $afGH46)
    
    #-------Cut Face
    base=entities.add_face(@pt0jj, @pt1jj, @pt2jj, @pt3jj)
    base.pushpull -$kqBC45

    #------Draw the Glazing 
    group=entities.add_group
    entities=group.entities
    base=entities.add_face(@pt0jj, @pt1jj, @pt2jj, @pt3jj)
    base.material=Sketchup::Color.new(163,204,204) #change RGB Color number here
    base.material.alpha = 0.6 #change opacity number here
    base.pushpull -$wePF79
    normal=base.normal
    normal.length= -$kmZF27-$wePF79
    tr=Geom::Transformation.translation(normal.reverse)
    group.transform! tr
    
    #------Reset the layer back to default layer [0]
	layers = model.layers
    activelayer = model.active_layer=layers[0]
	layer=model.active_layer

    model.commit_operation
end

end # class GlassTool


