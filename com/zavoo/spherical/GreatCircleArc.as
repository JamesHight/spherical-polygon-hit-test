package com.zavoo.spherical
{
	public class GreatCircleArc extends GreatCircle
	{
		public var crosses_pole:Boolean = false;
		
		public var lon_range:LonRange;
		public var lat_range:LatRange;
		
		public var arc_length_rad:Number;
		
		public var arc_length_deg:Number;
		
		//private var numerator:Number;
		//private var denominator:Number;
		
		private var g:Number;
		private var h:Number;
		private var w:Number;
		
		private var i:int;
		
		private var tmp_pnt: SPoint;
		
		//private var planar_const:Number;		
		//private var sphere_const:Number;		
		//private var scale:Number;
		//private var rad:Number;
		//private var firstX:Number;
		//private var secondX:Number;
		
		private var tmp_lat:Number;
		private var tmp_lon:Number;
		
		public function GreatCircleArc(given_lat0:Number, given_lon0:Number, 
		   given_lat1:Number, given_lon1:Number):void
	    {
	    	super(given_lat0,given_lon0,given_lat1,given_lon1);	
			arc_point[0] = new SPoint(given_lat0, given_lon0);
			arc_point[1] = new SPoint(given_lat1, given_lon1);				    
			init();
	    }
	    
	    protected override function init():void
	    {			
			
			if(arc_point[0].lon == arc_point[1].lon) 
			   is_meridian = true;
			   
			if((arc_point[0].lon == arc_point[1].lon + 180.0) ||
			   (arc_point[0].lon + 180.0 == arc_point[1].lon))
			    {
				is_meridian = true;	
				crosses_pole = true;
			    }
			if(!is_meridian)
			    orientArc();
		
			a = (arc_point[0].y * arc_point[1].z) - (arc_point[1].y * arc_point[0].z);
			b = (arc_point[1].x * arc_point[0].z) - (arc_point[0].x * arc_point[1].z);
			c = (arc_point[0].x * arc_point[1].y) - (arc_point[1].x * arc_point[0].y);
				
			lon_range = new LonRange(arc_point[0].lon, arc_point[1].lon);
			lat_range = new LatRange(arc_point[0].lat, arc_point[1].lat);
		
			this.computeInflectionPoint();
			
			if(!is_meridian && lon_range.contains(inflection_point.lon))
			    lat_range.max = inflection_point.lat;
			
			if(!is_meridian && lon_range.contains(inflection_point.lon - 180.0))
			    lat_range.min = -inflection_point.lat;
			
			if(arc_point[0].lat == arc_point[1].lat &&
			   arc_point[0].lon == arc_point[1].lon)
			    arc_length_rad = 0.0;
			else
			    arc_length_rad = Math.acos((Math.cos(radians(arc_point[0].lat)) * 
							Math.cos(radians(arc_point[0].lon)) * 
							Math.cos(radians(arc_point[1].lat)) * 
							Math.cos(radians(arc_point[1].lon))) +
						       (Math.cos(radians(arc_point[0].lat)) * 
							Math.sin(radians(arc_point[0].lon)) * 
							Math.cos(radians(arc_point[1].lat)) * 
							Math.sin(radians(arc_point[1].lon))) +
						       (Math.sin(radians(arc_point[0].lat)) * 
							Math.sin(radians(arc_point[1].lat))));
		
			arc_length_deg = degrees(arc_length_rad);
	
	    }
		
		/**
	     * The orient method.
	     *
	     * We always use the shortest arc from point 0 to point 1 and
	     * it is convenient to orient that arc from west to east.
	     */
	    private function orientArc():void
	    {
			if(isNaN(arc_point[0].lon) || isNaN(arc_point[1].lon))
			    return;
		
			arc_point[0].lon = normalize(arc_point[0].lon);
			arc_point[1].lon = normalize(arc_point[1].lon);
			
			/*
			 *  Eliminate dateline problems 
			 */
			while(0.0 > arc_point[0].lon || 0.0 > arc_point[1].lon){
			    arc_point[0].lon += 360.0;
			    arc_point[1].lon += 360.0;
			}
			
			/*
			 * if W-E is more than 180 degrees switch points
			 */
			if(arc_point[0].lon < arc_point[1].lon && 
			   (arc_point[1].lon - arc_point[0].lon) > 180.0)
			    {
				tmp_pnt = arc_point[0];
				arc_point[0] = arc_point[1];
				arc_point[1] = tmp_pnt;
				
			    }
		
			/* 
			 * if E->W is greater than 180 then W->E is less than 180
			 */
			if(arc_point[0].lon > arc_point[1].lon && arc_point[0].lon-arc_point[1].lon > 180.0){
			    arc_point[1].lon += 360.0;
			}
		
			/* 
			 * if E->W is less than 180 switch points to make it W->E
			 */
			if(arc_point[0].lon > arc_point[1].lon && arc_point[0].lon-arc_point[1].lon < 180.0){
			    tmp_pnt = arc_point[0];
			    arc_point[0] = arc_point[1];
			    arc_point[1] = tmp_pnt;
			}
			
			/*
			 *  Check the results
			 */
						
			arc_point[0].lon = normalize(arc_point[0].lon);
			arc_point[1].lon = normalize(arc_point[1].lon);
		
	    } /* END orientArc() */
	
	    /**********************************************************************
	     * The intersect methods.
	     **********************************************************************/
	
	    /**
	     * Determine if this arc intersects another.
	     * <P>
	     * The basic strategy is to convert everything to cartesian 3-space first
	     * because the math is easier.  All the action takes place in cartesian space.  
	     * Then we convert back to spherical and see what's what.
	     * 
	     * @return true    if the two arcs intersect.<br>
	     *         false   if the two arcs do not instersect.
	     *
	     * @see nsidc.spheres.Scene
	     **/
	
	    public function intersectsArc(other:GreatCircleArc):Boolean
	    {
			/*
			 * First check the trivial case.
			 */
			if(null == other)
			    return false;
		
			/* 
			 * Then check if it's even possible.
			 */
			if(!this.lon_range.overlaps(other.lon_range)){

			    return false;
			}
			
			if(!this.lat_range.overlaps(other.lat_range)){
			   

			    return false;
			}	
			    
	
			
			/*
			 * Then the special cases.
			 * If both great circles are meridians they cross at the poles.
			 *
			 * So if both arcs cross the pole the arcs cross.
			 */
			if(this.is_meridian && other.is_meridian)
			    {

				if((this.arc_point[0].lon == this.arc_point[1].lon + 180.0 ||
				    this.arc_point[0].lon + 180.0 == this.arc_point[1].lon) &&
				   (other.arc_point[0].lon == other.arc_point[1].lon + 180.0 ||
				    other.arc_point[0].lon + 180.0 == other.arc_point[1].lon))
				    {
					if((this.arc_point[0].lat >= 0.0 && other.arc_point[0].lat >= 0.0) ||
					   (this.arc_point[0].lat <= 0.0 && other.arc_point[0].lat <= 0.0))
					    {
					    return true;}
					else
					    return false;
				    }
				else
				    return false;
			    }
		
			/*
			 * If one arc is a meridian check that the intersect point is within the 
			 * lat range for that arc.
			 * 
			 * If neither arc is part of a meridian the great circles the two arcs
			 * are part of cross every meridian exactly once.  Moreover the two
			 * great circles cross each other exactly twice.  Find those crossing 
			 * points and check if the lon of the crossing is within the lon range 
			 * of both arcs and voila!
			 */
			
			/*
			 * find the intersect points.
			 *
			 * All great circles cross - this method only fails if there is 
			 * no other circle, which we already checked for - but something 
			 * odd might happen.
			 */

			if (!this.intersectsGreatCircle(other))
			    {

				return false;
			    }
		
			/*
			 * Check the lat range of the meridian.  This isn't actually correct because the arc
			 * could pass through the inflection point, but it'll do for now.  I still have to 
			 * figure out how to determine the inflection point and what to do about it once I've 
			 * found it.
			 */
			if(this.is_meridian && 
			   Math.min(this.arc_point[0].lat,this.arc_point[1].lat) <=  intersect_point[0].lat &&
			   Math.max(this.arc_point[0].lat,this.arc_point[1].lat) >=  intersect_point[0].lat)
			   {    		    

				return true;
			    }
			
			if(this.is_meridian && 
			   Math.min(this.arc_point[0].lat,this.arc_point[1].lat) <=  intersect_point[1].lat &&
			   Math.max(this.arc_point[0].lat,this.arc_point[1].lat) >=  intersect_point[1].lat)
			   {    		    

				return true;
			    }
		
			if(other.is_meridian && 
			   Math.min(other.arc_point[0].lat,other.arc_point[1].lat) <=  intersect_point[0].lat &&
			   Math.max(other.arc_point[0].lat,other.arc_point[1].lat) >=  intersect_point[0].lat)
			   {    		    
				return true;
			    }
			
			if(other.is_meridian && 
			   Math.min(other.arc_point[0].lat,other.arc_point[1].lat) <=  intersect_point[1].lat &&
			   Math.max(other.arc_point[0].lat,other.arc_point[1].lat) >=  intersect_point[1].lat)
			   {    		    
				
				return true;
			    }
		
			if(this.is_meridian || other.is_meridian)
			    {
				
				return false;
			    }
		
			/*
			 * Otherwise check if the intersects are in the lon range of both arcs.
			 * The intersects are on both great circles, so if an intersect
			 * is in the same region as both arcs it is on both arcs.
			 */

			if(this.lon_range.contains(intersect_point[0].lon) &&
			   other.lon_range.contains(intersect_point[0].lon))
			    {    		    

				return true;
			    }
			
			if(this.lon_range.contains(intersect_point[1].lon) &&
			   other.lon_range.contains(intersect_point[1].lon))
			    {				

				return true;
			    }
			/*
			 * tried everything and failed.
			 */
			
			return false;
		
	    } /* END intersectsArc */
	    
	    
	    /**
	     * Determine if this arc intersects a segment of a parallel.
	     * <P>
	     * The basic strategy is to convert everything to cartesian 3-space first
	     * because the math is easier.  All the action takes place in cartesian space.  
	     * Then we convert back to spherical and see what's what.
	     *
	     * @param seg_lat The latitude of the segment.
	     * @param min_lon The minimun longitude of the segment.
	     * @param max_lon The maximum longitude of the segment.
	     *
	     * @return true    if the two arcs intersect.<br>
	     *         false   if the two arcs do not instersect.
	     *
	     * @see nsidc.spheres.LatLonBoundingBox
	     */
	    public function intersectsLatSeg(seg_lat:Number, min_lon:Number, max_lon:Number):Boolean
	    {
			/**
			 * First check if it's even possible.
			 */
			
			if(!this.lon_range.overlaps(new LonRange(min_lon, max_lon)))
			    return false;
			if(Math.abs(seg_lat) > inflection_point.lat)
			    return false;
			/*
			 * Find the intersects.
			 *
			 * This method only fails if the lat is out of range, which we 
			 * already checked for - but something odd might happen.
			 */
		
			if (!this.intersectsLatitude(seg_lat))
		    {
				return false;
		    } 
		
			if(this.lon_range.contains(intersect_point[0].lon) &&
			   min_lon <= intersect_point[0].lon && intersect_point[0].lon <= max_lon)
			    return true;
			
			if(this.lon_range.contains(intersect_point[1].lon) &&
			   min_lon <= intersect_point[1].lon && intersect_point[1].lon <= max_lon)
			    return true;
			
			return false;
	    }
	
	
	    /**
	     * Determine if this arc intersects a small circle arc.
	     * <P>
	     * The basic strategy is to convert everything to cartesian 3-space first
	     * because the math is easier.  All the action takes place in cartesian space.  
	     * Then we convert back to spherical and see what's what. This method is not  
	     * actually implemented yet and always returns false.
	     *
	     * @param small_circle_arc The small circle arc of interest.
	     *
	     * @return true    if the two arcs intersect.<br>
	     *         false   if the two arcs do not instersect.
	     *
	     * @see nsidc.spheres.SmallCircle
	     * @see nsidc.spheres.SmallCircleArc
	     * @see nsidc.spheres.Scene
	     */
	    /* public function intersectsSCArc(small_circle_arc:SmallCircleArc):Boolean
	    { 
	
			return false;
	
	     }*/ /* END intersectsSCArc(small_circle_arc)  */
	
	
	    /**
	     * Find the center of the arc
	     * <P>
	     * Equations taken from the Aviation Formulary by Ed Williams.
	     *
	     * @param none.
	     *
	     * @return Point center_point The point at the center of the Arc.
	     *
	     */
	    public function center():SPoint
	    {	
			var A:Number;
			var B:Number;
			var f:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			var lat:Number;
			var lon:Number;
			
			var center_point:SPoint;
			
			A=Math.sin((0.5)*arc_length_rad)/Math.sin(arc_length_rad);
			B=Math.sin(0.5*arc_length_rad)/Math.sin(arc_length_rad);
			
			x = A*Math.cos(radians(arc_point[0].lat))*Math.cos(radians(arc_point[0].lon)) +  
			    B*Math.cos(radians(arc_point[1].lat))*Math.cos(radians(arc_point[1].lon));
			y = A*Math.cos(radians(arc_point[0].lat))*Math.sin(radians(arc_point[0].lon)) +  
			    B*Math.cos(radians(arc_point[1].lat))*Math.sin(radians(arc_point[1].lon));
			z = A*Math.sin(radians(arc_point[0].lat)) + B*Math.sin(radians(arc_point[1].lat));
			
			lat=Math.atan2(z, Math.sqrt(x*x+y*y));
			lon=Math.atan2(y,x);
			center_point = new SPoint(degrees(lat), degrees(lon));
			
			x= A*arc_point[0].x + B*arc_point[1].x;
			y= A*arc_point[0].y + B*arc_point[1].y;
			z= A*arc_point[0].z + B*arc_point[1].z;
			center_point = new SPoint(x,y,z);
			
			return center_point;
	    }
	
	    /**
	     * Densify the arc
	     * <P>
	     * Equations taken from the Aviation Formulary by Ed Williams.
	     *
	     * @param distance_rad The maximum distance in radians between points in the densified arc.
	     *
	     * @return Point[] dense_point A denser point set defining the same arc.
	     *
	     */
	    public  function densify(distance_rad:Number):Array
	    { 
			var num_points:int = (arc_length_rad/distance_rad) + 2;
			
			var dense_point:Array = new Array(num_points);/* Point[num_points]; */
			
			var fraction:Number = distance_rad / arc_length_rad;
			
			var A:Number;
			var B:Number;
			var f:Number;
			
			var x:Number;
			var y:Number;
			var z:Number;
			
			var lat:Number;
			var lon:Number;
			
			if(distance_rad >= arc_length_rad) return arc_point;

			dense_point[0] = new SPoint(arc_point[0].lat, arc_point[0].lon);

			for(i=1; i<num_points-1; i++)
			{
				f = fraction*i;
				A=Math.sin((1.0-f)*arc_length_rad)/Math.sin(arc_length_rad);
				B=Math.sin(f*arc_length_rad)/Math.sin(arc_length_rad);
				
				x = A*Math.cos(radians(arc_point[0].lat))*Math.cos(radians(arc_point[0].lon)) +  
				    B*Math.cos(radians(arc_point[1].lat))*Math.cos(radians(arc_point[1].lon));
				y = A*Math.cos(radians(arc_point[0].lat))*Math.sin(radians(arc_point[0].lon)) +  
				    B*Math.cos(radians(arc_point[1].lat))*Math.sin(radians(arc_point[1].lon));
				z = A*Math.sin(radians(arc_point[0].lat)) + B*Math.sin(radians(arc_point[1].lat));
					
				lat=Math.atan2(z, Math.sqrt(x*x+y*y));
				lon=Math.atan2(y,x);
				dense_point[i] = new SPoint(degrees(lat), degrees(lon));
				
		
				x= A*arc_point[0].x + B*arc_point[1].x;
				y= A*arc_point[0].y + B*arc_point[1].y;
				z= A*arc_point[0].z + B*arc_point[1].z;
				dense_point[i] = new SPoint(x,y,z);
		
		
			}
			dense_point[i] = new SPoint(arc_point[1].lat, arc_point[1].lon);
			
			return dense_point;
		}
		    
	}
}