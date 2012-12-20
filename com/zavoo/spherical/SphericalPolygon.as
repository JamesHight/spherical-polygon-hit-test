package com.zavoo.spherical
{
	public class SphericalPolygon extends Sphere
	{
		public var corner_point:Array;
		
		public var lon_range:LonRange;
		public var lat_range:LatRange;
		
		public var perimeter_rad:Number;
		public var perimeter_deg:Number;
		
		public var external_point:SPoint;
		
		private var i:int;
		private var j:int;
		private var k:int;
		
		private var arc:GreatCircleArc;
		private var other_arc:GreatCircleArc;
		
		public function SphericalPolygon(given_points:Array):void
	    {	
			corner_point = new Array(given_points.length);
			
			for(i=0; i<given_points.length; i++)
			    corner_point[i] = new SPoint(given_points[i].lat, given_points[i].lon);
			
			getRanges();
			//getLonRange();
			//max_lat = rangeMax(lat_array);
			//min_lat = rangeMin(lat_array);
			//getPerimeter();
	    }
	
		
	    /*******************************************************************
	     * getRanges method.
	     *******************************************************************/
	    /**
	     * Determine the lon range, lat range, and perimeter of this polygon.
	     * <P>
	     * This method just adds up the arc distance of all the arcs that 
	     * make up the polygon, and melds the ranges.
	     */
	    private function getRanges():void
	    {
			lon_range = (new GreatCircleArc(corner_point[0].lat,corner_point[0].lon,
							 corner_point[1].lat,corner_point[1].lon).lon_range);
			lat_range = new LatRange(corner_point[0].lat, corner_point[1].lat);
			perimeter_rad = 0;
		
			for(i=0; i<corner_point.length-1; i++){
			    arc = new GreatCircleArc(corner_point[i].lat, corner_point[i].lon,corner_point[i+1].lat, corner_point[i+1].lon);
			    perimeter_rad += arc.arc_length_rad;

			}
			perimeter_deg = degrees(perimeter_rad);
		
			external_point = guessExternalPoint();
	    }
	
	
	    /*******************************************************************
	     * guessExternalPoint method.
	     *******************************************************************/
	    /**
	     * Guess a point that is outside the polygon.  
	     * <P>
	     * This method has to assume that the polygon is somewhat reasonable.
	     * <P>
	     * If the lon range is the full 360 we're guessing the polygon includes 
	     * a pole.  We're also guessing the included pole is the pole nearest the edges, 
	     * so the other pole and the surrounding area would be excluded. 
	     * <P>
	     * For most purposes those are reasonable guesses, but if you are using a polygon
	     * with an unusual shape you should set the external point yourself. If your 
	     * polygon covers more than a hemisphere, or won't fit within a hemisphere, it 
	     * counts as "unusual".
	     * <P>
	     * If the lon range is not the full 360 the task is much easier and the
	     * guess should be correct.
	     * 
	     */
	    public function guessExternalPoint():SPoint
	    {
			var external_lon:Number;
			var external_lat:Number;
			
			if(lon_range.max - lon_range.min >=360.0){
			    external_lon = 90.0;
			    if(lat_range.max < 0.0)
				 external_lat = 45.0;
			    else if(lat_range.min > 0.0)
				external_lat = -45.0;
			    else if(Math.abs(lat_range.max) >= Math.abs(lat_range.min))
				external_lat = lat_range.min - ((90.0 + lat_range.min)/2.0);
			    else
				external_lat = lat_range.max + ((90.0 - lat_range.max)/2.0);
		
			}else{
			     external_lon = normalize(((lon_range.max+lon_range.min)/2.0) -180.0);
			     
			     if(Math.abs(lat_range.max) >= Math.abs(lat_range.min))
				 external_lat = lat_range.min + ((-90.0 - lat_range.min)/2.0);
			     else
				 external_lat = lat_range.max + ((90.0 - lat_range.max)/2.0);
			}
	
		    return new SPoint(external_lat, external_lon);
	
	    }  /* END private void guessExternalPoint() */
	    
	    /**
	     *  Return the point currently being used as the "external" point.  
	     */
	    public function getExternalPoint():SPoint
	    {
			return external_point;
	    }
	    
	    /**
	     *  Set the point that is to be used as the "external" point.  
	     */
	    public function setExternalPoint(given_point:SPoint):void
	    {
			external_point = new SPoint(given_point.lat, given_point.lon);
	    }
	
	    
	
	    /*******************************************************************
	     * Contains methods.
	     *******************************************************************/
	    
	    /**
	     * Determine if this polygon contains a given point.
	     * <P>
	     * This method creates a great circle arc between the point of 
	     * interest and the "known" external point and counts how many 
	     * times that arc crosses the edges of the polygon. Iff the arc 
	     * crosses an odd number of edges the point of interest must be 
	     * inside the polygon.  
	     * <P>
	     * The corner points are assumed to be in some order.  This should 
	     * work with both convex and concave polygons, but make sure the 
	     * external point actually is external.
	     * <P>
	     * For corner points and points on the edge of the polygon the behavior
	     * is undefined. It "should" be that corner points are "outside" (two edge
	     * crossings) and edge points are "inside" (one edge crossing) but it's 
	     * really down to the precision of the math processor and which way the 
	     * rounding goes. 
	     *
	     * @param given_point Point of interest.
	     *
	     * @returns true  If the point is inside the polygon.
	     *          false If the point is outside the polygon or the algorithm can't figure it out.
	     */
	    
	    public function contains(given_point:SPoint):Boolean
	    { 
			var arc:GreatCircleArc;
			var count:int = 0;
			
			arc = new GreatCircleArc(given_point.lat, given_point.lon, external_point.lat, external_point.lon);
			
			for(i=0; i<corner_point.length-1; i++){
			    if(arc.intersectsArc(new GreatCircleArc(corner_point[i].lat, corner_point[i].lon, 
								    corner_point[i+1].lat, corner_point[i+1].lon)))
				count++;
			}
			if(1 == (count % 2))
			    return true;
			return false;
			
	    }  /* END contains(Point) */
	    
	
	    /**
	     * Determine if this polygon contains a given point using STP.
	     * <P>
	     * This method checks the scalar triple product of the point 
	     * and consective corner points all the way around the polygon. 
	     * If the point is on the same side of every edge, the point 
	     * must be inside the polygon.
	     * <P>
	     * The corner points are assumed to be in some order
	     * and the polygon has to be convex for this to work.  
	     * 
	     * @param given_point Point of interest.
	     *
	     * @returns true  If the point is inside the polygon.
	     *          false If the point is outside the polygon or the algorithm can't figure it out.
	     */
	    public function containsSTP(given_point:SPoint):Boolean
	    {
			var test_result:int;
			var left:Boolean = false
			var right:Boolean = false;
			
			test_result = scalarTripleProductTest(given_point, 
							      corner_point[corner_point.length-1],
							      corner_point[0]);
			if(test_result < 0)
			    right = true;
			else if (test_result > 0)
			    left = true;
			
			for(i=0; i<corner_point.length-1; i++)
			{
				test_result = scalarTripleProductTest(given_point, 
								      corner_point[i],
								      corner_point[i+1]);
				if(test_result < 0)
				    right = true;
				else if (test_result > 0)
				    left = true;
		
				if(left && right)
				    return false;
		 	}
			return true;
		
	    } /* END containsSTP(Point) */
	
	
	
	    /*******************************************************************
	     * Overlap methods for other spherical polygons, lat/lon bounding 
	     * boxes, and scenes.
	     *******************************************************************/
	    
	    /**
	     * Determine if this polygon overlaps another.
	     * 
	     * After determining if it's even possible, and we don't have the 
	     * trivial case where one polygon is entirely inside the other, 
	     * this method checks for arc instersections between the sides of 
	     * the two polygons.  If any arcs intersect the polygons overlap.
	     *
	     * @return true if the polygons overlap.<br>
	     *         false if the polygons do not overlap.
	     *
	     * @see nsidc.spheres.GreatCircleArc
	     **/
	    public function overlaps(other:SphericalPolygon):Boolean
	    {
	
			if(!this.lon_range.overlaps(other.lon_range)){
			    return false;
			}
			/**** WOOOP WOOOP WOOOP ****
			if(true) return true;
			*********/
			
			/*
			 * Then check a single point from each to see if it is inside the other.
			 * If either polygon is wholly inside the other this is the only way to 
			 * catch that.  And we could get lucky even if that's not the case.
			 */

			if(this.contains(other.corner_point[0])){

			    return true;
			}

			if(other.contains(this.corner_point[0])){

			    return true;
			}
			/*
			 * If the two polygons overlap then some pair of sides intersect.
			 * Check them all.
			 */
			

			
			for(i=1; i<=corner_point.length; i++){
			    //System.out.print(".");	
			    //System.out.print(i+": ");	
			 
			    arc = new GreatCircleArc(corner_point[i-1].lat, corner_point[i-1].lon,
						     corner_point[i%corner_point.length].lat, corner_point[i%corner_point.length].lon);
			    for(j=1; j<=other.corner_point.length; j++){
				//System.out.print(j+" ");
				other_arc = new GreatCircleArc(other.corner_point[j-1].lat, other.corner_point[j-1].lon,
							       other.corner_point[j%other.corner_point.length].lat, other.corner_point[j%other.corner_point.length].lon);
				//System.out.println("SP test - ("+(i-1)+", "+(i%corner_point.length)+
				//		   ") : ("+(j-1)+", "+(j%other.corner_point.length)+")");
				//System.out.print(i+":"+j+" ");
				if(arc.intersectsArc(other_arc)){

						       /***
							   +" (("+
							   arc.arc_point[0].lat+", "+arc.arc_point[0].lon+"), ("+
							   arc.arc_point[1].lat+", "+arc.arc_point[1].lon+")) and (("+ 
							   other_arc.arc_point[0].lat+", "+other_arc.arc_point[0].lon+"), ("+
							   other_arc.arc_point[1].lat+", "+other_arc.arc_point[1].lon
							   +")) at ("+ 
							   arc.intersect_point[0].lat+", "+arc.intersect_point[0].lon+") or ("+
							   arc.intersect_point[1].lat+", "+arc.intersect_point[1].lon+")"
						       ***/

						       
				    return true;
				}
			    }
			}
			
			return false;
		
	    } /* END overlaps(SphericalPolygon other) */
	
	    
		      
	    
	
	
	    /**
	     * Densify the polygon
	     * <P>
	     * Densify each arc of the spherical polygon to 
	     * <P>
	     * @param distance_rad The maximum distance in radians between points in the densified polygon.
	     * <P>
	     * @return SphericalPolygon dense_spherical_polygon A denser spherical polygon defining the same area.
	     *
	     */ 
	
	    public function densify( distance_rad:Number):SphericalPolygon
	    { 
			var num_points:Number = (perimeter_rad/distance_rad) + corner_point.length;
			var dense_point:Array = new Array(num_points);
			var arc_point:Array = new Array(num_points);
			var arc:GreatCircleArc;
			
			var fraction:Number;
			var A:Number;
			var B:Number;
			var f:Number;
			
			var double:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			
			var num_arc_points:int = 0;
			
			/* Do nothing if this polygon is already dense enough */
			if(perimeter_rad<distance_rad)
			    return this;
		
			/***************
			 * This is a good idea - but doesn't actually work.
			 * Arcs are oriented W->E which means a lot of these points 
			 * end up in the wrong order.
			 ***
		
			for(i=0, j=0; j<corner_point.length-1; j++){
			    arc = new GreatCircleArc(corner_point[j], corner_point[j+1]);
			    arc_point = arc.densify(distance_rad);
			    for(k=0; k<arc_point.length-2; k++, i++){
				dense_point[i] = new Point(arc_point[k].lat, arc_point[k].lon);
				
			    } 
			    systemLog(i+": "+i+" length: "+num_points, 3);
			    dense_point[i] = new Point(arc_point[k].lat, arc_point[k].lon);
			}
			systemLog(i+": "+i+" length: "+num_points, 3);
			arc_point = new Point[i];
			
			for(i=0; i<arc_point.length; i++)
			    arc_point[i] = dense_point[i];
			    
		
			    ******
			    * This loop preserves the order of the points, at the expense of having to repeat
			    * a lot of the code in the arc densifier.  As a result I'm not sure if the arc 
			    * densifier is even worth having anymore.  But might as well keep it.
			    ********************/
		
			for(i=0, j=0; j<corner_point.length-1; j++){
			    arc = new GreatCircleArc(corner_point[j].lat, corner_point[j], 
			    						corner_point[j+1].lat, corner_point[j+1].lon);
			    
			    dense_point[i] = corner_point[j];

			    i++;
			    if(distance_rad >= arc.arc_length_rad){

				continue;
			    }
			    
			    fraction = distance_rad / arc.arc_length_rad;
			    num_arc_points = (int)((arc.arc_length_rad/distance_rad) + 2.5);
			    f=fraction;
			    for(k=1, f=fraction; f<1.0; k++,f+=fraction, i++){
				//f = fraction*k;
				A=Math.sin((1.0-f)*arc.arc_length_rad)/Math.sin(arc.arc_length_rad);
				B=Math.sin(f*arc.arc_length_rad)/Math.sin(arc.arc_length_rad);

				
				x= A*corner_point[j].x + B*corner_point[j+1].x;
				y= A*corner_point[j].y + B*corner_point[j+1].y;
				z= A*corner_point[j].z + B*corner_point[j+1].z;
		
				dense_point[i] = new SPoint(x,y,z);

				
			    }
			}
			dense_point[i] = corner_point[j];

			arc_point = new SPoint[i+1];
			
			for(i=0; i<arc_point.length; i++)
			    arc_point[i] = dense_point[i];

			return new SphericalPolygon(arc_point);
		}
		    
		
		  
	
	    public function rangeMax(array:Array):Number
	    {
			var max:Number = Number.NEGATIVE_INFINITY;
			/************
			 for(i=0; i<array.length; i++)
			    if(!Double.isNaN(array[i]))
				{
				   max = array[i];
				   break;
				}
			****************/
			for(i=0; i<array.length; i++)
			    if(!isNaN(array[i]))
				max = Math.max(max, array[i]);
			return max;
	    }
	
	    public function rangeMin(array:Array):Number
	    {
			var min:Number = Number.POSITIVE_INFINITY;
			/********************
			for(i=0; i<array.length; i++)
			    if(!Double.isNaN(array[i]))
				{
				    min = array[i];
				    break;
				}
			**************/
			for(i=0; i<array.length; i++)
			    if(!isNaN(array[i]))
				min = Math.min(min, array[i]);
			return min;
	    }
	    
	}
}