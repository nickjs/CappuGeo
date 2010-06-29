/*
 * MKPlacemark.j
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


AddressThoroughfareKey          = @"AddressThoroughfareKey";
AddressSubThoroughfareKey       = @"AddressSubThoroughfareKey";
AddressLocalityKey              = @"AddressLocalityKey";
AddressSubLocalityKey           = @"AddressSubLocalityKey";
AddressAdministrativeAreaKey    = @"AddressAdministrativeAreaKey";
AddressSubAdministrativeAreaKey = @"AddressSubAdministrativeAreaKey";
AddressPostalCodeKey            = @"AddressPostalCodeKey";
AddressCountryKey               = @"AddressCountryKey";
AddressCountryCodeKey           = @"AddressCountryCodeKey";

@implementation MKPlacemark : CPObject
{
    CPDictionary    addressDictionary       @accessors(readonly);
    CLLocation      coordinate              @accessors(readonly);
    CPString        description             @accessors(readonly);
    
    CPString        thoroughfare            @accessors(readonly);
    CPString        subThoroughfare         @accessors(readonly);
    CPString        locality                @accessors(readonly);
    CPString        subLocality             @accessors(readonly);
    CPString        administrativeArea      @accessors(readonly);
    CPString        subAdministrativeArea   @accessors(readonly);
    CPString        postalCode              @accessors(readonly);
    CPString        country                 @accessors(readonly);
    CPString        countryCode             @accessors(readonly);
}

- (id)initWithCoordinate:(CLLocation)aLocation addressDictionary:(CPDictionary)aDictionary
{
    self = [super init];
    
    if (self)
    {
        coordinate = aLocation;
        addressDictionary = aDictionary;
        description = [addressDictionary objectForKey:@"description"];
        
        thoroughfare = [addressDictionary objectForKey:AddressThoroughfareKey];
        subThoroughfare = [addressDictionary objectForKey:AddressSubThoroughfareKey];
        locality = [addressDictionary objectForKey:AddressLocalityKey];
        subLocality = [addressDictionary objectForKey:AddressSubLocalityKey];
        administrativeArea = [addressDictionary objectForKey:AddressAdministrativeAreaKey];
        subAdministrativeArea = [addressDictionary objectForKey:AddressSubAdministrativeAreaKey];
        postalCode = [addressDictionary objectForKey:AddressPostalCodeKey];
        country = [addressDictionary objectForKey:AddressCountryKey];
        countryCode = [addressDictionary objectForKey:AddressCountryCodeKey];
    }
    
    return self;
}

- (CPString)canonical
{
    return [locality, administrativeArea].join(@", ");
}

@end
