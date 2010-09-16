/*
 * CLLocation.j
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

@import "MKReverseGeocoder.j"

CLLocationDidFindPlacemarkNotification = @"CLLocationDidFindPlacemarkNotification";

@implementation CLLocation : CPObject
{
    JSObject            coordinate  @accessors(readonly);
    CPDate              timestamp   @accessors(readonly);

    CLLocationAccuracy  accuracy    @accessors(readonly);

    MKPlacemark         placemark   @accessors;
    MKReverseGeocoder   _geocoder   @accessors(reaonly);
}

- (id)initWithLatitude:(float)latitude longitude:(float)longitude
{
    return [self initWithCoordinate:{latitude: latitude, longitude: longitude}
                    accuracy:(latitude && longitude ? 0 : -1)
                    timestamp:[CPDate date]];
}

- (id)initWithCoordinate:(JSObject)aCoordinate accuracy:(CLLocationAccuracy)anAccuracy timestamp:(CPDate)aDate
{
    self = [super init];

    if (self)
    {
        coordinate = aCoordinate;
        accuracy = anAccuracy;
        timestamp = aDate;
    }

    return self;
}

- (float)getDistanceFrom:(CLLocation)aLocation
{
    if (accuracy < 0 || !aLocation || [aLocation accuracy] < 0)
        return;
}

- (BOOL)isEqual:(CLLocation)rhs
{
    return coordinate.latitude === rhs.coordinate.latitude && coordinate.longitude === rhs.coordinate.longitude;
}

- (CPString)description
{
    return [CPString stringWithFormat:@"< %@, %@ > +/- %@ @ %@", coordinate.latitude, coordinate.longitude, accuracy, timestamp];
}

- (JSObject)latLng
{
    if (!coordinate)
        return nil;

    return new google.maps.LatLng(coordinate.latitude, coordinate.longitude);
}

- (void)geocode
{
    if (_geocoder)
        [_geocoder cancel];

    _geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self];
    [_geocoder setDelegate:self];
    [_geocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder)aCoder didFindPlacemark:(MKPlacemark)aPlacemark
{
    [self setPlacemark:aPlacemark];
    [[CPNotificationCenter defaultCenter] postNotificationName:CLLocationDidFindPlacemarkNotification object:self];
}

@end
