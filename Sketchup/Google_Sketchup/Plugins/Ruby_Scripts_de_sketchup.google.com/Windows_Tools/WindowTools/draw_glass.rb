module WindowTools; end
def WindowTools.draw_glass(vertoff, horizoff, gthick, glinset, pts)
  #--------------------------------------------------------------------------
  model=Sketchup.active_model
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

  group=entities.add_group
  entities=group.entities

  #------create a new set of points from the original 3 point pick
  pt0=Geom::Point3d.new(pts[0][0], pts[0][1], pts[0][2])
  pt0=Geom::Point3d.new(pts[0])
  pt1=Geom::Point3d.new(pts[1][0], pts[1][1], pts[1][2])
  pt1=Geom::Point3d.new(pts[1])
  pt2=Geom::Point3d.new(pts[2][0], pts[2][1], pts[2][2])
  pt2=Geom::Point3d.new(pts[2])
  pt3=Geom::Point3d.new(pts[3][0], pts[3][1], pts[3][2])
  pt3=Geom::Point3d.new(pts[3])

  #------now find the points for the upper jamb btw. pt0 & #pt3
  pt0j=translate(pt0, pt0, pt3, horizoff)
  #------find the points for the upper jamb thickness btw. pt1 & #pt2
  pt1j=translate(pt1, pt1, pt2, horizoff )
  #------now find the points for lower jamb thickness btw. pt0 & #pt3
  pt2j=translate(pt2, pt2, pt1, horizoff)
  #------find the points for lower jamb thickness btw. pt1 & #pt2
  pt3j=translate(pt3, pt3, pt0, horizoff)
  #------now the points for the left jamb btw. pt0j & #pt1j
  pt0jj=translate(pt0j, pt0j, pt1j, vertoff)
  #------find the points for the left jamb btw. pt3j & #pt2j
  pt3jj=translate(pt3j, pt3j, pt2j, vertoff)
  #------now the points for the right jamb btw. pt0 & #pt3
  pt1jj=translate(pt1j, pt1j, pt0j, vertoff)
  #------find the points for the right jamb btw. pt1 & #pt2
  pt2jj=translate(pt2j, pt2j, pt3j, vertoff)

  #------Do the Glazing 
  group=entities.add_group
  entities=group.entities
  base=entities.add_face(pt0jj, pt1jj, pt2jj, pt3jj)
  base.material=Sketchup::Color.new(163,204,204) #change RGB Color number here
  base.material.alpha = 0.6 #change opacity number here
  base.pushpull -gthick
  normal=base.normal
  normal.length= -glinset-gthick
  tr=Geom::Transformation.translation(normal.reverse)
  group.transform! tr

  model.commit_operation
end
