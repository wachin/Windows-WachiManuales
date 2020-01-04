# Name :        Balustrade
# Description : Creates balustrade with desired dimmensions
# Author :      Tomasz MAREK, modified-enhanced D. Bur
# Usage :       1.Menu - Draw/Balustrade
#		2.Give dimmensions and Ok.			
# Date :        14.Jul.2oo5
# Type :        script
# History:        
#                
#                 1.o  (14.July.2oo5) - first version, 11.November 2005) version 1.1

require 'sketchup.rb'

class Balustrade

def create_balus

inputbox1 = %w[Rectangular Circular].join("|") 
inputbox2 = %w[Rectangular Circular].join("|")
inputbox3 = %w[Yes No].join("|") 
array_of_dropdowns = [inputbox1, inputbox2,inputbox3]
  
prompts = ["Handrail Section: ", "Post Section: ", "Panels: "]
values = ["Rectangular", "Rectangular", "Yes"]
results = inputbox prompts, values, array_of_dropdowns, "Balustrade Elements"
return if not results
handrail_section, post_section, draw_panels = results

# Rect and rect
if (handrail_section == "Rectangular") and (post_section == "Rectangular")
  prompts = ["Balustrade: length ", "Balustrade: height ","Balustrade: post spacing ","Post: width ", "Post: depth ", "Handrail: height ", "Handrail: depth ", "Panel: height / ground ", "Panel: height ", "Panel: depth "]
  values = [5000.mm, 1000.mm, 500.mm, 50.mm, 50.mm, 40.mm, 60.mm, 200.mm,500.mm,10.mm]
  results = inputbox prompts, values, "Balustrade Dimensions"
  return if not results
  length, height, jump, post_width, post_depth, handrail_height, handrail_depth, panel_start_height, panel_height, panel_thickness = results	
end
# Circ and circ
if (handrail_section == "Circular") and (post_section == "Circular")
  prompts = ["Balustrade: length ", "Balustrade: height ","Balustrade: post spacing ","Post: diameter ", "Handrail: diameter ", "Panel: height / ground ", "Panel: height ", "Panel: depth "]
  values = [5000.mm, 1000.mm, 500.mm, 40.mm, 40.mm, 200.mm,500.mm,10.mm]
  results = inputbox prompts, values, "Balustrade Dimensions"
  return if not results
  length, height, jump, post_diam, handrail_diam, panel_start_height, panel_height, panel_thickness = results	
end
# Rect and circ
if (handrail_section == "Rectangular") and (post_section == "Circular")
  prompts = ["Balustrade: length ", "Balustrade: height ","Balustrade: post spacing ", "Post: diameter ", "Handrail: height ", "Handrail: depth ", "Panel: height / ground ", "Panel: height ", "Panel: depth "]
  values = [5000.mm, 1000.mm, 500.mm, 40.mm, 40.mm, 60.mm, 200.mm,500.mm,10.mm]
  results = inputbox prompts, values, "Balustrade Dimensions"
  return if not results
  length, height, jump, post_diam, handrail_height, handrail_depth, panel_start_height, panel_height, panel_thickness = results	
end
# Circ and rect
if (handrail_section == "Circular") and (post_section == "Rectangular")
  prompts = ["Balustrade: length ", "Balustrade: height ","Balustrade: post spacing ","Post: width ", "Post: depth ", "Handrail: diameter ", "Panel: height / ground ", "Panel: height ", "Panel: depth "]
  values = [5000.mm, 1000.mm, 500.mm, 50.mm, 50.mm, 40.mm, 200.mm,500.mm,10.mm]
  results = inputbox prompts, values, "Balustrade Dimensions"
  return if not results
  length, height, jump, post_width, post_depth, handrail_diam, panel_start_height, panel_height, panel_thickness = results	
end

model = Sketchup.active_model
model.start_operation "Create Balustrade"
entities = model.active_entities

group = entities.add_group
entities = group.entities

# Y values for front plane, posts heights and length of panels
if handrail_depth and post_depth
  y_front_plane = (handrail_depth / 2.0) - (post_depth / 2.0)
  post_height = height - handrail_height
  length_panel = jump - post_width
end
if handrail_depth and post_diam
  y_front_plane = (handrail_depth / 2.0)
  post_height = height - handrail_height
  length_panel = jump - post_diam
end
if handrail_diam and post_depth
  y_front_plane = (handrail_diam / 2.0) - (post_depth / 2.0)
  post_height = height - (handrail_diam / 2.0)
  length_panel = jump - post_width
end
if handrail_diam and post_diam
  y_front_plane = (handrail_diam / 2.0)
  post_height = height - (handrail_diam / 2.0)
  length_panel = jump - post_diam
end

# Handrail
  if handrail_height
    # Top of rectangular hanrail
    pts = []
    pts[0] = [0, 0, height]
    pts[1] = [length, 0, height]
    pts[2] = [length, handrail_depth, height]
    pts[3] = [0, handrail_depth, height]
    base = entities.add_face pts
    base.pushpull 0.0-handrail_height
    else
    # Circular section
    #section
    if post_depth
      section = entities.add_circle [0,y_front_plane+(post_depth / 2.0),height-(handrail_diam/2.0)], [1,0,0], (handrail_diam/2.0), 10
      else
      section = entities.add_circle [0,y_front_plane,height-(handrail_diam/2.0)], [1,0,0], (handrail_diam/2.0), 10
    end
    circle = entities.add_face section
    circle.pushpull length
  end  

