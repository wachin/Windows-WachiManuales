# Copyright 2004, @Last Software, Inc.

# This software is provided as an example of using the Ruby interface
# to SketchUp.

# Permission to use, copy, modify, and distribute this software for 
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#-----------------------------------------------------------------------------
# Name        :   Window Maker 1.0
# Description :   A tool to create parametric Double Hung and Slider windows.
# Menu Item   :   Tools->Windows
# Context Menu:   Edit Window
# Usage       :   Select window type and then specify the size.
#             :   If the size needs to be changed after inserting into the model, 
#             :   right click on the window and select "Edit Window".
# Date        :   9/10/2004
# Type        :   Dialog Box
#-----------------------------------------------------------------------------

# Classes for creating and editing parametric windows

require 'sketchup.rb'
require './parametric.rb'

#=============================================================================
# Define the main parametric window class

class Window < Parametric

# Create windows as components rather than groups
def class_of_object
    Sketchup::ComponentInstance
end

def create_entities(data, container)
    width = data["w"]
    height = data["h"]
    type = data["t"]
    Window.create_window(width, height, type, container)
end

def create_entity(model)
    #TODO: try to find existing definition matching the parameters
    @entity = model.definitions.add self.compute_name
    
    # Set the behavior
    behavior = @entity.behavior
    behavior.is2d = true
    behavior.snapto = 0
    behavior.cuts_opening = true
    @entity
end

@@defaults = {"w", 4.feet, "h", 5.feet, "t", 0}

def default_parameters
    @@defaults.clone
end

def translate_key(key)
    prompt = key
    case( key )
        when "w"
            prompt = "Width"
        when "h"
            prompt = "Height"
    end
    prompt
end

# Show a dialog and get the values from the user
# The default implementation of this in the Parametric class doesn't support
# having a popup list.  Maybe I should consider adding something that would
# allow doing that in a more generic way.
def prompt(operation)
    # get the parameters
    if( @entity )
        data = self.parameters
    else
        data = self.default_parameters
    end
    if( not data )
        puts "No parameters attached to the entity"
        return nil
    end
    title = operation + " " + self.class.name
    prompts = ["Width", "Height", "Type"]
    types = ["Double Hung", "Slider"]
    values = [data["w"], data["h"], types[data["t"]]]
    popups = [nil, nil, types.join("|")]
    results = inputbox( prompts, values, popups, title )
    return nil if not results
    
    # Store the results back into data
    data["w"] = results[0]
    data["h"] = results[1]
    t = types.index(results[2])
    data["t"] = t ? t : 0
    
    # update the defaults values
    if( not @entity )
       data.each {|k, v| @@defaults[k] = v }
    end

    data
end

#-----------------------------------------------------------------------
# Create a rectangular face at a given location

def Window.rectangle(origin, width, height, container, close)

    v1 = Geom::Vector3d.new(width,0,0)
    v2 = Geom::Vector3d.new(0,height,0)
    p1 = origin;
    p2 = origin + v1
    p3 = p2 + v2
    p4 = origin + v2

    edges = []
    edges[0]=container.add_line p1, p2
    edges[1]=container.add_line p2, p3
    edges[2]=container.add_line p3, p4
    edges[3]=container.add_line p4, p1

    if( close )
        f = container.add_face edges
    else
        edges
    end
    
end

#-----------------------------------
# Create a simple rectangluar frame
def Window.simple_frame(p1, width, height, thickness, frameWidth, container)

    # create a group for the frame
    frame = container.add_group
    
    v = Geom::Vector3d.new(frameWidth, frameWidth, 0)
    p2 = p1 + v

    holeWidth = width - (2.0 * frameWidth)
    holeHeight = height - (2.0 * frameWidth)

    # Create the outer frame and the hole
    outer = Window.rectangle(p1, width, height, frame.entities, true)
    hole = Window.rectangle(p2, holeWidth, holeHeight, frame.entities, true)
    hole.erase!

    # Extrude the window
    outer.pushpull(-thickness)

    frame
end

#-----------------------------------
# Create a basic window
def Window.create_window(width, height, type, container)

    depth = 3
    outsideFrameWidth = 2.25
    insideFrameWidth = 1.25
    sliderThickness = 1.25
    bHorizontal = (type == 1)

    # Create the outer frame
    pt = Geom::Point3d.new(0,0,0)
    Window.simple_frame(pt, width, height, depth, outsideFrameWidth, container)

    # For a component to cut an opening it must have real geometry in it - not
    # just groups, so create the cutting gometry
    Window.rectangle(pt, width, height, container, false)

    # Create the two sliding windows
    z = ((depth - (2.0 * sliderThickness)) / 2.0) + sliderThickness
    pt = pt + Geom::Vector3d.new(outsideFrameWidth, outsideFrameWidth, z)

    if bHorizontal
        wh = (width - (2.0 * outsideFrameWidth)) / 2.0
        w = wh + + insideFrameWidth
        h = height - (2.0 * outsideFrameWidth)
    else
        w = width - (2.0 * outsideFrameWidth)
        wh = (height - (2.0 * outsideFrameWidth)) / 2.0
        h = wh + + insideFrameWidth
        pt.y = pt.y + wh
    end

    Window.simple_frame(pt, w, h, sliderThickness, insideFrameWidth, container)

    if bHorizontal
        pt.x = pt.x + wh
    else
        pt.y = pt.y - wh
    end
    pt.z = pt.z + sliderThickness
    Window.simple_frame(pt, w, h, sliderThickness, insideFrameWidth, container)
end

#-----------------------------------------------------------------------
# Prompt for parameters and then insert windows
def Window.create
    window = Window.new
    definition= window.entity
    Sketchup.active_model.place_component definition, true
end

# add a menu with the window types
if( not $windows_menu_loaded )
    UI.menu("Tools").add_item("Windows") { Window.create } 
    $windows_menu_loaded = true
end

#-----------------------------------------------------------------------
end # module Window
