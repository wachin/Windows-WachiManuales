# Name:           k_tools 5.0
# Author :        Klaudius "mail@klaudiuskrusch.de"
# Description:  Draws mathematical graphs in 2D and 3D and some geometrical constructions
# Usage:          Dialog-Boxes
#                    Draws curves and curved areas
# Type:           Tool
# Date:           2005,09,26
#--------------------------------------------------------------------------

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

#--------------------------------------------------------------------------

require 'sketchup.rb'
include(Math)


def graph_2d
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    $plasel = "xy" if not $plasel
    
    plane_list = %w[xy xz yz].join("|")
    dropdowns= [plane_list]
    prompts = ["Graph in Plane: "]
    values = [$plasel]
    results = inputbox prompts, values, dropdowns, "Selection of Plane"
    $plasel = results[0].chomp
    
    if $plasel == "xy" then
    
      Sketchup::set_status_text("Draw a Graph along the xy-Plane", SB_PROMPT)
    
      xbeg = -1.0 if not xbeg
      xend = 1.0 if not xend
      stepw = 0.1 if not stepw
    
      prompts = ["x-Range from", "x-Range to", "Stepwidth"]
      values = [xbeg, xend, stepw]
      results = inputbox prompts, values, "Range and Resolution"
      xbeg, xend, stepw = results

      formula = "x**2                                                                                 " if not formula
        
      prompts = ["y = "]
      values = [formula]
      results = inputbox prompts, values, "Mathematical Formula"
      formula = results.to_s
    
      xbeg.step(xend-stepw, stepw) do |i| 
      
        x1 = i
        x = x1
        z1 = 0
    
        begin
          y1 = eval(formula)
        rescue
          y1 = 0
        end	
      
        y1=100000000 if y1>100000000
        y1=-100000000 if y1<-100000000
	
        x2 = i+stepw
        x = x2
        z2 = 0
	     
        begin       
          y2 = eval(formula)
        rescue
          y2 = 0
        end
      
        y2=100000000 if y2>100000000
        y2=-100000000 if y2<-100000000
      
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]

        polyline2d = entities.add_line(pt1, pt2)
    	       
     end
    
   elsif $plasel == "xz" then    
   
      Sketchup::set_status_text("Draw a Graph along the xz-Plane", SB_PROMPT)
    
      xbeg = -1.0 if not xbeg
      xend = 1.0 if not xend
      stepw = 0.1 if not stepw
    
      prompts = ["x-Range from", "x-Range to", "Stepwidth"]
      values = [xbeg, xend, stepw]
      results = inputbox prompts, values, "Range and Resolution"
      xbeg, xend, stepw = results

      formula = "x**2                                                                                 " if not formula
        
      prompts = ["z = "]
      values = [formula]
      results = inputbox prompts, values, "Mathematical Formula"
      formula = results.to_s
    
      xbeg.step(xend-stepw, stepw) do |i| 
      
        x1 = i
        x = x1
        y1 = 0
    
        begin
          z1 = eval(formula)
        rescue
          z1 = 0
        end	
      
        z1=100000000 if z1>100000000
        z1=-100000000 if z1<-100000000
	
        x2 = i+stepw
        x = x2
        y2 = 0
	     
        begin       
          z2 = eval(formula)
        rescue
          z2 = 0
        end
      
        z2=100000000 if z2>100000000
        z2=-100000000 if z2<-100000000
      
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]

        polyline2d = entities.add_line(pt1, pt2)
    	       
     end
   
  elsif $plasel == "yz" then    
   
      Sketchup::set_status_text("Draw a Graph along the yz-Plane", SB_PROMPT)
    
      xbeg = -1.0 if not xbeg
      xend = 1.0 if not xend
      stepw = 0.1 if not stepw
    
      prompts = ["y-Range from", "y-Range to", "Stepwidth"]
      values = [xbeg, xend, stepw]
      results = inputbox prompts, values, "Range and Resolution"
      xbeg, xend, stepw = results

      formula = "y**2                                                                                 " if not formula
        
      prompts = ["z = "]
      values = [formula]
      results = inputbox prompts, values, "Mathematical Formula"
      formula = results.to_s
    
      xbeg.step(xend-stepw, stepw) do |i| 
      
        y1 = i
        y = y1
        x1 = 0
    
        begin
          z1 = eval(formula)
        rescue
          z1 = 0
        end	
      
        z1=100000000 if z1>100000000
        z1=-100000000 if z1<-100000000
	
        y2 = i+stepw
        y = y2
        x2 = 0
	     
        begin       
          z2 = eval(formula)
        rescue
          z2 = 0
        end
      
        z2=100000000 if z2>100000000
        z2=-100000000 if z2<-100000000
      
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]

        polyline2d = entities.add_line(pt1, pt2)
    	       
     end   
     
   end
          
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------graph_2d-----------------------------------------
#-----------------------------------------------------------------------------


def phigraph_2d
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Draw a polar Graph along the xy-Plane", SB_PROMPT)
    
    phibeg = 0.0 if not phibeg
    phiend = 6.28318531 if not phiend
    stepw = 0.06283185 if not stepw
        
    prompts = ["p-Range from", "p-Range to", "Stepwidth"]
    values = [phibeg, phiend, stepw]
    results = inputbox prompts, values, "Range and Resolution"
    phibeg, phiend, stepw = results
    
    formula = "p**2                                                                                            " if not formula
    
    prompts = ["r = "]
    values = [formula]
    results = inputbox prompts, values, "Mathematical Formula"
    formula = results.to_s
            
    phibeg.step(phiend-stepw, stepw) do |i| 
        
      phi1 = i
      p = phi1
      z1 = 0
    
      begin
        r1 = eval(formula)
      rescue
        r1 = 0
      end	
      
      r1=100000000 if r1>100000000
      r1=-100000000 if r1<-100000000
	
      phi2 = i+stepw
      p = phi2
      z2 = 0
	     
      begin       
        r2 = eval(formula)
      rescue
        r2 = 0
      end
      
      r2=100000000 if r2>100000000
      r2=-100000000 if r2<-100000000
           
      x1 = cos(phi1) * r1
      y1 = sin(phi1) * r1
	
      x2 = cos(phi2) * r2
      y2 = sin(phi2) * r2
	
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]
		
	polyline2d = entities.add_line(pt1, pt2)
	
    end
        
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------phigraph_2d-----------------------------------------
#-----------------------------------------------------------------------------


def tgraph_2d
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Draw a x(t);y(t)-Graph along the xy-Plane", SB_PROMPT)
    
    tbeg = 0.0 if not tbeg
    tend = 6.28318531 if not tend
    stepw = 0.0062831853 if not stepw
        
    prompts = ["t-Range from", "t-Range to", "Stepwidth"]
    values = [tbeg, tend, stepw]
    results = inputbox prompts, values, "Range and Resolution"
    tbeg, tend, stepw = results
    
    formula1 = "sin(7*t)                                                                         " if not formula1
    formula2 = "cos(5*t)                                                                         " if not formula2
        
    prompts = ["y = "]
    values = [formula1]
    results = inputbox prompts, values, "Mathematical Formula for y"
    formula1 = results.to_s
    
    prompts = ["x = "]
    values = [formula2]
    results = inputbox prompts, values, "Mathematical Formula for x"
    formula2 = results.to_s
            
    tbeg.step(tend-stepw, stepw) do |i| 
        
      t1 = i
      t = t1
      z1 = 0
    
      begin
        y1 = eval(formula1)
      rescue
        y1 = 0
      end	
      
      begin
        x1 = eval(formula2)
      rescue
        x1 = 0
      end	
         
      y1=100000000 if y1>100000000
      y1=-100000000 if y1<-100000000
      x1=100000000 if x1>100000000
      x1=-100000000 if x1<-100000000
	
      t2 = i+stepw
      t = t2
      z2 = 0
    
      begin
        y2 = eval(formula1)
      rescue
        y2 = 0
      end	
      
      begin
        x2 = eval(formula2)
      rescue
        x2 = 0
      end	
         
      y2=100000000 if y2>100000000
      y2=-100000000 if y2<-100000000
      x2=100000000 if x2>100000000
      x2=-100000000 if x2<-100000000
   
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]
		
	polyline2d = entities.add_line(pt1, pt2)
	
    end
        
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------tgraph_2d-----------------------------------------
#-----------------------------------------------------------------------------


