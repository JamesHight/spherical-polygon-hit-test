Spherical Polygon Hit Test
==========================

````actionscript
var p1:SphericalPolygon = new SphericalPolygon([ new SPoint(lat1, lon1), new SPoint(lat2,lon2), etc... ] );
var p2:SphericalPolygon = new SphericalPolygon([ new SPoint(lat6, lon6), new SPoint(lat7,lon7), etc... ] );
 
if (p1.overlaps(p2)) {
    trace('They overlap!');
}
else {
    trace ('They do not overlap.');
}

````
