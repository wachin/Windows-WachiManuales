require 'sketchup.rb'
# (c) Carlo Roosen 2004

def simplify
  model = Sketchup.active_model
  #define everything as one undo operation
  model.start_operation "Simplify"

  prompts = ["Angle (degrees)"]
  values = [10]
  result=UI.inputbox prompts, values, "hoi"
  angle = (180-result[0])/57.3 #in radians
 
  #search all edges in selection set
  while (model.selection.length>0)
    #remove the first Entity from the Selection and put it in e
    e=model.selection.shift
    if (e.kind_of?(Sketchup::Edge) && e.valid?)
      domino(e,angle)
    end
  end
end

def domino(e0,angle)
    p=e0.parent
    
    t=0
    for v in e0.vertices 
      #count edges connected to v
      if (v.edges.length==2)
        v0=e0.other_vertex(v)
        v1=v
        t=t+1
      end
    end
    if(t!=1)
      return
    end
  
    count=0
    while (true)
  
      for e in v1.edges  
        if (e.entityID  != e0.entityID)
          e1=e
        end
      end
      v2=e1.other_vertex(v1)
      vec1 = v1.position - v0.position
      vec2 = v1.position - v2.position
      #when they have a small angle they are replaced
      if (vec1.angle_between(vec2)>angle)
        enew = p.entities.add_line(v0.position,v2.position)
        e0.erase!
        e1.erase!
        v1=v2
        e0=enew
        count=count+=1
      else
        v0=v1
        v1=v2
        e0=e1
      end
      if (v1.edges.length!=2)
        return
      end
    end 
  UI.messagebox ("#{count} lines less")
end

if( not file_loaded?("simplify.rb") )
  UI.menu("Plugins").add_item("Simplify") { simplify }
end

file_loaded "simplify.rb"

    
  
