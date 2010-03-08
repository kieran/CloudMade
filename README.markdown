CloudMade
=========


A CloudMade static map generator.

You will need a CloudMade API to use this gem. Get one for free at http://www.developers.cloudmade.com/ 


Basics
------

Piecing together long URLs is a pain in the ass, and the CloudMade static maps API is a fickle beast.

Also, static map generation can sometimes be a tad slow, so it would be nice to cache the maps if you plan to use them more than once.


Enter CloudMade.gem
-------------------

Before we get started, we need to set up CloudMade with our API key. init.rb (or wherever) is a good place for this:

    CloudMade.api_key = 'YOUR_API_KEY_HERE'

You may also decide to add your custom map style id here as well:

    CloudMade.style_id = 3288

If you decide to enable map caching, you'll need to provide two more pieces of info: The path to your http_root and your cache_path, which is relative to your http_root

    CloudMade.http_root = './public'
    CloudMade.cache_path = 'images/maps'
  
With the example paths above, your maps will live in './public/images/maps/'


Enough config. Let's make maps!
-------------------------------

A simple map of somewhere in downtown Toronto:

    CloudMade.static_map :width=>720, :height=>360, :lat=>43.6760, :lng=>-79.3997, :zoom=>15

The same map, in JPG (smaller than PNG):

    CloudMade.static_map :width=>720, :height=>360, :lat=>43.6760, :lng=>-79.3997, :zoom=>15, :format=>'jpg'

### Bounding boxes

Instead of specifying a centre lat/lng & zoom level, you can also create a bounding box to contain all the things you want visible on your map:

    CloudMade.static_map :width=>720, :height=>360, :bbox=>[43.6459460258875, -79.4994735717625, 43.6797490120125, -79.3860244751375]

Bounding boxes are specified by two lat/lng co-ordinates, each representing an opposite corner of the box. This can be done either as an array [lat0,lng0,lat1,lng1] or as a comma-delimited string 'lat0,lng0,lat1,lng1'.

The resulting map will *contain* the entire bounding box, with extra padding to suit the width & height of the map.

An optional fifth parameter will let you specify padding for your box, and is expressed as a fraction of the width & height of the box. So:

    CloudMade.static_map :width=>720, :height=>360, :bbox=>[43.6459460258875, -79.4994735717625, 43.6797490120125, -79.3860244751375, 0.1]

will ensure an extra 10% width on both sides, as well as an extra 10% of the height of the box. 


Maps with things
----------------

Maps are nice. Maps with stuff on them are nicer. You can currently put two types of things on a static map: Paths and Markers.

### Markers

The simplest thing you can plop on your map is a *marker*. The simplest marker requires just a lat/lng co-ordinate:

    CloudMade.marker :lat=>43.6760, :lng=>-79.3997
    
If you want to get a little fancier (and why wouldn't you?) you can add a label, change the opacity, and specify the size ('big' or 'small').

    CloudMade.marker :lat=>43.6760, :lng=>-79.3997, :label=>'Q', :opacity=>0.7, :size=>'small'

Labels can only be one character on a static map :-( I call them lamels. Then I ditch them and use my own image:

    CloudMade.marker :lat=>43.6760, :lng=>-79.3997 , :url=>'http://awesome.com/images/marker.png', :opacity=>0.4

You can also pass :lat_offset and/or :lng_offset if you want to fiddle with the positioning.

### Paths

Adding a path is pretty straight-forward. In it's simplest form, you just need to pass an array of points like so:

    CloudMade.path :points=>[ [43.6459,-79.4994], [43.6797,-79.3860], ... ]
    
In this case, each lat/lng point is an array, with all the points collected in an outer array.

As with markers, you can adjust the opacity of your path with :opacity. Other options are :weight (line thickness in pixels) and :color (css color names OR a hex code). To use a hex code, you must provide a value in Ruby's Hexadecimal notation: 0x0088ff

    CloudMade.path :color=>0x0088ff, :weight=>5 :points=>[ [43.6459,-79.4994], [43.6797,-79.3860], ... ]


Caching for the future
----------------------

You can enable caching without slowing down your app. If a cached map isn't available, CloudMade will return the original cloudmade url and cache the map itself in the background. Every subsequent time that map is requested you'll get the relative URL of the cached file, which is saved as a hex string plus the file extension, like so: /images/maps/869ce32c.jpg

Deleting the cache is as simple as removing the files.
