module WindowTools; end
def WindowTools.draw_trim(etthick, etwidth, pts)
    #-------------------------------------------------------------------------
    model=Sketchup.active_model
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
    pt0=Geom::Point3d.new(pts[0][0], pts[0][1], pts[0][2])
    pt0=Geom::Point3d.new(pts[0])
    pt1=Geom::Point3d.new(pts[1][0], pts[1][1], pts[1][2])
    pt1=Geom::Point3d.new(pts[1])
    pt2=Geom::Point3d.new(pts[2][0], pts[2][1], pts[2][2])
    pt2=Geom::Point3d.new(pts[2])
    pt3=Geom::Point3d.new(pts[3][0], pts[3][1], pts[3][2])
    pt3=Geom::Point3d.new(pts[3])
  
    #------find the points for the head 
    pt0tt=translate(pt0, pt0, pt1, -etwidth) 
    pt1tt=translate(pt1, pt1, pt0, -etwidth) 
    #------find the points for the sill 
    pt3tt=translate(pt3, pt3, pt2, -etwidth)
    pt2tt=translate(pt2, pt2, pt3, -etwidth)
    #------find the points for the head 
    pt0t=translate(pt0tt, pt0tt, pt3tt, -etwidth)
    pt1t=translate(pt1tt, pt1tt, pt2tt, -etwidth)
    #------find the points for the sill 
    pt3t=translate(pt3tt, pt3tt, pt0tt, -etwidth)
    pt2t=translate(pt2tt, pt2tt, pt1tt, -etwidth)
            
    #------Draw the exterior Trim
    group=entities.add_group
    entities=group.entities
    base=entities.add_face(pt0t, pt1t, pt2t, pt3t)
    base.pushpull -etthick 
    base=entities.add_face(pt0, pt1, pt2, pt3)
    base.pushpull -etthick

    model.commit_operation
end