def graph_3d
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Draw a 3d-Surface relating to the xy-Plane", SB_PROMPT)
    
    xbeg = -1.0 if not xbeg
    xend = 1.0 if not xend
    stepx = 0.1 if not stepx
    ybeg= -1.0 if not ybeg
    yend= 1.0 if not yend
    stepy = 0.1 if not stepy
    
    prompts = ["x-Range from", "x-Range to", "Stepwidth of x", "y-Range from", "y-Range to", "Stepwidth of y"]
    values = [xbeg, xend, stepx, ybeg, yend, stepy]
    results = inputbox prompts, values, "Range and Resolution"
    xbeg, xend, stepx, ybeg, yend, stepy = results

    formula = "x*y                                                                                 " if not formula
    
    prompts = ["z = "]
    values = [formula]
    results = inputbox prompts, values, "Mathematical Formula"
    formula = results.to_s
        
    $style = "Faced" if not $style
    
    style_list = %w[Grid Triangle_Grid Faced].join("|")
    dropdowns= [style_list]
    prompts = ["Style: "]
    values = [$style]
    results = inputbox prompts, values, dropdowns, "Visualisation"
    $style = results[0].chomp
   
    
    xbeg.step(xend-stepx, stepx) do |i| 
     ybeg.step(yend-stepy, stepy) do |j| 
        
        x1 = i
        x = x1
        	
	y1 = j
	y = y1
    
        begin
          z1 = eval(formula)
        rescue
          z1 = 0
        end	
      
        z1=100000000 if z1>100000000
        z1=-100000000 if z1<-100000000
	
        x2 = i+stepx
        x = x2
	
	y2 = j
        y = y2
        	     
        begin       
          z2 = eval(formula)
        rescue
          z2 = 0
        end
      
        z2=100000000 if z2>100000000
        z2=-100000000 if z2<-100000000
          
        x3 = i
        x = x3
	
	y3 = j+stepy
        y = y3
        	     
        begin       
          z3 = eval(formula)
        rescue
          z3 = 0
        end
      
        z3=100000000 if z3>100000000
        z3=-100000000 if z3<-100000000
         
	x4 = i+stepx
        x = x4
	
	y4 = j+stepy
        y = y4
        	     
        begin       
          z4 = eval(formula)
        rescue
          z4 = 0
        end
      
        z4=100000000 if z4>100000000
        z4=-100000000 if z4<-100000000 
              

        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]
	pt3 = [x3.m, y3.m, z3.m]
	pt4 = [x4.m, y4.m, z4.m]
	
	if $style=="Faced" then
	  face3d= entities.add_face(pt1, pt2, pt3)
	  face3d= entities.add_face(pt2, pt3, pt4)
        else
          polyline3d = entities.add_line(pt1, pt2)
	  polyline3d = entities.add_line(pt1, pt3)
	  polyline3d = entities.add_line(pt2, pt4)
	  polyline3d = entities.add_line(pt3, pt4)
	  if $style=="Triangle_Grid" then
	   polyline3d = entities.add_line(pt2, pt3)
	  end
	end	
	
     end	
   end
        
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------graph_3d-----------------------------------------
#-----------------------------------------------------------------------------


def graph_3sp
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Draw a 3d-Sphere r = f(p,t)", SB_PROMPT)
    
    pbeg = 0.0 if not pbeg
    pend = 3.14159265 if not pend
    stepp = 0.314159265 if not stepp
    tbeg= 0.0 if not tbeg
    tend= 6.28318531 if not tend
    stept = 0.314159265 if not stept
    
    prompts = ["p-Range from", "p-Range to", "Stepwidth of p", "t-Range from", "t-Range to", "Stepwidth of t"]
    values = [pbeg, pend, stepp, tbeg, tend, stept]
    results = inputbox prompts, values, "Range and Resolution"
    pbeg, pend, stepp, tbeg, tend, stept = results

    formula = "p*t                                                                                                     " if not formula
    
    prompts = ["r = "]
    values = [formula]
    results = inputbox prompts, values, "Mathematical Formula"
    formula = results.to_s
        
    $style = "Faced" if not $style
    
    style_list = %w[Grid Triangle_Grid Faced].join("|")
    dropdowns= [style_list]
    prompts = ["Style: "]
    values = [$style]
    results = inputbox prompts, values, dropdowns, "Visualisation"
    $style = results[0].chomp
   
    
    pbeg.step(pend-stepp, stepp) do |i| 
     tbeg.step(tend-stept, stept) do |j| 
        
        p1 = i
        p = p1
        	
	t1 = j
	t = t1
    
        begin
          r1 = eval(formula)
        rescue
          r1 = 0
        end	
      
        r1=100000000 if r1>100000000
        r1=-100000000 if r1<-100000000
	
        p2 = i+stepp
        p = p2
	
	t2 = j
        t = t2
        	     
        begin       
          r2 = eval(formula)
        rescue
          r2 = 0
        end
      
        r2=100000000 if r2>100000000
        r2=-100000000 if r2<-100000000
          
        p3 = i
        p = p3
	
	t3 = j+stept
        t = t3
        	     
        begin       
          r3 = eval(formula)
        rescue
          r3 = 0
        end
      
        r3=100000000 if r3>100000000
        r3=-100000000 if r3<-100000000
         
	p4 = i+stepp
        p = p4
	
	t4 = j+stept
        t = t4
        	     
        begin       
          r4 = eval(formula)
        rescue
          r4 = 0
        end
      
        r4=100000000 if r4>100000000
        r4=-100000000 if r4<-100000000 
	
	x1 = cos(t1) * r1 * sin(p1)
        y1 = sin(t1) * r1 * sin(p1)
	z1 = cos(p1) * r1
	
	x2 = cos(t2) * r2 * sin(p2)
        y2 = sin(t2) * r2 * sin(p2)
	z2 = cos(p2) * r2
        
	x3 = cos(t3) * r3 * sin(p3)
        y3 = sin(t3) * r3 * sin(p3)
	z3 = cos(p3) * r3
	
	x4 = cos(t4) * r4 * sin(p4)
        y4 = sin(t4) * r4 * sin(p4)
	z4 = cos(p4) * r4
	         
        pt1 = [x1.m, y1.m, z1.m]
        pt2 = [x2.m, y2.m, z2.m]
	pt3 = [x3.m, y3.m, z3.m]
	pt4 = [x4.m, y4.m, z4.m]
	
	if $style=="Faced" then
	  begin
	  face3d= entities.add_face(pt1, pt2, pt3)
	  rescue
	   begin
	   face3d= entities.add_face(pt1, pt3, pt2)
	   rescue
	   end
	  end
	  begin
	  face3d= entities.add_face(pt2, pt3, pt4)
	  rescue
	   begin
	   face3d= entities.add_face(pt2, pt4, pt3)
	   rescue
	   end
	  end
        else
          polyline3d = entities.add_line(pt1, pt2)
	  polyline3d = entities.add_line(pt1, pt3)
	  polyline3d = entities.add_line(pt2, pt4)
	  polyline3d = entities.add_line(pt3, pt4)
	  if $style=="Triangle_Grid" then
	   polyline3d = entities.add_line(pt2, pt3)
	  end
	end	
	
     end	
   end
        
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------graph_3sp----------------------------------------
#-----------------------------------------------------------------------------


