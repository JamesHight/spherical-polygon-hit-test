package com.zavoo.spherical
{
	public class LatRange extends Sphere
	{
		/**
	     * minimum latitude in range.
	     */
	    public var min:Number = -90.0;
	    
	    /**
	     * maximum latitude in range.
	     */
	    public var max:Number = 90.0;
	     
	    /**
	     * temporary variable.
	     */
	    private var tmp_lat:Number = 90.0;
	    
	    public function LatRange(givenMin:Number, givenMax:Number):void
	    {
			min = givenMin;
			max = givenMax;
			
			if(max < min){
			    tmp_lat = max;
			    max = min;
			    min = tmp_lat;   
			}
	    }
	    
	    /**
	     * Determine if the given latgitude is within the range.
	     */
	    public function contains(lat:Number):Boolean
	    {
			if(min <= lat && lat <= max)
			    return true;
			return false;
	    }    
	    
		/**
	     * Determine if this range overlaps another.
	     */
	    public function overlaps(other_range:LatRange):Boolean
	    {
			/* 
			 * Check for nothing  
			 */
			if(null == other_range)
			    return false;
		
			/*  
			 * Check for everything
			 */
			if((max - min) >= 180.0)
			    return true;
			
			if((other_range.max - other_range.min) >= 180.0)
			    return true;
		
			/*  
			 * Check for any overlap.
			 */	    
			if((min <= other_range.min && other_range.min <= max) ||
			   (min <= other_range.max && other_range.max <= max) ||
			   (other_range.min <= min && min <= other_range.max) ||
			   (other_range.min <= max && max <= other_range.max)) 
			    return true;
		
			/*  
			 * Else the ranges do not overlap.
			 */
			return false;
	    }
	
	    /**
	     * Combine two ranges if possible.  
	     * <br>
	     * If the two ranges overlap this range is adjusted to include the 
	     * other and true is returned. The other range can then be discarded 
	     * by the calling method.
	     * <br>
	     * If the two ranges do not overlap no changes are made and 
	     * false is returned.
	     */
	    public function meldRange(other_range:LatRange):Boolean
	    {
		
			/*   Check for nothing    
			 */
			if(null == other_range)
			    return true;
			
			if(isNaN(other_range.min) || isNaN(other_range.max))
			    return false;
			
			if(isNaN(min) || isNaN(max)){
			    min = other_range.min;
			    max = other_range.max;
			    return true;
			}
			
		
			/*  Check for everything
			 */
			if((max - min) >= 180.0)
			    return true;
			
			if((other_range.max - other_range.min) >= 180.0){
			    min = -90.0;
			    max = 90.0;
			    return true;
			}
			
			/*  
			 *  Check for any overlap and merge if there is overlap.
			 */	    
			if((min <= other_range.min && other_range.min <= max) ||
			   (min <= other_range.max && other_range.max <= max) ||
			   (other_range.min <= min && min <= other_range.max) ||
			   (other_range.min <= max && max <= other_range.max)) {
			    min = Math.min(min, other_range.min);
			    max = Math.max(max, other_range.max);
			    
			    if(max - min >= 180.0){
				min = -90.0;
				max = 90.0;
			    }
			    return true;
			}
			/*  Else the ranges do not overlap - do nothing.
			 */
			return false;
		
	    } /* END meldRange */	    
	}
}