module WindowTools; end
def WindowTools.draw_mullion(mfwidth, mvpanes, mhpanes, mwidth, mthick, mset, pts)
  #----------------------------------------------------------------------------------
    model=Sketchup.active_model
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
    pt0=Geom::Point3d.new(pts[0][0], pts[0][1], pts[0][2])
    pt0=Geom::Point3d.new(pts[0])
    pt1=Geom::Point3d.new(pts[1][0], pts[1][1], pts[1][2])
    pt1=Geom::Point3d.new(pts[1])
    pt2=Geom::Point3d.new(pts[2][0], pts[2][1], pts[2][2])
    pt2=Geom::Point3d.new(pts[2])
    pt3=Geom::Point3d.new(pts[3][0], pts[3][1], pts[3][2])
    pt3=Geom::Point3d.new(pts[3])
    
    #------find the points for the head btw. pt0 & pt3
    pt0j=translate(pt0, pt0, pt3, mfwidth)
    #------find the points for the head btw. pt1 & pt2
    pt1j=translate(pt1, pt1, pt2, mfwidth)
    #------find the points for the sill btw. pt0 & pt3
    pt2j=translate(pt2, pt2, pt1, mfwidth)
    #------find the points for the sill btw. pt1 & pt2
    pt3j=translate(pt3, pt3, pt0, mfwidth)
    #------find the points for the left jamb btw. pt0j & pt1j
    pt0jj=translate(pt0j, pt0j, pt1j, mfwidth)
    #------find the points for the left jamb btw. pt3j & pt2j
    pt3jj=translate(pt3j, pt3j, pt2j, mfwidth)
    #------find the points for the right jamb btw. pt0 & pt3
    pt1jj=translate(pt1j, pt1j, pt0j, mfwidth)
    #------find the points for the right jamb btw. pt1 & pt2
    pt2jj=translate(pt2j, pt2j, pt3j, mfwidth)

    #------width of opening minus framewidth (mfwidth)
    vLength=pt0jj.distance pt3jj
    #------height of opening minus framewidth (mfwidth)
    hLength=pt1jj.distance pt0jj 
    #------width of pane
    vPane=(vLength - (mvpanes -1) * mwidth)/mvpanes
    #------height of pane
    hPane=(hLength - (mhpanes -1) * mwidth)/mhpanes

    #------create a mullion mask over opening minus framewidth (mfwidth)
    group=entities.add_group
    entities=group.entities 
    base=entities.add_face(pt0,pt1,pt2,pt3)
    #base=entities.add_face(pt0jj,pt1jj,pt2jj,pt3jj)
    base.pushpull mthick
    
    #------points required to create the 1st pane
    pt4jj=translate(pt3jj, pt3jj, pt2jj, hPane)
    pt6jj=translate(pt3jj, pt3jj, pt0jj, vPane)
    pt7jj=translate(pt0jj, pt0jj, pt1jj, hPane)
    pt5jj=translate(pt4jj, pt4jj, pt7jj, vPane)
        
    # The first pane is in the correct location regardless of the values of
    # mfwidth or mwidth, and it also has the right proportional size
    # set by mvpanes & mhpanes
    #entities.add_cpoint pt3jj
    #entities.add_cpoint pt4jj
    #entities.add_cpoint pt5jj
    #entities.add_cpoint pt6jj

    hVec = pt4jj - pt3jj
    vVec = pt6jj - pt3jj
   
    1.upto(mvpanes) do |i|
      x = (vPane*i)+(i*mwidth)  
      1.upto(mhpanes) do |j|
	    y = (hPane*j)+(j*mwidth) 
        
	    o = pt3jj.offset(hVec, y - mwidth).offset(vVec, x - mwidth)
        pt1 = o.offset(hVec, -hPane)
	    pt2 = o.offset(vVec, -vPane)
	    pt3 = pt1.offset(vVec, -vPane)
	    #entities.add_cpoint o
	    #entities.add_cpoint pt1
	    #entities.add_cpoint pt2
	    #entities.add_cpoint pt3
        face = entities.add_face o, pt1, pt3, pt2
	    face.pushpull -mthick
        
        normal = base.normal
        normal.length = mset/9 
        tr = Geom::Transformation.translation(normal.reverse)
        group.transform! tr
	    #entities.add_text( "(#{x}, #{y})", [x, y] )
      end
    end
    model.commit_operation
  end