def rotate_3d
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Rotating a xz-Graph around the z-axis", SB_PROMPT)
    
    xbeg = -1.0 if not xbeg
    xend = 1.0 if not xend
    stepw = 0.1 if not stepw
    rsides = 24 if not rsides
    
    prompts = ["x-Range from", "x-Range to", "Stepwidth", "Rotation-Sides"]
    values = [xbeg, xend, stepw, rsides]
    results = inputbox prompts, values, "Range and Resolution"
    xbeg, xend, stepw, rsides = results
    
    formula = "(x-1)**2                                                                                 " if not formula
    
    prompts = ["z = "]
    values = [formula]
    results = inputbox prompts, values, "Mathematical Formula"
    formula = results.to_s
    
    $style = "Faced" if not $style
    
    style_list = %w[Grid Faced].join("|")
    dropdowns= [style_list]
    prompts = ["Style: "]
    values = [$style]
    results = inputbox prompts, values, dropdowns, "Visualisation"
    $style = results[0].chomp
    
    xbeg.step(xend-stepw, stepw) do |i| 
        
      x1 = i
      x = x1
      y1 = 0
    
      begin
        z1 = eval(formula)
      rescue
        z1 = 0
      end	
      
      z1=100000000 if z1>100000000
      z1=-100000000 if z1<-100000000
	
      x2 = i+stepw
      x = x2
      y2 = 0
	     
      begin       
        z2 = eval(formula)
      rescue
        z2 = 0
      end
      
      z2=100000000 if z2>100000000
      z2=-100000000 if z2<-100000000
           
      0.step(6.283185307-6.283185307/rsides, 6.283185307/rsides) do |r| 
            
        xr1 = sin(r) * x1
	yr1 = cos(r) * x1
	
        xr2 = sin(r) * x2
	yr2 = cos(r) * x2
		
        pt1 = [xr1.m, yr1.m, z1.m]
        pt2 = [xr2.m, yr2.m, z2.m]
		
	xr3 = sin(r+6.28318531/rsides) * x1
	yr3 = cos(r+6.28318531/rsides) * x1
	
        xr4 = sin(r+6.28318531/rsides) * x2
	yr4 = cos(r+6.28318531/rsides) * x2
	
        pt3 = [xr3.m, yr3.m, z1.m]
        pt4 = [xr4.m, yr4.m, z2.m]
	
	if $style=="Faced" then
	  begin
	  face3d= entities.add_face(pt2, pt1, pt3, pt4)  
	  rescue
	   begin
	   face3d= entities.add_face(pt3, pt4, pt2, pt1) 
	   rescue
	   end
	  end 
	else
	 polyline2d = entities.add_line(pt1, pt2)
	 polyline2d = entities.add_line(pt1, pt3)
	 polyline2d = entities.add_line(pt2, pt4)
	end
    
      end
	       
   end
        
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------rotate_3d-----------------------------------------
#-----------------------------------------------------------------------------


def rotate_lines
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Rotating selected lines around the z-axis", SB_PROMPT)
    
    edge = []
    startpt = []
    endpt = []
    
    numsel = model.selection.count
    
    if numsel == 0 then
     UI.messagebox("Please select a line!", MB_MULTILINE , "Rotating Lines")
     k_tools.rb
    end
        
    0.step(numsel-1, 1) do |i|
     edge[i] = model.selection.shift
    end
  
    test1 = Regexp.new("Edge")
  
    0.step(numsel-1, 1) do |i|
     if not test1.match(edge[i].to_s) then
      UI.messagebox("Not every selected object is a line!", MB_MULTILINE , "Rotating Lines")
      k_tools.rb
     end
    end
  
    0.step(numsel-1, 1) do |i|
     stp =  edge[i].start
     startpt[i] = stp.position
     enp = edge[i].end
     endpt[i] = enp.position
    end
    
    $style = "Faced" if not $style
    numseg = 24 if not numseg
    
    style_list = %w[Grid Triangle_Grid Faced].join("|")
    dropdowns= [style_list]
    prompts = ["Style: ", "Number of Segments:  "]
    values = [$style, numseg]
    results = inputbox prompts, values, dropdowns, "Visualisation"
    $style = results[0].chomp
    numseg = results[1]
        
    0.step(numsel-1, 1) do |i|
     x1 = startpt[i].x
     y1 = startpt[i].y
     z1 = startpt[i].z
     
     x2 = endpt[i].x
     y2 = endpt[i].y
     z2 = endpt[i].z
     
     0.step(6.283185307-6.283185307/numseg, 6.283185307/numseg) do |r| 
            
        xr1 = x1 * cos(r) - y1 * sin(r)
	yr1 = x1 * sin(r) + y1 * cos(r)
	
        xr2 = x2 * cos(r) - y2 * sin(r)
	yr2 = x2 * sin(r) + y2 * cos(r)
		
        pt1 = [xr1, yr1, z1]
        pt2 = [xr2, yr2, z2]
		
	xr3 = x1 * cos(r+6.28318531/numseg) - y1 * sin(r+6.28318531/numseg)
	yr3 = x1 * sin(r+6.28318531/numseg) + y1 * cos(r+6.28318531/numseg)
	
        xr4 = x2 * cos(r+6.28318531/numseg) - y2 * sin(r+6.28318531/numseg)
	yr4 = x2 * sin(r+6.28318531/numseg) + y2 * cos(r+6.28318531/numseg)
	
        pt3 = [xr3, yr3, z1]
        pt4 = [xr4, yr4, z2]
	
	if $style=="Faced" then
	  begin
	  face3d= entities.add_face(pt1, pt2, pt3)
	  rescue
	   begin
	   face3d= entities.add_face(pt1, pt3, pt2)
	   rescue
	   end
	  end
	  begin
	  face3d= entities.add_face(pt2, pt3, pt4)
	  rescue
	   begin
	   face3d= entities.add_face(pt2, pt4, pt3)
	   rescue
	   end
	  end
        else
          polyline3d = entities.add_line(pt1, pt2)
	  polyline3d = entities.add_line(pt1, pt3)
	  polyline3d = entities.add_line(pt2, pt4)
	  polyline3d = entities.add_line(pt3, pt4)
	  if $style=="Triangle_Grid" then
	   polyline3d = entities.add_line(pt2, pt3)
	  end
	end	
    
      end
     end 
     
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------rotate_lines-----------------------------------------
#-----------------------------------------------------------------------------

