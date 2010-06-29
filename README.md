# MapKit and CoreLocation for Cappuccino
A port of Cocoa's MapKit and CoreLocation frameworks to [Cappuccino](http://cappuccino.org).
This is tested against Cappuccino master, but should potentially work on 0.8 and above.

## Status
There is still a lot to do. I haven't messed with this code in a bit and won't have time to for a little bit longer. I'm not entirely sure what state it's in, but it should be mostly usable.

## Installation
The framework will not include Google Maps for you. Simply add this to your index.html files:
	`<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script>`

Place the entire CappuGeo folder in your Frameworks folder, or anywhere else that is included in `OBJJ_INCLUDE_PATHS`.

Use:
@import <CappuGeo/CoreLocation.j>
and/or
@import <CappuGeo/MapKit.j>
when you want to access the classes.

Note:
@import <CappuGeo/CappuGeo.j>
will import both frameworks.

## CoreLocation
The singleton CLLocationManager will attempt to geolocate the user. If they are using a browser supporting the new geolocation API, it will be used, otherwise falling back to unreliable IP methods.
You can force one method or the other using -setDesiredAccuracy:. After you call -startUpdatingLocation, the CLLocationManager will begin firing CLLocationManagerDidUpdateNotification notifications.
Whenever this event happens, you can query the location manager for -location, which will return the CLLocation object.

	- (id)init
	{
		self = [super init];
		
		if (self)
		{
			[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:CLLocationManagerDidUpdateNotification object:nil];
			[[CLLocationManager sharedManager] startUpdatingLocation];
		}
		
		return self;
	}
	
	- (void)locationDidChange:(CPNotification)aNotification
	{
		var location = [[CLLocationManager sharedManager] location];
		
		// Let's get some geocoded results
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidGeocode:) name:CLLocationDidFindPlacemarkNotification object:location];
		[location geocode];
	}
	
	- (void)locationDidGeocode:(CPNotification)aNotification
	{
		var location = [aNotification object],
			placemark = [location placemark];
		
		alert([CPString stringWithFormat:@"How's the weather in %@?", [placemark canonical]]);
	}

## MapKit
MapKit is much more complex than CoreLocation. I would recommend seeing Apple's [documentation](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html).

Note: This version of MapKit has not been updated with the version of MapKit in the iOS SDK 4.0. The new classes that were added are not present. There are also a bit of additional things to make this work in Cappuccino.
