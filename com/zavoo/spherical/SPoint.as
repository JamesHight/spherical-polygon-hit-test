package com.zavoo.spherical
{
	public class SPoint extends Sphere
	{
		public var lat:Number;
		public var lon:Number;
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function SPoint(given_lat:Number, given_lon:Number, given_z:Object = null):void
    	{
    		if (given_z == null)
    		{
				lat = given_lat;
				lon = given_lon;
				x = radius * Math.cos(radians(lon)) * Math.cos(radians(lat));
				y = radius * Math.sin(radians(lon)) * Math.cos(radians(lat));
				z = radius * Math.sin(radians(lat));
    		}
    		else
    		{
    			SPoint2(given_lat, given_lon, Number(given_z));    			
    		}
	    }
	    
	    public function SPoint2(given_x:Number, given_y:Number, given_z:Number):void
    	{
			x = given_x;
			y = given_y;
			z = given_z;
			//lat = 90.0 - degrees(Math.asin(z/radius));
			lat = degrees(Math.asin(z/radius));
			lon = degrees(Math.atan2(y, x));
   		}
	    
	    /**
	     * Use a different radius.
	     */
		public function setRadius(given_radius:Number):void
	    {
			//this.setRadius(given_radius);
			x = radius * Math.cos(radians(lon)) * Math.cos(radians(lat));
			y = radius * Math.sin(radians(lon)) * Math.cos(radians(lat));
			z = radius * Math.sin(radians(lat));
	    }
	
	    /**
	     * Reset the point from known spherical coordinates.
	     */
	    public function reset(given_lat:Number, given_lon:Number):void
	    {
			lat = given_lat;
			lon = given_lon;
			x = radius * Math.cos(radians(lon)) * Math.cos(radians(lat));
			y = radius * Math.sin(radians(lon)) * Math.cos(radians(lat));
			z = radius * Math.sin(radians(lat));
	    }	    
		
	}
}