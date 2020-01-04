# Name:           View Parts 1.2
# Description:    Creates scenes for each component and group in a selection.
#                 Creates scene for the entire selection
#                 Creates a scene representing the "view" before the ruby was initiated 
#                 
#                 Helpful when needing to layout and visualize or dimension individual parts of an assebly in LayOut scenes. 
#
# Author :        CMD
# Usage :         Select components and groups and activate under Plugins/Exploded Views
#                 
# Date :          1.0 05-22-2011 
#                 1.1 09-06-2011 - code updates based on TIG recommendations
#                 1.2 09-13-2011 - menu code correction

require 'sketchup.rb'

module VPARTS 
  
def self.hideAll
  allEnts = Sketchup.active_model.active_entities
  allEnts.each{|e|
    e.hidden = true
  }
end

def self.compFocus(compAry)
  model=Sketchup.active_model
  
  # Save the view state 
  model.pages.add("Initial State")
  
  self.hideAll()
  
  # Create a page scene with selection
  ss=model.selection
  ss.each{|v|
	  v.hidden = false
	}
	model.active_view.zoom_extents
  model.pages.add("SELECTION")
  
  self.hideAll()
  
  #clears selection to allow for proper zoom extents
  model.selection.clear
  
  # Create page scene for each part
  compAry.each{|p|
    p.hidden = false
    eclass = p.class
    partName = ""
    
    if eclass == Sketchup::ComponentInstance
      partName = p.definition.name.to_s
      instName = p.name.to_s
      if instName != ""
        partName = partName + " (" + instName + ")"
      end
    end
     
    if eclass == Sketchup::Group
      partName = p.name
      if p.name == ""
        partName = "G"
      end
    end
     
    view = Sketchup.active_model.active_view
    new_view = view.zoom_extents
    #UI.messagebox("zoom extents")
    
    
    # Generate page Scene with part name
    model.pages.add(partName)
    p.hidden = true
  }
  
  # Set the view to the state before the ruby was initiated
  setView = 0
  cnt = 0
  model.pages.each{|o|
    if o.label == "Initial State"
      setView = cnt
    end
    cnt+=1
  }
  model.pages.selected_page = model.pages[setView]
  
end


  
def self.viewParts
	model=Sketchup.active_model
	ss=model.selection
	parts=[]
	
	if ss.empty?
	  UI.messagebox("You did not make a selection.")
	  return;
	end
  
  noDupe = UI.messagebox("Do you want to exclude duplicate components?", MB_YESNO)
  
	#find and list components in selection
	ss.each{|c|
	  if (c.class == Sketchup::ComponentInstance) 
	    
	    # Checking for duplicate components in selection
	    if (noDupe == 6) && (parts.length > 0)
	      dName = c.definition.name
	      dup = false
	      
	      parts.each{|i|
	        
	        if (i.class == Sketchup::ComponentInstance) && (i.definition.name == dName)
	          dup = true
	          break
	        end  
	      }
	      
	      if dup == false
	        parts.push(c)
	      end
	    else
	      parts.push(c)
	    end
	    
	  elsif (c.class == Sketchup::Group)
	    parts.push(c)
	  else
	    model.selection.remove(c)
	  end
	  
	}
	
	prtsCount = parts.length
	if prtsCount == 0
	  UI.messagebox("There were no Groups or Components selected")
	  return
	end
	
	numParts = parts.length.to_s

  result = UI.messagebox(numParts + " scene/s will be created\n- a scene for each component/group in the selection. \n\n Do you wish to continue?", MB_YESNO)
	if result == 6
	  self.compFocus(parts)
	end	
	
end


end
# ------------------------------------------------------


if not file_loaded?(File.basename(__FILE__))
UI.menu("Plugins").add_item("Parts --> Scenes") {VPARTS.viewParts}
end

file_loaded("viewparts.rb")   # Mark the script loaded.