#Posts
  if post_depth
    # First rectangular post
    pts = []
    pts[0] = [0, y_front_plane, 0]
    pts[1] = [0, y_front_plane+post_depth, 0]
    pts[2] = [post_width, y_front_plane+post_depth, 0]
    pts[3] = [post_width, y_front_plane, 0]
    base = entities.add_face pts
    base.reverse!.pushpull post_height
  
    # Intermediate rectangular posts
    if length>jump
      jmpl=jump
      jump_post=jump
      while jump_post<length-post_width do
        pts = []
        pts[0] = [jump_post, y_front_plane, 0]
        pts[1] = [jump_post, y_front_plane+post_depth, 0]
        pts[2] = [jump_post+post_width, y_front_plane+post_depth, 0]
        pts[3] = [jump_post+post_width, y_front_plane, 0]
        base = entities.add_face pts
        base.reverse!.pushpull post_height
        jump_post+=jmpl
      end
    end
    # Last rectangular post
    pts = []
    pts[0] = [length-post_width, y_front_plane, 0]
    pts[1] = [length-post_width, y_front_plane+post_depth, 0]
    pts[2] = [length, y_front_plane+post_depth, 0]
    pts[3] = [length, y_front_plane, 0]
    base = entities.add_face pts
    base.reverse!.pushpull post_height
    
  else
  
  # First circular post
    start_point = Geom::Point3d.new((post_diam/2.0),y_front_plane,0)
    section = entities.add_circle start_point, [0,0,1], (post_diam/2.0), 10
    circle = entities.add_face section
    if( circle.normal.dot(Z_AXIS) > 0 )
      circle.pushpull post_height
      else
      circle.reverse!.pushpull post_height
    end
      
  # Intermediate circular posts
    if length>jump
      jmpl=jump
      jump_post=jump
      while jump_post<length-post_diam do
        start_point = [(post_diam/2.0)+jump_post,y_front_plane,0]
        section = entities.add_circle start_point, [0,0,1], (post_diam/2.0), 10
        circle = entities.add_face section
        if( circle.normal.dot(Z_AXIS) > 0 )
          circle.pushpull height-(post_diam/2.0)
          else
          circle.reverse!.pushpull post_height
        end
        jump_post+=jmpl
      end
    end    
  # Last circular post    
     start_point = [length-(post_diam/2.0),y_front_plane,0]
     section = entities.add_circle start_point, [0,0,1], (post_diam/2.0), 10
    circle = entities.add_face section
    if( circle.normal.dot(Z_AXIS) > 0 )
      circle.pushpull height-(post_diam/2.0)
      else
      circle.reverse!.pushpull post_height
    end
  end # of posts
  
if (draw_panels == "Yes")
    # Inner panels
    num_panels = (length/jump).floor.to_i
    if post_width
      start_point = [post_width, y_front_plane, panel_start_height]
      else
      start_point = [post_diam, y_front_plane, panel_start_height]
    end
    0.upto (num_panels - 2) do |i|
      pts = []
      pts[0] = start_point
      if post_width
        pts[1] = [start_point[0], y_front_plane+post_depth, panel_start_height]
        else
        pts[1] = [start_point[0], y_front_plane+post_diam, panel_start_height]
      end
      if post_width
        pts[2] = [start_point[0]+length_panel, y_front_plane+post_depth, panel_start_height]
        else
        pts[2] = [start_point[0]+length_panel, y_front_plane+post_diam, panel_start_height]
      end
      pts[3] = [start_point[0]+length_panel, y_front_plane, panel_start_height]
      panel = entities.add_face pts
      if( panel.normal.dot(Z_AXIS) > 0 )
        panel.pushpull panel_height
        else
        panel.reverse!.pushpull panel_height
      end
      #Move start_point
      start_point = [start_point[0]+jump, y_front_plane, panel_start_height]
    end
    
    # Last panel 
      pts = []
      pts[0] = start_point
      if post_width
        pts[1] = [start_point[0], y_front_plane+post_depth, panel_start_height]
        else
        pts[1] = [start_point[0], y_front_plane+post_diam, panel_start_height]
      end
      if post_width
        pts[2] = [length-post_width, y_front_plane+post_depth, panel_start_height]
        else
        pts[2] = [length-post_diam, y_front_plane+post_diam, panel_start_height]
      end
      if post_width
        pts[3] = [length-post_width, y_front_plane, panel_start_height]
        else
        pts[3] = [length-post_diam, y_front_plane, panel_start_height]
      end
      panel = entities.add_face pts
      panel.reverse!.pushpull panel_height
end # od draw_panels
    model.commit_operation
end

end #class Balustrade


if( not file_loaded?("balustrade.rb") )
    UI.menu("Draw").add_item("Balustrade") { Balustrade.new.create_balus }

end


file_loaded("balustrade.rb")



