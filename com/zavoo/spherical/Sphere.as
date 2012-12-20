package com.zavoo.spherical
{
	public class Sphere
	{
		public var radius:Number;
		
		/* Radius of the earth in km. */
		public const Re_km:Number = 6367.435;		
		
		public const Ru_km:Number = 10.0;
		
		public function Sphere()
		{			
			radius = Ru_km;
		}
		
		public function normalize(lon:Number):Number
    	{
			while (lon < -180.0) lon += 360.0; 
			while (lon >  180.0) lon -= 360.0; 
			return lon;
	    } 
	    
	   	public function radians(deg:Number):Number
	    {	
			return  ((deg) * Math.PI / 180.0);
	    }  
	    
		public function degrees(rad:Number):Number
	    {
			return ((rad) * 180.0 / Math.PI);
	    }
	    
	    public function scalarTripleProductTest(given_point:SPoint, 
				       start_point:SPoint,
				       end_point:SPoint):int
	    {
	    	var product:Number;
			var result:int;

			product = ((given_point.x*start_point.y*end_point.z)
		   +(given_point.z*start_point.x*end_point.y)
		   +(given_point.y*start_point.z*end_point.x)
		   -(given_point.z*start_point.y*end_point.x)
		   -(given_point.x*start_point.z*end_point.y)
		   -(given_point.y*start_point.x*end_point.z));

		  if(Math.abs(product) < 10*Number.MIN_VALUE) return 0;
		  else if(product < 0) return -1;
		  return 1;
	    	
	    }
	    
	   
	}
}