def screw_lines
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------   
    
    Sketchup::set_status_text("Screwing selected lines around the z-axis", SB_PROMPT)
    
    edge = []
    startpt = []
    endpt = []
    
    numsel = model.selection.count
    
    if numsel == 0 then
     UI.messagebox("Please select a line!", MB_MULTILINE , "Screwing Lines")
     k_tools.rb
    end
        
    0.step(numsel-1, 1) do |i|
     edge[i] = model.selection.shift
    end
  
    test1 = Regexp.new("Edge")
  
    0.step(numsel-1, 1) do |i|
     if not test1.match(edge[i].to_s) then
      UI.messagebox("Not every selected object is a line!", MB_MULTILINE , "Screwing Lines")
      k_tools.rb
     end
    end
  
    0.step(numsel-1, 1) do |i|
     stp =  edge[i].start
     startpt[i] = stp.position
     enp = edge[i].end
     endpt[i] = enp.position
    end
    
    $style = "Faced" if not $style
    numseg = 24 if not numseg
    deltaz = 1.0 if not deltaz
    
    style_list = %w[Grid Triangle_Grid Faced].join("|")
    dropdowns= [style_list]
    prompts = ["Style: ", "Number of Segments:","Delta z of one Rotation:"]
    values = [$style, numseg, deltaz]
    results = inputbox prompts, values, dropdowns, "Visualisation"
    $style = results[0].chomp
    numseg = results[1]
    deltaz = results[2].m
        
    0.step(numsel-1, 1) do |i|
     x1 = startpt[i].x
     y1 = startpt[i].y
     z1 = startpt[i].z
     
     x2 = endpt[i].x
     y2 = endpt[i].y
     z2 = endpt[i].z
          
     0.step(numseg-1.0, 1.0) do |s| 
     r = s/numseg*6.283185307
            
        xr1 = x1 * cos(r) - y1 * sin(r)
	yr1 = x1 * sin(r) + y1 * cos(r)
        zr1 = z1 + deltaz*s/numseg
	
        xr2 = x2 * cos(r) - y2 * sin(r)
	yr2 = x2 * sin(r) + y2 * cos(r)
	zr2 = z2 + deltaz*s/numseg
		
        pt1 = [xr1, yr1, zr1]
        pt2 = [xr2, yr2, zr2]
		
	xr3 = x1 * cos(r+6.283185307/numseg) - y1 * sin(r+6.283185307/numseg)
	yr3 = x1 * sin(r+6.283185307/numseg) + y1 * cos(r+6.283185307/numseg)
	zr3 = z1 + deltaz*(s+1)/numseg
	
        xr4 = x2 * cos(r+6.283185307/numseg) - y2 * sin(r+6.283185307/numseg)
	yr4 = x2 * sin(r+6.283185307/numseg) + y2 * cos(r+6.283185307/numseg)
	zr4 = z2 + deltaz*(s+1)/numseg
	
        pt3 = [xr3, yr3, zr3]
        pt4 = [xr4, yr4, zr4]
	
	if $style=="Faced" then
	  begin
	  face3d= entities.add_face(pt1, pt2, pt3)
	  rescue
	   begin
	   face3d= entities.add_face(pt1, pt3, pt2)
	   rescue
	   end
	  end
	  begin
	  face3d= entities.add_face(pt2, pt3, pt4)
	  rescue
	   begin
	   face3d= entities.add_face(pt2, pt4, pt3)
	   rescue
	   end
	  end
        else
          polyline3d = entities.add_line(pt1, pt2)
	  polyline3d = entities.add_line(pt1, pt3)
	  polyline3d = entities.add_line(pt2, pt4)
	  polyline3d = entities.add_line(pt3, pt4)
	  if $style=="Triangle_Grid" then
	   polyline3d = entities.add_line(pt2, pt3)
	  end
	end	
      
      end
     end 
     
    #-----------------------------------------------------------------------------
    view = model.active_view.zoom_extents 
    model.commit_operation
    #-----------------------------------------------------------------------------
end
#--------------------------rotate_lines-----------------------------------------
#-----------------------------------------------------------------------------


def ang_div
 #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------  
  
  if not model.selection.count == 2 then
   UI.messagebox("Please select two lines!", MB_MULTILINE , "Angle Division")
   k_tools.rb
  end
   
  edgeta = [] 
  lineta = []  
  cornerta = [0, 0, 0]
  startpt = []
  endpt = []
  edgpt = []
  vecst = []
  vecen = []
  trianglepl =[0, 0, 0, 0]
      
  edgeta[0] = model.selection.shift
  edgeta[1] = model.selection.shift
  
  test1 = Regexp.new("Edge")
  
  0.step(1, 1) do |i|
   if not test1.match(edgeta[i].to_s) then
    UI.messagebox("Not every selected object is a line!", MB_MULTILINE , "Angle Division")
    k_tools.rb
   end
  end
    
  0.step(1, 1) do |i|
   lineta[i]=edgeta[i].line
  end
  
  if not Geom.intersect_line_line(lineta[0], lineta[1]) then
    UI.messagebox("Lines do not intersect!", MB_MULTILINE , "Angle Division")
    k_tools.rb
   end
      
   $intersect = "yes" if not $intersect
   $divpoi = "yes" if not $divpoi
   $lines = "no" if not $lines
   numseg = 2 if not numseg
    
    style_list = %w[yes no].join("|")
    dropdowns= [style_list, style_list, style_list]
    prompts = ["Draw intersection point? ", "Draw division points ? ", "Draw lines?", "Number of Divisions:"]
    values = [$intersect, $divpoi, $lines, numseg]
    results = inputbox prompts, values, dropdowns, "outer circle of triangle"
    $intersect = results[0].chomp
    $divpoi = results[1].chomp
    $lines = results[2].chomp
    numseg = results[3]
         
  cornerta = Geom.intersect_line_line(lineta[0], lineta[1]) 
 
  if $intersect == "yes"  
  entities.add_cpoint(cornerta)
  end
       
  0.step(1, 1) do |i|
   startpt[i] = edgeta[i].start
   vecst[i] = cornerta - startpt[i]
   endpt[i] = edgeta[i].end
   vecen[i] = cornerta - endpt[i]
  end
  
  0.step(1, 1) do |i|
   if vecst[i] == nil
   edgpt[i] = endpt[i].position
   elsif vecen[i] == nil
   edgpt[i] = startpt[i].position
   elsif vecst[i].length < vecen[i].length
   edgpt[i] = endpt[i].position
   elsif vecst[i].length >vecen[i].length
   edgpt[i] = startpt[i].position
   end 
  end
    
  divangle = (cornerta - edgpt[0]).angle_between(cornerta - edgpt[1])
  divangle2 = divangle/numseg
   
  trianglepl = Geom.fit_plane_to_points(cornerta, edgpt[0], edgpt[1])
   
  trr = Geom::Transformation.rotation(cornerta, [trianglepl[0], trianglepl[1], trianglepl[2]], divangle2)
  target = edgpt[0]
  
  1.step(numseg-1, 1) do |i|
   target = target.transform(trr)
   newpoint = Geom.intersect_line_line([edgpt[0], edgpt[1]], [cornerta, target]) 
   if $divpoi == "yes" 
    entities.add_cpoint(newpoint)
   end
   if $lines == "yes" 
    entities.add_line(newpoint, cornerta)
   end
  end
  
end
#------------------------ang_div --------------------------------------
#--------------------------------------------------------------------------


