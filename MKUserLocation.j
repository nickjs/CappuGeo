/*
 * MKUserLocation.j
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


@implementation MKUserLocation : CPObject
{
    CLLocation  location    @accessors(readonly);
    CLLocation  coordinate  @accessors(readonly);
    
    CPString    title       @accessors;
    CPString    subtitle    @accessors;
}

- (CLLocation)location
{
    return [[CLLocationManager sharedManager] location];
}

- (CLLocation)coordinate
{
    return [self location];
}

- (CPString)title
{
    return title || @"Current Location";
}

- (CPString)subtitle
{
    return subtitle || [[[self location] placemark] description];
}

@end

@implementation _MKUserLocationView : MKAnnotationView
{
    
}

- (id)initWithAnnotation:(MKAnnotation)anAnnotation
{
    self = [super initWithAnnotation:anAnnotation];
    
    if (self)
    {
        image = CPImageInBundle(@"Blip.png", CGSizeMake(16.0, 16.0), [CPBundle bundleForClass:MKCalloutView]);
        
        enabled = YES;
        draggable = NO;
    }
    
    return self;
}

- (void)update
{
    if (_marker)
        _marker.setPosition([[[self annotation] coordinate] latLng]);
}

@end
