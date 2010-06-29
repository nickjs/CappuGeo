/*
 * CLLocationManager.j
 * CoreLocation
 *
 * Created by Nicholas Small.
 * Copyright 2010, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPObject.j>


CLDistanceFilterNone = 0;

CLLocationAccuracyBest = 0;
CLLocationAccuracySimple = 50;

CLLocationManagerDidUpdateNotification = @"CLLocationManagerDidUpdateNotification";
CLLocationManagerDidFailNotification = @"CLLocationManagerDidFailNotification";

CLLocationManagerOldLocation = @"CLLocationManagerOldLocation";
CLLocationManagerNewLocation = @"CLLocationManagerNewLocation";
CLLocationManagerDeltaDistance = @"CLLocationManagerDeltaDistance";
CLLocationManagerError = @"CLLocationManagerError";

CLErrorDenied = @"CLErrorDenied";
CLErrorLocationUnknown = @"CLErrorLocationUnknown";

var SharedManager;

geoip_region = nil;

@implementation CLLocationManager : CPObject
{
    id                  delegate        @accessors;
    BOOL                isStarted       @accessors(readonly);
    
    CLLocationDistance  distanceFilter  @accessors;
    CLLocationAccuracy  desiredAccuracy @accessors;
    
    CLLocation          location        @accessors(readonly);
    
    CPTimer             _locateNativeInterval;
    CPTimer             _locateIPInterval;
}

+ (CLLocationManager)sharedManager
{
    if (!SharedManager)
        SharedManager = [[[self class] alloc] init];
    
    return SharedManager;
}

- (BOOL)locationServicesEnabled
{
    return YES;
}

- (void)startUpdatingLocation
{
    if (![self locationServicesEnabled])
        return;
    
    if (isStarted)
        return;
    
    isStarted = YES;
    
    if (desiredAccuracy >= CLLocationAccuracySimple)
        [self _startLocatingIP];
    else
        [self _startLocatingNative];
}

- (void)stopUpdatingLocation
{
    [self _stopLocatingNative];
    [self _stopLocatingIP];
    
    isStarted = NO;
}

- (void)_updateLocation:(CLLocation)aLocation
{
    if ([location isEqual:aLocation])
        return;
    
    var oldLocation = location;
    location = aLocation;
    
    var distance;
    if (distanceFilter > 0)
        distance = [location getDistanceFrom:oldLocation];
    
    // var userInfo = [CPDictionary dictionaryWithObjectsAndKeys:oldLocation, CLLocationManagerOldLocation, location, CLLocationManagerNewLocation, distance, CLLocationManagerDeltaDistance];
    // [[CPNotificationCenter defaultCenter] postNotificationName:CLLocationManagerDidUpdateNotification object:self userInfo:userInfo];
    
    if (distanceFilter > 0 && distance < distanceFilter)
        return;
    
    if ([delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
        [delegate locationManager:self didUpdateToLocation:location fromLocation:oldLocation];
    
    var userInfo = [CPDictionary dictionaryWithObjectsAndKeys:oldLocation, CLLocationManagerOldLocation, location, CLLocationManagerNewLocation, distance, CLLocationManagerDeltaDistance];
    [[CPNotificationCenter defaultCenter] postNotificationName:CLLocationManagerDidUpdateNotification object:self userInfo:userInfo];
}

- (void)_failWithError:(CPError)anError
{
    if ([delegate respondsToSelector:@selector(locationManager:didFailWithError:)])
        [delegate locationManager:self didFailWithError:anError];
    
    var userInfo = [CPDictionary dictionaryWithObjectsAndKeys:location, CLLocationManagerNewLocation, anError, CLLocationManagerError];
    [[CPNotificationCenter defaultCenter] postNotificationName:CLLocationManagerDidFailNotification object:self userInfo:userInfo];
}

- (void)_startLocatingNative
{
    if (!navigator || !navigator.geolocation)
        return [self _startLocatingNativeDidFail];
    
    var onSuccess = function(position) {
        var latitude = position.coords.latitude,
            longitude = position.coords.longitude,
            accuracy = latitude && longitude ? position.coords.accuracy : -1;
        
        var newLocation = [[CLLocation alloc] initWithCoordinate:{latitude: latitude, longitude: longitude}
                                                    accuracy:accuracy
                                                    timestamp:position.timestamp];
        
        if (accuracy >= 0)
            [self _updateLocation:newLocation];
        else
        {
            [self _failWithError:CLErrorLocationUnknown];
            [self _startLocatingNativeDidFail];
        }
    };
    
    var onFailure = function(error) {
        if (!error)
            return;
        
        if (error.code === error.PERMISSION_DENIED)
            [self _failWithError:CLErrorDenied];
        else if (error.code === error.POSITION_UNAVAILABLE)
            [self _failWithError:CLErrorLocationUnknown];
        else
            [self _failWithError:error.message];
        
        [self _startLocatingNativeDidFail];
    }
    
    try
    {
        _locateNativeInterval = navigator.geolocation.watchPosition(onSuccess, onFailure);
    }
    catch (e)
    {
        [self _startLocatingNativeDidFail];
    }
}

- (void)_startLocatingNativeDidFail
{
    desiredAccuracy = CLLocationAccuracySimple;
    [self stopUpdatingLocation];
    [self startUpdatingLocation];
}

- (void)_stopLocatingNative
{
    if (_locateNativeInterval)
    {
        navigator.geolocation.clearWatch(_locateNativeInterval);
        _locateNativeInterval = nil;
    }
}

- (void)_startLocatingIP
{
    if (_locateIPInterval)
        return;
    
    _locateIPInterval = window.setInterval(function() {
        [self _locateIP];
    }, 120 * 1000);
    
    [self _locateIP];
}

- (void)_stopLocatingIP
{
    if (_locateIPInterval)
    {
        window.clearInterval(_locateIPInterval);
        _locateIPInterval = nil;
    }
}

- (void)_locateIP
{
    var script = document.createElement('script');
    script.src = 'http://j.maxmind.com/app/geoip.js';
    script.type = 'text/javascript';
    
    document.body.appendChild(script);
    
    var interval = window.setInterval(function() {
        if (!geoip_region)
            return;
        
        var latitude = geoip_latitude(),
            longitude = geoip_longitude(),
            accuracy = latitude && longitude ? CLLocationAccuracySimple : -1;
        
        var newLocation = [[CLLocation alloc] initWithCoordinate:{latitude: latitude, longitude: longitude}
                                                accuracy:accuracy
                                                timestamp:[CPDate date]];
        
        geoip_region = nil;
        
        document.body.removeChild(script);
        window.clearInterval(interval);
        
        if (accuracy >= 0)
            [self _updateLocation:newLocation];
        else
            [self _failWithError:CLErrorLocationUnknown];
    }, 100);
}

@end