def outer_c
 #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------  
  
  if not model.selection.count == 3 then
   UI.messagebox("Please select three lines!", MB_MULTILINE , "outer circle of triangle = circle through three points ")
   k_tools.rb
  end
   
  edgeta = [] 
  lineta = []  
  cornerta = []
  middleta = []
  veclin = []
  circleta = []
  planecir = []
  trianglepl =[0, 0, 0, 0]
  linenor = []
  
  edgeta[0] = model.selection.shift
  edgeta[1] = model.selection.shift
  edgeta[2] = model.selection.shift
  
  test1 = Regexp.new("Edge")
  
  0.step(2, 1) do |i|
   if not test1.match(edgeta[i].to_s) then
    UI.messagebox("Not every selected object is a line!", MB_MULTILINE , "outer circle of triangle = circle through three points ")
    k_tools.rb
   end
  end
    
  0.step(2, 1) do |i|
   lineta[i]=edgeta[i].line
  end
  
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
    if not Geom.intersect_line_line(lineta[i], lineta[j]) then
    UI.messagebox("Lines lie not in a plane or they are parallel!", MB_MULTILINE , "outer circle of triangle = circle through three points ")
    k_tools.rb
    end
  end
  
   $midpo = "yes" if not $midpo
   $corner = "yes" if not $corner   
   $faceta = "yes" if not $faceta
   numseg = 24 if not numseg
    
    style_list = %w[yes no].join("|")
    dropdowns= [style_list, style_list, style_list]
    prompts = ["Draw midpoint?", "Draw three points?", "Draw face?", "Number of Segments:  "]
    values = [$midpo, $corner, $faceta, numseg]
    results = inputbox prompts, values, dropdowns, "outer circle of triangle"
    $midpo = results[0].chomp
    $corner = results[1].chomp
    $faceta = results[2].chomp
    numseg = results[3]
    
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
   cornerta[i] = Geom.intersect_line_line(lineta[i], lineta[j]) 
   if cornerta[i] == cornerta[j] then
    UI.messagebox("Lines do not form a triangle!", MB_MULTILINE , "outer circle of triangle = circle through three points ")
    k_tools.rb
   end
   if $corner == "yes" then
    entities.add_cpoint(cornerta[i])
   end 
  end
  
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
   veclin[i]= cornerta[j] - cornerta[i]
   middleta[i] = cornerta[i] + [veclin[i].x / 2, veclin[i].y / 2, veclin[i].z / 2]
  end
  
  0.step(2, 1) do |i|
   planecir[i] = [veclin[i].x, veclin[i].y, veclin[i].z, -1 * (veclin[i].x*middleta[i].x + veclin[i].y*middleta[i].y + veclin[i].z*middleta[i].z)]
  end
  
  trianglepl = Geom.fit_plane_to_points(cornerta[0], cornerta[1], cornerta[2])

  0.step(2, 1) do |i|
    linenor[i] = Geom.intersect_plane_plane(trianglepl, planecir[i])
  end

  circlecenter = Geom.intersect_line_line(linenor[0], linenor[1]) 
  if $midpo == "yes" then
   entities.add_cpoint(circlecenter)
  end
  
  outercircle = entities.add_circle(circlecenter, [trianglepl[0], trianglepl[1], trianglepl[2]], (circlecenter - cornerta[0]).length, numseg) 
  if $faceta == "yes" then
   entities.add_face(outercircle)
  end 
 
end
#------------------------ outer_c --------------------------------------
#--------------------------------------------------------------------------


def inner_c
 #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------  
  
  if not model.selection.count == 3 then
   UI.messagebox("Please select three lines!", MB_MULTILINE , "inner circle of triangle = circle tangent to three lines ")
   k_tools.rb
  end
   
  edgeta = [] 
  lineta = []  
  cornerta = []
  veclinl = []
  veclinr = []
  vecmid = []
  anglediv = []
  trianglepl =[0, 0, 0, 0]
  tangent = []
  tangentpt = []
  
  edgeta[0] = model.selection.shift
  edgeta[1] = model.selection.shift
  edgeta[2] = model.selection.shift
  
  test1 = Regexp.new("Edge")
  
  0.step(2, 1) do |i|
   if not test1.match(edgeta[i].to_s) then
    UI.messagebox("Not every selected object is a line!", MB_MULTILINE , "inner circle of triangle = circle tangent to three lines ")
    k_tools.rb
   end
  end
    
  0.step(2, 1) do |i|
   lineta[i]=edgeta[i].line
  end
  
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
    if not Geom.intersect_line_line(lineta[i], lineta[j]) then
    UI.messagebox("Lines lie not in a plane or they are parallel!", MB_MULTILINE , "inner circle of triangle = circle tangent to three lines ")
    k_tools.rb
    end
  end
  
   $midpo = "yes" if not $midpo
   $corner = "yes" if not $corner   
   $faceta = "yes" if not $faceta
   numseg = 24 if not numseg
    
    style_list = %w[yes no].join("|")
    dropdowns= [style_list, style_list, style_list]
    prompts = ["Draw midpoint?", "Draw three points?", "Draw face?", "Number of Segments:  "]
    values = [$midpo, $corner, $faceta, numseg]
    results = inputbox prompts, values, dropdowns, "outer circle of triangle"
    $midpo = results[0].chomp
    $corner = results[1].chomp
    $faceta = results[2].chomp
    numseg = results[3]
    
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
   cornerta[i] = Geom.intersect_line_line(lineta[i], lineta[j]) 
   if cornerta[i] == cornerta[j] then
    UI.messagebox("Lines do not form a triangle!", MB_MULTILINE , "inner circle of triangle = circle tangent to three lines ")
    k_tools.rb
   end
  end
  
  0.step(2, 1) do |i|
   j=i+1
   j=0 if j>2
   k=i-1
   k=2 if k<0
   veclinl[i] = (cornerta[j] - cornerta[i]).normalize
   veclinr[i] = (cornerta[k] - cornerta[i]).normalize
  end
  
  0.step(2, 1) do |i|
  vecmid[i] =veclinl[i] + veclinr[i]
  anglediv[i] = [cornerta[i].x+vecmid[i].x, cornerta[i].y+vecmid[i].y, cornerta[i].z+vecmid[i].z] , cornerta[i]
  end
   
  trianglepl = Geom.fit_plane_to_points(cornerta[0], cornerta[1], cornerta[2])

  circlecenter = Geom.intersect_line_line(anglediv[0], anglediv[1]) 
  
  if $midpo == "yes" then
   entities.add_cpoint(circlecenter)
  end
  
  0.step(2, 1) do |i|
  tangent[i] = Geom.closest_points([circlecenter, circlecenter+[trianglepl[0], trianglepl[1], trianglepl[2]]], lineta[i])
  tangentpt[i] = tangent[i][1]
   if $corner == "yes" then
    entities.add_cpoint(tangentpt[i])
   end
  end
  
  innercircle = entities.add_circle(circlecenter, [trianglepl[0], trianglepl[1], trianglepl[2]], (tangent[0][0]-tangent[0][1]).length, numseg) 
  if $faceta == "yes" then
   entities.add_face(innercircle)
  end 
 
end
#------------------------inner_c --------------------------------------
#--------------------------------------------------------------------------


def hpgl
    #-----------------------------------------------------------------------------
    model = Sketchup.active_model
    model.start_operation "k_tools"
    #-----------------------------------------------------------------------------
    entities = model.active_entities
    group = entities.add_group
    entities = group.entities
    #-----------------------------------------------------------------------------  
    
	hpgl_name = UI.openpanel( "Select HPGL-file to import data", "." , "*.*" )	
	hpgl_content = File.open(hpgl_name).readlines.join
	hpgl_length = hpgl_content.length
	
	comstr = ""
	linbeg = [0.m, 0.m, 0.m]
	linend = [0.m, 0.m, 0.m]
	visible = 0
	num1 = 0.0
	num2 = 0.0
	
	0.step(hpgl_length-1, 1) do |i|
		comstr = comstr + hpgl_content.slice!(0).chr
		Sketchup::set_status_text((100-100*hpgl_content.length/hpgl_length).to_i.to_s + "% imported", SB_PROMPT)
		if comstr.include? "PU" then
			comstr = ""
			visible = 0
			if hpgl_content.slice(0..1) == hpgl_content.slice(0..1).to_i.to_s then
				num1 = hpgl_content.to_i
				hpgl_content.slice!(0..num1.to_s.length)
				num2 = hpgl_content.to_i
				hpgl_content.slice!(0..(num2.to_s.length - 1))
				linbeg = linend
				linend = [num1*0.025.m, num2*0.025.m, 0]
			end
			
		elsif comstr.include? "PD" then
			comstr = ""
			visible = 1
			if hpgl_content.slice(0..1) == hpgl_content.slice(0..1).to_i.to_s then
				num1 = hpgl_content.to_i
				hpgl_content.slice!(0..num1.to_s.length)
				num2 = hpgl_content.to_i
				hpgl_content.slice!(0..(num2.to_s.length - 1))
				linbeg = linend
				linend = [num1*0.025.m, num2*0.025.m, 0]
				hpglline = entities.add_line(linbeg, linend)
			end
				
		elsif comstr.include? "PA" then
			comstr = ""
			if hpgl_content.slice(0..1) == hpgl_content.slice(0..1).to_i.to_s then
				num1 = hpgl_content.to_i
				hpgl_content.slice!(0..num1.to_s.length)
				num2 = hpgl_content.to_i
				hpgl_content.slice!(0..(num2.to_s.length - 1))
				linbeg = linend
				linend = [num1*0.025.m, num2*0.025.m, 0]
				if visible == 1 then
					hpglline = entities.add_line(linbeg, linend)
				end	
			end
		end
	end
		
	#-----------------------------------------------------------------------------
	view = model.active_view.zoom_extents 
	model.commit_operation
	#-----------------------------------------------------------------------------
	File.close(hpgl_name)
