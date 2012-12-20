package com.zavoo.spherical
{
	public class SmallCircle extends GreatCircle
	{
		public var distance:Number;
	    //public var arc_point:Array = new Array(2);
	    //public var intersect_point:Array = new Array(2);
	    
	    //protected var m:Number;
	    //protected var n:Number;
	    //protected var p:Number;
	    //protected var q:Number;
	    
	    protected var lon_range:LonRange;
	    
	    public function SmallCircle(given_lat0:Number, given_lon0:Number, 
		       given_lat1:Number, given_lon1:Number,
		       given_distance:Number):void
	    {
	    	super(given_lat0,given_lon0,given_lat1,given_lon1);
			if(given_distance > radius)
			    return;
		
			copyGC(new GreatCircle(given_lat0, given_lon0, 
					       given_lat1, given_lon1));
			distance = given_distance;
	    }
	    
	    public function copyGC(reference:GreatCircle):void
	    {
			this.a = reference.a;
			this.b = reference.b;
			this.c = reference.c;
			this.is_meridian = reference.is_meridian;
	    }
	
	    /**
	     * Determine if this small circle is parallel to a given great circle.
	     */
	    public function parallel(gc:GreatCircle):Boolean
	    {
			return(this.a == gc.a && this.b == gc.b && this.c == gc.c);
	    }
	
	
	    
	    /*******************************************************************
	     * Intersect methods.
	     *******************************************************************/
	    
	    /**
	     * Determine if this small circle intersects another.
	     *
	     * @param other Another small circle.
	     *
	     * @result true - if the two arcs intersect.<br>
	     *         false - if the two arcs do not intersect.
	     */
	    
	    public override function intersectsSmallCircle(other:SmallCircle):Boolean
	    {
			/* double  m,n,p,q;
			double numerator, denominator;
			double sqr_term, lin_term, const_term, rad;
			double tmp_z;
			*/
			intersect_point[0] = null;
			intersect_point[1] = null;
		
			/*
			 * first check see if it's even possible.
			 */
			if(!(this.lon_range.overlaps(other.lon_range)))
			    return false;
			
			/*
			 * Each small circle is defined by ax+by+cz = d and
			 * we want to know where they intersect on the sphere.
			 * 
			 * So we have three equations and three unkowns.
			 * First solve for x in terms of z so:
			 * x = (d-by-cz)/a
			 *
			 * Then solve ex+fy+gz = h for y in terms of z so:
			 * e(d-by-cz)/a + fy + gz = h
			 * ed/a - eby/a - ecz/a + fy + gz = h
			 * y(f-eb/a) = h - ed/a + ecz/a - gz
			 * y = (h - ed/a + ecz/a - gz)/(f-eb/a) or
			 * y = z((ec/a - g)/(f-eb/a)) + ((h - ed/a)/(f-eb/a))
			 * so let
			 */
			numerator = ((other.a * c)/a) - other.c;
			denominator = other.b - ((other.a * b)/a);
			m = numerator / denominator;
			
			numerator = other.distance - ((other.a * distance)/a);
			denominator = other.b - ((other.a * b)/a);
			n = numerator / denominator;
			
			/*
			 * So y = mz + n which means
			 * x = (d-b(mz+n)-cz)/a
			 * x = (d - bmz - bn - cz)/a
			 * x = z(-bm -c)/a + (d-bn)/a
			 * so let
			 */
			numerator = (-b * m) -c;
			p = numerator / a;
			
			numerator = distance - (b * n);
			q = numerator / a;
			
			/*
			 * so x = pz + q;
			 *
			 * substitute in the equation of the sphere and solve for z
			 * (pz+q)^2 + (mz+n)^2  + z^2 = r^2
			 * p^2z^2 + 2pzq + q^2 + m^2z^2 + 2mzn + n^2 + z^2 = r^2
			 * z^2(1+p^2+n^2) + z(2pq + 2mn) + q^2 + p^2 = r^2 
			 * so let
			 */
			
			sqr_term = 1.0+(p*p)+(n*n);
			lin_term = (2.0*p*q) + (2.0*m*n);
			const_term = (q*q) + (p*p) - (radius * radius);
			
			/*
			 * So sqr_trm(z^2) + lin_term(z) + const_term = 0
			 *
			 * Solve for z
			 * z = (-lin (-+) sqrt(lin^2 - 4*const*sqr))/2*sqr
			 */
			
			rad = (lin_term*lin_term) - (4.0*const_term*sqr_term);
			
			/* 
			 * If rad is negative taking the sqaure root would involve 
			 * imaginary numbers.  I'm guessing this means the circles 
			 * don't cross.
			 */
			if(rad < 0.0)
			    return false;
		
			rad = Math.sqrt(rad);
			numerator = -lin_term - rad;
			denominator = 2.0*sqr_term;
			tmp_z = numerator/denominator;
			intersect_point[0] = new SPoint(((p*tmp_z)+q), ((m*tmp_z)+n), tmp_z);
		
			numerator = -lin_term + rad;
			tmp_z = numerator/denominator;
			intersect_point[1] = new SPoint(((p*tmp_z)+q), ((m*tmp_z)+n), tmp_z);
			
			return true;
		    
	    }
	}
}