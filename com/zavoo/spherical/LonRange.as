package com.zavoo.spherical
{
	public class LonRange extends Sphere
	{
		public var min:Number = 999999;
		public var max:Number = -9999999;
		
		 /** 
	     * Assumes West to East orientation.  So if min > max that just means
	     * you're taking the long way round.
	     */
	    public function LonRange(givenMin:Number, givenMax:Number)
	    {
			min = givenMin;
			max = givenMax;
			
			/* Assume the input is correct
			 */
			while(max < min)
			    max += 360.0;
			
			/*  Eliminate dateline problems 
			 */
			while(540.0 < min || 540.0 < max){
			    min -= 360.0;
			    max -= 360.0;
			}
			while(-180.0 > min || -180.0 > max){
			    min += 360.0;
			    max += 360.0;
			}	    		
		}
	
   
	    /**
	     * Determine if the given longitude is within the range.
	     */
	    public function contains(lon:Number):Boolean
	    {
			while(-180.0 > lon)
			    lon += 360.0;
			
			if(min <= lon && lon <= max)
			    return true;
			
			lon += 360.0;
			
			if(min <= lon && lon <= max)
			    return true;
			    
			return false;
	    }  	
	    
	    /**
	     * Determine if this range overlaps another.
	     */
		public function overlaps(other_range:LonRange):Boolean
	    {
			/* 
			 * Check for nothing  
			 */
			if(null == other_range)
			    return false;
		
			/*  
			 * Check for everything
			 */
			if((max - min) >= 360.0)
			    return true;
			
			if((other_range.max - other_range.min) >= 360.0)
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
			 * Check for overlap near the dateline.
			 */
			if((min <= other_range.min + 360.0 && other_range.min + 360.0 <= max) ||
			   (min <= other_range.max + 360.0 && other_range.max + 360.0 <= max) ||
			   (other_range.min <= min + 360.0 && min + 360.0 <= other_range.max) ||
			   (other_range.min <= max + 360.0 && max + 360.0 <= other_range.max)) 
			    return true;
			
			/*  
			 * Else the ranges do not overlap.
			 */
			return false;
	    }	 
	    
		/**
	     * Combine two ranges if possible.  
	     *
	     * If the two ranges overlap this range is adjusted to include the 
	     * other and true is returned. The other range can then be discarded 
	     * by the calling method.\n
	     *
	     * If the two ranges do not overlap no changes are made and 
	     * false is returned.
	     */
	    public function meldRange(other_range:LonRange):Boolean
	    {
		
			/* Check for nothing 
			   
			 */
			if(null == other_range)
			    return true;
			
			if(isNaN(other_range.min) || isNaN(other_range.max))
			    return true;
			
			if(isNaN(min) || isNaN(max))
			{
			    min = other_range.min;
			    max = other_range.max;
			    return true;
			}
			
		
			/*  Check for everything
			 */
			if((max - min) >= 360.0)
			    return true;
			
			if((other_range.max - other_range.min) >= 360.0)
			{
			    min = -180.0;
			    max = 180.0;
			    return true;
			}
			
			/* 
			 * Check for overlap near the dateline and adjust if necessary
			 */
			if((min <= other_range.min + 360.0 && other_range.min + 360.0 <= max) ||
			   (min <= other_range.max + 360.0 && other_range.max + 360.0 <= max)) 
			{
			    other_range.min += 360.0;
			    other_range.max += 360.0;
			}
			
			if((other_range.min <= min + 360.0 && min + 360.0 <= other_range.max) ||
			   (other_range.min <= max + 360.0 && max + 360.0 <= other_range.max)) 
			{
			    min += 360.0;
			    max += 360.0;
			}
			
			/*  
			 *Check for any overlap and merge if there is overlap.
			 */	    
			if((min <= other_range.min && other_range.min <= max) ||
			   (min <= other_range.max && other_range.max <= max) ||
			   (other_range.min <= min && min <= other_range.max) ||
			   (other_range.min <= max && max <= other_range.max)) 
			{
			    min = Math.min(min, other_range.min);
			    max = Math.max(max, other_range.max);
			  
			    if(max - min >= 360.0)
			    {
					min = -180.0;
					max = 180.0;
			    }
			    return true;
			}
			/*  Else the ranges do not overlap - do nothing.
			 */
			return false;
		
	    } /* END meldRange */	       
    
    }
}