end
#--------------------------------hpgl----------------------------------------
#-----------------------------------------------------------------------------


class Make_L

	def initialize
		$ip = Sketchup::InputPoint.new
	end


	def reset
		Sketchup.active_model.selection.clear
		Sketchup::set_status_text "MAKE L - Please select FIRST line/arc/circle!"
 		$selent = "0"
		$numcir = "0"
	end
       
       
	def activate
		if not $cscale
			$cscale = "m" 
		end
		if not $numseg
			$numseg = "72"
		end
		if not $cradius
			$cradius = "0"
		end
		if not $numcir
			$numcir = "0"
		end
		self.reset
		Sketchup::set_status_text $exStrings.GetString("Radius: "), SB_VCB_LABEL
	end


	def onMouseMove(flags,x,y,view)
		$ip.pick(view,x,y)
		if $ip.tooltip == "On Edge" or $ip.tooltip == "Midpoint" or $ip.tooltip == "Endpoint" then
		 	view.tooltip = "Click to L"
		end
	end


	def onLButtonDown(flags, x, y, view)
		if $selent == "0" then 
			$ip.pick(view,x,y)
			$ip1 = $ip.position
			if $ip.tooltip == "On Edge" or $ip.tooltip == "Midpoint" then
				$ipe1 = $ip.edge
			end
			if $ip.tooltip == "Endpoint" then
				$ipe1 = $ip.vertex.edges[0]
			end			
			if $ipe1.curve then
				Sketchup.active_model.selection.add $ipe1.curve.edges
				$circle1 = $ipe1.curve
				$numcir = "1"
			else
				Sketchup.active_model.selection.add $ipe1
			end
				$selent = "1"
				Sketchup::set_status_text "MAKE L - Please select SECOND line/arc/circle!"
		elsif $selent == "1" then
			$ip.pick(view,x,y)
			$ip2 = $ip.position
			if $ip.tooltip == "On Edge" or $ip.tooltip == "Midpoint" then
				$ipe2 = $ip.edge
			end
			if $ip.tooltip == "Endpoint" then
				$ipe2 = $ip.vertex.edges[0]
			end
			if $ipe2.curve then
				Sketchup.active_model.selection.add $ipe2.curve.edges
				$circle2 = $ipe2.curve
				$numcir = $numcir +"1"
			else
				Sketchup.active_model.selection.add $ipe2	
			end
			if $cradius.to_f>0 then
				cradius = $cradius
				if $cscale == "mm" then
				cradius = cradius.mm
				elsif $cscale == "cm" then 
				cradius = cradius.cm
				elsif $cscale == "m" then 
				cradius = cradius.m
				elsif $cscale == "km" then 
				cradius = cradius.km
				elsif $cscale == "inch" then 
				cradius = cradius.inch
				elsif $cscale == "feet" then 
				cradius = cradius.feet
				elsif $cscale == "yard" then 
				cradius = cradius.yard
				elsif $cscale == "mile" then 
				cradius = cradius.mile 
				end
			else
				cradius = 0
			end
			if $numcir == "0" then			
				if Geom.intersect_line_line($ipe1.line, $ipe2.line) then
					intsct = Geom.intersect_line_line($ipe1.line, $ipe2.line)
					vip1 = (intsct - $ip1)
					vip2 = (intsct - $ip2)
					pt10 = $ipe1.start.position
					pt11 = $ipe1.end.position
					pt20 = $ipe2.start.position
					pt21 = $ipe2.end.position
					lipe1 = $ipe1.line
					lipe2 = $ipe2.line
					
					if intsct.distance(pt10) == 0 then
						vpt1 = pt11
					elsif intsct.distance(pt11) == 0 then
						vpt1 = pt10
					elsif (intsct - pt10).samedirection?(vip1) and (intsct - pt11).samedirection?(vip1) then
						if intsct.distance(pt10) > intsct.distance(pt11) then
							vpt1 = pt10
						else
							vpt1 = pt11
						end
					else
						if (intsct - pt10).samedirection?(vip1) then
							vpt1 = pt10
						else
							vpt1 = pt11
						end
					end
					
					if intsct.distance(pt20) == 0 then
						vpt2 = pt21
					elsif intsct.distance(pt21) == 0 then
						vpt2 = pt20
					elsif (intsct - pt20).samedirection?(vip2) and (intsct - pt21).samedirection?(vip2) then
						if intsct.distance(pt20) > intsct.distance(pt21) then
							vpt2 = pt20
						else
							vpt2 = pt21
						end
					else
						if (intsct - pt20).samedirection?(vip2) then
							vpt2 = pt20
						else
							vpt2 = pt21
						end
					end
					$ipe1.erase!
					$ipe2.erase!
					delta = ((intsct - vpt1).angle_between(intsct - vpt2))/2
					tplane = Geom.fit_plane_to_points(intsct, vpt1, vpt2)
					trot = Geom::Transformation.rotation(intsct, [tplane[0], tplane[1], tplane[2]], delta)
					midvpt = vpt1
					midvpt = midvpt.transform(trot)	
					ls12 = cradius/tan(delta) + tan(delta)*cradius
					s1 = intsct.offset((vpt1-intsct), ls12)
					s2 = intsct.offset((vpt2-intsct), ls12)
					arccen = Geom.intersect_line_line([intsct, midvpt], [s1, s2])
					Sketchup.active_model.active_entities.add_arc(arccen, (intsct - midvpt), [tplane[0], tplane[1], tplane[2]], cradius, -1.57079633+delta, 1.57079633-delta, $numseg.to_f)
					lk12 = cradius/tan(delta)
					k1 = intsct.offset((vpt1-intsct), lk12)
					k2 = intsct.offset((vpt2-intsct), lk12)
					Sketchup.active_model.active_entities.add_edges(k1, vpt1)
					Sketchup.active_model.active_entities.add_edges(k2, vpt2)
				end
				Sketchup.active_model.selection.clear
				self.reset
			elsif $numcir == "1" or $numcir == "01" then
				if $numcir == "1" then
					$circle = $circle1
					$ic = $ip1
					$ipe = $ipe2
					$ip = $ip2
				else	
					$circle = $circle2
					$ic = $ip2
					$ipe = $ipe1
					$ip = $ip1
				end
				iperot = Geom::Transformation.rotation($ipe.end.position, $circle.normal, -1.57079633)
				nor_ipe = $ipe.start.position.transform(iperot)
				vnor_ipe = nor_ipe - $ipe.end.position
				mid = $circle.center
				rad1 = $circle.radius-cradius
				rad2 = $circle.radius+cradius
				pln1 = $ipe.start.position.offset(vnor_ipe, cradius)
				vln1 = $ipe.start.position.offset(vnor_ipe, cradius) - $ipe.end.position.offset(vnor_ipe, cradius)
				pln2 = $ipe.start.position.offset(vnor_ipe, -cradius)
				vln2 = $ipe.start.position.offset(vnor_ipe, -cradius) - $ipe.end.position.offset(vnor_ipe, -cradius)
				cp = []
				intersect_cir_line(pln1[0].to_f, pln1[1].to_f, pln1[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid[0].to_f, mid[1].to_f, mid[2].to_f, rad1.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[1] = Sketchup.active_model.entities.add_cpoint([pln1[0].to_f+s_*vln1[0].to_f, pln1[1].to_f+s_*vln1[1].to_f, pln1[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[2] = Sketchup.active_model.entities.add_cpoint([pln1[0].to_f+s_*vln1[0].to_f, pln1[1].to_f+s_*vln1[1].to_f, pln1[2].to_f+s_*vln1[2].to_f])
				end
				intersect_cir_line(pln1[0].to_f, pln1[1].to_f, pln1[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid[0].to_f, mid[1].to_f, mid[2].to_f, rad2.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[3] = Sketchup.active_model.entities.add_cpoint([pln1[0].to_f+s_*vln1[0].to_f, pln1[1].to_f+s_*vln1[1].to_f, pln1[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[4] = Sketchup.active_model.entities.add_cpoint([pln1[0].to_f+s_*vln1[0].to_f, pln1[1].to_f+s_*vln1[1].to_f, pln1[2].to_f+s_*vln1[2].to_f])
				end
				intersect_cir_line(pln2[0].to_f, pln2[1].to_f, pln2[2].to_f, vln2[0].to_f, vln2[1].to_f, vln2[2].to_f, mid[0].to_f, mid[1].to_f, mid[2].to_f, rad1.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[5] = Sketchup.active_model.entities.add_cpoint([pln2[0].to_f+s_*vln2[0].to_f, pln2[1].to_f+s_*vln2[1].to_f, pln2[2].to_f+s_*vln2[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[6] = Sketchup.active_model.entities.add_cpoint([pln2[0].to_f+s_*vln2[0].to_f, pln2[1].to_f+s_*vln2[1].to_f, pln2[2].to_f+s_*vln2[2].to_f])
				end
				intersect_cir_line(pln2[0].to_f, pln2[1].to_f, pln2[2].to_f, vln2[0].to_f, vln2[1].to_f, vln2[2].to_f, mid[0].to_f, mid[1].to_f, mid[2].to_f, rad2.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[7] = Sketchup.active_model.entities.add_cpoint([pln2[0].to_f+s_*vln2[0].to_f, pln2[1].to_f+s_*vln2[1].to_f, pln2[2].to_f+s_*vln2[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[8] = Sketchup.active_model.entities.add_cpoint([pln2[0].to_f+s_*vln2[0].to_f, pln2[1].to_f+s_*vln2[1].to_f, pln2[2].to_f+s_*vln2[2].to_f])
				end
				
				hp1 = []
				hp2 = []
				1.step(8, 1) do |i|
					if cp[i] then
						hp1[i] = Geom.intersect_line_line($ipe.line, [cp[i].position, cp[i].position - vnor_ipe])
						hp2[i] = mid.offset(cp[i].position - mid, $circle.radius)
						hp1_hp2_angle = (hp2[i] - cp[i].position).angle_between (hp1[i] - cp[i].position)
						testrot = Geom::Transformation.rotation(cp[i].position, $circle.normal, hp1_hp2_angle)
						if hp2[i] == hp1[i].transform(testrot) then
							Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle.normal, cradius, 0, - hp1_hp2_angle, $numseg.to_f
						elsif hp1[i] == hp2[i].transform(testrot) then
							Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f	
						else
							hp2[i] = mid.offset(mid - cp[i].position, $circle.radius)
							if hp2[i] == hp1[i].transform(testrot) then
								Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle.normal, cradius, 0, - hp1_hp2_angle, $numseg.to_f
							elsif hp1[i] == hp2[i].transform(testrot) then
								Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f
							end
						end
					end
				end
				
				
				
				
				
				
				Sketchup.active_model.selection.clear
				self.reset
								
			elsif $numcir == "11" and $circle1.normal == $circle2.normal then
				$ip1 = $ip1
				$ip2 = $ip2
				mid1 = $circle1.center
				mid2 = $circle2.center
				rad11 = $circle1.radius - cradius
				rad12 = $circle1.radius + cradius
				rad21 = $circle2.radius - cradius
				rad22 = $circle2.radius + cradius
				cp = []
				absdist = ((mid1[0].to_f-mid2[0].to_f)**2 + (mid1[1].to_f-mid2[1].to_f)**2 + (mid1[2].to_f-mid2[2].to_f)**2)**0.5
				
				pole = mid2.offset(mid2-mid1, (rad11**2 - rad21**2 - absdist**2)/(2*absdist))
				interrot = Geom::Transformation.rotation(pole, $circle1.normal, -1.57079633)
				helppt1 = $circle1.center.transform(interrot)
				vln1 =pole - helppt1
				intersect_cir_line(pole[0].to_f, pole[1].to_f, pole[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid1[0].to_f, mid1[1].to_f, mid1[2].to_f, rad11.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[1] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[2] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				
				pole = mid2.offset(mid2-mid1, (rad11**2 - rad22**2 - absdist**2)/(2*absdist))
				interrot = Geom::Transformation.rotation(pole, $circle1.normal, -1.57079633)
				helppt1 = $circle1.center.transform(interrot)
				vln1 =pole - helppt1
				intersect_cir_line(pole[0].to_f, pole[1].to_f, pole[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid1[0].to_f, mid1[1].to_f, mid1[2].to_f, rad11.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[3] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[4] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				
				pole = mid2.offset(mid2-mid1, (rad12**2 - rad21**2 - absdist**2)/(2*absdist))
				interrot = Geom::Transformation.rotation(pole, $circle1.normal, -1.57079633)
				helppt1 = $circle1.center.transform(interrot)
				vln1 =pole - helppt1
				intersect_cir_line(pole[0].to_f, pole[1].to_f, pole[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid1[0].to_f, mid1[1].to_f, mid1[2].to_f, rad12.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[5] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[6] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				
				pole = mid2.offset(mid2-mid1, (rad12**2 - rad22**2 - absdist**2)/(2*absdist))
				interrot = Geom::Transformation.rotation(pole, $circle1.normal, -1.57079633)
				helppt1 = $circle1.center.transform(interrot)
				vln1 =pole - helppt1
				intersect_cir_line(pole[0].to_f, pole[1].to_f, pole[2].to_f, vln1[0].to_f, vln1[1].to_f, vln1[2].to_f, mid1[0].to_f, mid1[1].to_f, mid1[2].to_f, rad12.to_f)
				if $s_tag1 then
					s_= $s_tag1.to_f
					cp[7] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				if $s_tag2 then
					s_= $s_tag2.to_f
					cp[8] = Sketchup.active_model.entities.add_cpoint([pole[0].to_f+s_*vln1[0].to_f, pole[1].to_f+s_*vln1[1].to_f, pole[2].to_f+s_*vln1[2].to_f])
				end
				
				hp1 = []
				hp2 = []
				1.step(8, 1) do |i|
					if cp[i] then
						hp1[i] = mid1.offset (cp[i].position-mid1, $circle1.radius)
						hp2[i] = mid2.offset (cp[i].position-mid2, $circle2.radius)
						hp1_hp2_angle = (hp1[i] - cp[i].position).angle_between (hp2[i] - cp[i].position)
						testrot1 = Geom::Transformation.rotation(cp[i].position, $circle1.normal, hp1_hp2_angle)
						if hp2[i] == hp1[i].transform(testrot1) then
							Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, -hp1_hp2_angle, $numseg.to_f
						elsif hp1[i] == hp2[i].transform(testrot1) then
							Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f
						else
							hp2[i] = mid2.offset(mid2 - cp[i].position, $circle2.radius)
							if hp2[i] == hp1[i].transform(testrot1) then
								Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, -hp1_hp2_angle, $numseg.to_f
							elsif hp1[i] == hp2[i].transform(testrot1) then
								Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f
							else
								hp1[i] = mid1.offset(mid1 - cp[i].position, $circle1.radius)
								if hp2[i] == hp1[i].transform(testrot1) then
									Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, -hp1_hp2_angle, $numseg.to_f
								elsif hp1[i] == hp2[i].transform(testrot1) then
									Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f
								else
									hp2[i] = mid2.offset (cp[i].position-mid2, $circle2.radius)
									if hp2[i] == hp1[i].transform(testrot1) then
										Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, -hp1_hp2_angle, $numseg.to_f
									elsif hp1[i] == hp2[i].transform(testrot1) then
										Sketchup.active_model.entities.add_arc cp[i].position, hp2[i] - cp[i].position, $circle1.normal, cradius, 0, hp1_hp2_angle, $numseg.to_f
									else
										Sketchup.active_model.entities.add_circle cp[i].position, $circle1.normal, cradius, $numseg.to_f
									end
								end
							end		
						end
					end
				end
				
				
				
				
				Sketchup.active_model.selection.clear
				self.reset
			end
		end
	end
	
	
	def intersect_cir_line(pln_0, pln_1, pln_2, vln_0, vln_1, vln_2, mid_0, mid_1, mid_2, rad_)
		var_0 = pln_0 - mid_0
		var_1 = pln_1 - mid_1
		var_2 = pln_2 - mid_2
		quad_a = vln_0**2 + vln_1**2 + vln_2**2
		quad_b = 2 * (var_0*vln_0 + var_1*vln_1 + var_2*vln_2)
		quad_c = var_0**2 + var_1**2 + var_2**2 - rad_**2
		 quad_p = quad_b/quad_a
		 quad_q = quad_c/quad_a
		roo_t = quad_p**2 / 4 - quad_q
		stag = [0.0, 0.0]
		if roo_t < 0 then
			s_tag = [ nil, nil]
		elsif roo_t == 0 then
			s_tag = [ -quad_p/2, nil]
		else
			s_tag = [ -quad_p/2 + roo_t**0.5 , -quad_p/2 - roo_t**0.5]
		end
		$s_tag1 = s_tag[0]
		$s_tag2 = s_tag[1]
	end
	
	
	def onRButtonDown(flags, x, y, view)
		scale_list = %w[mm cm m km inch feet yard mile].join("|") 
		dropdowns= [scale_list]
		prompts = ["Units: ", "Circle segments: "]
		values = [$cscale, $numseg]
		results = inputbox prompts, values, dropdowns, "MAKE L setup"
		$cscale = results[0].chomp
		$numseg = results[1].to_s
	end

	def onKeyDown
		
	end 

	def onKeyUp
		
	end 
	
	
	def onUserText(text, view)
		if $cscale=="inch" or $cscale=="feet" then
			$cradius = text.to_l
		else
			$cradius = text.to_f
		end
   	end
	

end # class Make_L
#------------------------Make_L--------------------------------------
#--------------------------------------------------------------------------


class Make_T

	def initialize
		$ip = Sketchup::InputPoint.new
	end


	def reset
		Sketchup.active_model.selection.clear
		Sketchup::set_status_text "MAKE T - Please select main Line!"
		$selent = "0"
	end
       
       
	def activate
		self.reset
	end


	def onMouseMove(flags,x,y,view)
		$ip.pick(view,x,y)
		if $ip.tooltip == "On Edge" then
			view.tooltip = "Click to T"
		end
	end


	def onLButtonDown(flags, x, y, view)
		if $selent == "0" then 
			$ip.pick(view,x,y)
			$ipe1 = $ip.edge
			Sketchup.active_model.selection.add $ipe1
			$selent = "1"
			Sketchup::set_status_text "MAKE T - Please select secondary line!"
		elsif $selent == "1" then
			$ip.pick(view,x,y)
			$ipe2 = $ip.edge
			$ip2 = $ip.position
			if Geom.intersect_line_line($ipe1.line, $ipe2.line) then
				intsct = Geom.intersect_line_line($ipe1.line, $ipe2.line)
				vip2 = (intsct - $ip2)
				pt20 = $ipe2.start.position
				pt21 = $ipe2.end.position
				lipe2 = $ipe2.line
				
				if intsct.distance(pt20) == 0 then
					self.reset
				end
				if intsct.distance(pt21) == 0 then
					self.reset
				end	
				if (intsct - pt20).samedirection?(vip2) and (intsct - pt21).samedirection?(vip2) then
					if intsct.distance(pt20) > intsct.distance(pt21) then
						vpt2 = pt20
					else
						vpt2 = pt21
					end					
				elsif (intsct - pt20).samedirection?(vip2) then
					vpt2 = pt20
				elsif (intsct - pt21).samedirection?(vip2) then
					vpt2 = pt21
				end
				$ipe2.erase!
				Sketchup.active_model.entities.add_edges(intsct, vpt2)
				Sketchup.active_model.selection.clear
				self.reset
			else
				self.reset
			end
		end
	end
		

	def onKeyDown
		
	end 

	def onKeyUp
		
	end 
	
end # class Make_T
#------------------------Make_L-----------------------------------------
#--------------------------------------------------------------------------


def about_k_tools
   UI.messagebox("k_tools 5.0 November 2006\nFreeware SketchUp plugin to draw 2D- and 3D-functions,\nto do some geometrical construction and a simple HPGL-import.\nPlease be careful with this tool.\nComputing time can increase very fast and data can be lost.\nAlso complex functions can cause problems.\nThis plugin comes without any warranties!\n\nAuthor: Klaudius Krusch - Architect\nMail: mail@klaudiuskrusch.de\nPlease contact me, if there is interesting work to do!" , MB_MULTILINE , "About k_tools") 
end
#------------------------about_k_tools--------------------------------------
#-----------------------------------------------------------------------------

def make_l_help
   UI.messagebox("Make L Help:\nPush right mousebutton to setup\nthe right unit and the number of arc-segments.\nIf Radius = 0 the lines will not be rounded." , MB_MULTILINE , "k_tools Help") 
end
#------------------------about_k_tools--------------------------------------
#-----------------------------------------------------------------------------

def Make_L
    Sketchup.active_model.select_tool Make_L.new
end

def Make_T
    Sketchup.active_model.select_tool Make_T.new
end

if( not file_loaded?("k_tools.rb") )
    utilities_menu = UI.menu("Plugins").add_submenu("k_tools")
      analysis_menu = utilities_menu.add_submenu("Graphs")
        analysis_menu.add_item("2D-Graph cartesian") { graph_2d }
	analysis_menu.add_item("2D-Graph polar r=f(p)") { phigraph_2d }
	analysis_menu.add_item("2D-Graph y=f(t);x=f(t)") { tgraph_2d }
        analysis_menu.add_item("3D-Graph z=f(x,y)") { graph_3d }
	analysis_menu.add_item("3D-Graph spherical r=f(p,t)") { graph_3sp }
	analysis_menu.add_item("Rotation of xz-Graph around z-Axis") { rotate_3d }
	analysis_menu.add_item("Rotation of Lines around z-Axis") { rotate_lines }
	analysis_menu.add_item("Screwing of Lines around z-Axis") { screw_lines }
      geometry_menu = utilities_menu.add_submenu("Geometry")
        geometry_menu.add_item("Angle Division") { ang_div }
        geometry_menu.add_item("Outer Circle of Triangle") { outer_c }
        geometry_menu.add_item("Inner Circle of Triangle") { inner_c }
	geometry_menu.add_item("Make T") { Sketchup.active_model.select_tool Make_T.new }
	geometry_menu.add_item("Make L") { Sketchup.active_model.select_tool Make_L.new }
	geometry_menu.add_item("Make L - Help") { make_l_help }
      utilities_menu.add_item("Import HPGL") { hpgl } 
      utilities_menu.add_item("About k_tools") { about_k_tools }
        
end
#-----------------------------------------------------------------------------
file_loaded("k_tools.rb")