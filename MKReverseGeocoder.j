/*
 * MKReverseGeocoder.j
 * MapKit
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

@implementation MKReverseGeocoder : CPObject
{
    id              delegate    @accessors;
    CLLocation      coordinate  @accessors(readonly);
    MKPlacemark     placemark   @accessors(readonly);

    BOOL            querying    @accessors(readonly);

    JSObject        _geocoder;
}

- (id)initWithCoordinate:(CLLocation)aLocation
{
    self = [super init];

    if (self)
        coordinate = aLocation;

    return self;
}

- (void)start
{
    if (querying)
        return;

    querying = YES;

    _geocoder = new google.maps.Geocoder();
    _geocoder.geocode({latLng: [coordinate latLng]}, function(results, status) {
        if (!querying)
            return;

        if (status !== google.maps.GeocoderStatus.OK)
        {
            if ([delegate respondsToSelector:@selector(reverseGeocoder:didFailWithError:)])
                [delegate reverseGeocoder:self didFailWithError:status];
        }
        else
        {
            [self _didFinishLoading:results];
        }
    });
}

- (void)_didFinishLoading:(JSObject)results
{
    var object = {};

    object['description'] = results[0].formatted_address;

    results = results[0]['address_components'];
    for (var i = 0, count = results.length; i < count; i++)
    {
        var result = results[i],
            resultType = result.types[0],
            shortName = result.short_name;

        if (resultType === @"street_number")
            object[AddressSubThoroughfareKey] = shortName;
        else if (resultType === @"route")
            object[AddressThoroughfareKey] = shortName;
        else if (resultType === @"locality")
            object[AddressLocalityKey] = shortName;
        else if (resultType === @"administrative_area_level_1")
            object[AddressAdministrativeAreaKey] = shortName;
        else if (resultType === @"administrative_area_level_2")
            object[AddressSubAdministrativeAreaKey] = shortName;
        else if (resultType === @"sublocality")
            object[AddressSubLocalityKey] = shortName;
        else if (resultType === @"country")
        {
            object[AddressCountryKey] = result.long_name;
            object[AddressCountryCodeKey] = [shortName lowercaseString];
        }
        else if (resultType === @"postal_code")
            object[AddressPostalCodeKey] = shortName;
    }

    var placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:[CPDictionary dictionaryWithJSObject:object]];
    [delegate reverseGeocoder:self didFindPlacemark:placemark];

    [self cancel];
}

- (void)cancel
{
    querying = NO;
    _geocoder = nil;
}

@end
