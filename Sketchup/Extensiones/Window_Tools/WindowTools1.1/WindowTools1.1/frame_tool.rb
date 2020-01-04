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
#                 2008,11,24 revised Window Tools 1.1
#--------------------------------------------------------------------------------------------------------------------
=end
require 'sketchup.rb'
require 'windowtools1.1/3PointTool'


class FrameTool < ThreePointTool

def initialize

    super # calls the initialize method in the ThreePointTool class
    # sets the default Window settings
    $knPW75 = 2.inch if not $knPW75         # wallframe thickness
    $kqBC45 = 6.inch if not $kqBC45         # frame width
    $dhTY68 = 0.inch if not $dhTY68         # glass thickness
    $onGV39 = 3.inch if not $onGV39         # glass inset
       
    # Set the layer names
    $wnWN00= "Windows" if not $drDR00       #layer for windows
    
    # Dialog box
    prompts = ["Default Layer", "Wall Thickness","Frame Width", "Glass Thickness", "Glass Inset"]
    values = [$wnWN00, $kqBC45, $knPW75, $dhTY68, $onGV39]
    results = inputbox prompts, values, "Window - Frame & Glass parameters"

    return if not results
    $wnWN00, $kqBC45, $knPW75, $dhTY68, $onGV39 = results
    
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
    
    model.start_operation "Create Window Frame"
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
    
    @pt0j=translate(@pt0, @pt0, @pt3, $knPW75)
    @pt1j=translate(@pt1, @pt1, @pt2, $knPW75)
    @pt2j=translate(@pt2, @pt2, @pt1, $knPW75)
    @pt3j=translate(@pt3, @pt3, @pt0, $knPW75)
    @pt0jj=translate(@pt0j, @pt0j, @pt1j, $knPW75)
    @pt3jj=translate(@pt3j, @pt3j, @pt2j, $knPW75)
    @pt1jj=translate(@pt1j, @pt1j, @pt0j, $knPW75)
    @pt2jj=translate(@pt2j, @pt2j, @pt3j, $knPW75)
    
    #-------Cut Face
    base=entities.add_face(@pt0jj, @pt1jj, @pt2jj, @pt3jj)
    base.pushpull -$kqBC45
     
    #------Draw the Frame 
    group=entities.add_group
    entities=group.entities    
    base=entities.add_face(@pt0, @pt1, @pt2, @pt3)
    base.pushpull $kqBC45
    base=entities.add_face(@pt0jj, @pt1jj, @pt2jj, @pt3jj)
    base.pushpull -$kqBC45
  
    #------Draw the Glazing 
    group=entities.add_group
    entities=group.entities
    base=entities.add_face(@pt0jj, @pt1jj, @pt2jj, @pt3jj)
    base.material=Sketchup::Color.new(163,204,204) #insert your own RGB Color numbers
    base.material.alpha = 0.6 
    base.pushpull -$dhTY68

    self.reset
    normal=base.normal
    normal.length= -$onGV39-$dhTY68
    tr=Geom::Transformation.translation(normal.reverse)
    group.transform! tr
    
    #------Reset the layer back to default layer [0]
	layers = model.layers
    activelayer = model.active_layer=layers[0]
	layer=model.active_layer
   
    model.commit_operation
end
 
end # class FrameTool

