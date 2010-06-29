/*
 * MKAnnotationView.j
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

@import <AppKit/CPView.j>


@implementation MKAnnotationView : CPView
{
    MKAnnotation    annotation                  @accessors(readonly);
    CPImage         image                       @accessors;
    
    CGPoint         centerOffset                @accessors;
    CGPoint         calloutOffset               @accessors;
    
    BOOL            enabled                     @accessors(getter=isEnabled);
    BOOL            draggable                   @accessors(getter=isDraggable);
    BOOL            highlighted                 @accessors(getter=isHighlighted);
    BOOL            selected                    @accessors(readonly,getter=isSelected);
    
    BOOL            canShowCallout              @accessors;
    CPView          leftCalloutAccessoryView    @accessors;
    CPView          rightCalloutAccessoryView   @accessors;
    CPView          _calloutView;
    
    MKMapView       mapView                     @accessors;
    JSObject        _marker;
    CPArray         _listeners;
}

- (id)initWithAnnotation:(MKAnnotation)anAnnotation
{
    self = [super init];
    
    if (self)
    {
        annotation = anAnnotation;
        
        centerOffset = CGPointMake(0.0, 0.0);
        calloutOffset = CGPointMake(0.0, 0.0);
        
        enabled = YES;
        draggable = NO;
        canShowCallout = YES;
        
        _listeners = [];
    }
    
    return self;
}

- (void)setImage:(CPImage)anImage
{
    if (image === anImage)
        return;
    
    image = anImage;
    
    if (_marker)
        _marker.setIcon([image filename]);
}

- (void)setSelected:(BOOL)aFlag animated:(BOOL)animated
{
    selected = enabled ? aFlag : NO;
    
    if ([annotation respondsToSelector:@selector(setSelected:)])
        [annotation setSelected:selected];
    
    if (selected)
    {
        if (!_calloutView)
            _calloutView = [[MKCalloutView alloc] init];
        
        if ([annotation respondsToSelector:@selector(viewForCallout)])
            [_calloutView setView:[annotation viewForCallout]];
        else
            [_calloutView setStringValue:[annotation title]];
        
        var windowView = [[mapView window] contentView],
            location = [mapView convertCoordinate:[annotation coordinate] toPointToView:windowView];
        
        [_calloutView setLeftAccessoryView:leftCalloutAccessoryView];
        [_calloutView setRightAccessoryView:rightCalloutAccessoryView];
        [_calloutView setCenter:CGPointMake(location.x + calloutOffset.x, location.y + calloutOffset.y)];
        [windowView addSubview:_calloutView];
    }
    else
        [_calloutView removeFromSuperview];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [mapView selectAnnotation:annotation animated:YES];
}

- (void)setMapView:(MKMapView)aView
{
    mapView = aView;
    
    if (mapView && mapView._map && !_marker && [annotation coordinate])
    {
        var options = {
            clickable: YES,
            draggable: [self isDraggable],
            icon: [[self image] filename],
            map: mapView._map,
            position: [[annotation coordinate] latLng],
            title: [annotation title]
        };
        
        _marker = new google.maps.Marker(options);
        
        _listeners.push(google.maps.event.addListener(_marker, 'mouseover', function(e) {[self mouseEntered:e]}));
        _listeners.push(google.maps.event.addListener(_marker, 'mouseout', function(e) {[self mouseExited:e]}));
        _listeners.push(google.maps.event.addListener(_marker, 'click', function(e) {e.stopPropagation(); [self mouseDown:e]}));
    }
    
    if (!mapView && _marker)
    {
        _marker.setMap(nil);
        
        for (var i = 0, count = _listeners.length; i < count; i++)
            google.maps.event.removeListener(_listeners[i]);
    }
}

- (JSObject)_icon
{
    var size = new google.maps.Size([self frame].size.width, [self frame].size.height),
        origin = new google.maps.Point(0, 0);
    
    return new google.maps.MarkerImage(@"Resources/PinBlue.png");//, size, origin);
}

@end

MKPinAnnotationColorRed = 0;
MKPinAnnotationColorGreen = 1;
MKPinAnnotationColorBlue = 2;
MKPinAnnotationColorBlack = 3;

var PinImages = [];

@implementation MKPinAnnotationView : MKAnnotationView
{
    int         pinColor        @accessors;
    BOOL        animatesDrop    @accessors;
}

+ (void)initialize
{
    if ([self class] !== MKPinAnnotationView)
        return;
    
    var bundle = [CPBundle bundleForClass:MKAnnotationView];
    
    PinImages[MKPinAnnotationColorRed] = CPImageInBundle(@"PinRed.png", CGSizeMake(11.0, 19.0), bundle);
    PinImages[MKPinAnnotationColorGreen] = CPImageInBundle(@"PinGreen.png", CGSizeMake(11.0, 19.0), bundle);
    PinImages[MKPinAnnotationColorBlue] = CPImageInBundle(@"PinBlue.png", CGSizeMake(11.0, 19.0), bundle);
    PinImages[MKPinAnnotationColorBlack] = CPImageInBundle(@"PinBlack.png", CGSizeMake(11.0, 19.0), bundle);
}

- (CPImage)image
{
    return PinImages[pinColor];
}

@end
