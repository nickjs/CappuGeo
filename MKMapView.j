/*
 * MKMapView.j
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


MKMapTypeStandard = 0;
MKMapTypeSatellite = 1;
MKMapTypeHybrid = 2;
MKMapTypeTerrain = 3;

var MapTypeMappings = [
    google.maps.MapTypeId.ROADMAP,
    google.maps.MapTypeId.SATELLITE,
    google.maps.MapTypeId.HYBRID,
    google.maps.MapTypeId.TERRAIN
];

@implementation MKMapView : CPView
{
    id                  delegate            @accessors;
    
    int                 zoom;
    CLLocation          centerCoordinate;
    
    MKMapType           mapType             @accessors;
    BOOL                zoomEnabled         @accessors(getter=isZoomEnabled);
    BOOL                scrollEnabled       @accessors(getter=isScrollEnabled);
    BOOL                useDefaultControls  @accessors;
    
    BOOL                showsUserLocation   @accessors;
    BOOL                userLocationVisible @accessors(readonly,getter=isUserLocationVisible);
    MKUserLocation      userLocation        @accessors(readonly);
    
    CPArray             annotations         @accessors(readonly);
    CPArray             selectedAnnotations @accessors(readonly);
    CPArray             _annotationViews;
    
    JSObject            _map;
    JSObject            _projection;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self)
    {
        mapType = MKMapTypeStandard;
        zoom = 9;
        
        zoomEnabled = YES;
        scrollEnabled = YES;
        
        annotations = [];
        selectedAnnotations = [];
        _annotationViews = {};
    }
    
    return self;
}

- (int)zoom
{
    return zoom;
}

- (void)setZoom:(int)aZoom animated:(BOOL)animated
{
    if (zoom == aZoom)
        return;
    
    if ([delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)])
        [delegate mapView:self regionWillChangeAnimated:animated];
    
    zoom = aZoom;
    
    if (_map)
        _map.setZoom(zoom);
    
    if ([delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)])
        [delegate mapView:self regionDidChangeAnimated:animated];
}

- (CLLocation)centerCoordinate
{
    return centerCoordinate;
}

- (void)setCenterCoordinate:(CLLocation)aLocation animated:(BOOL)animated
{
    if ([delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)])
        [delegate mapView:self regionWillChangeAnimated:animated];
    
    centerCoordinate = aLocation;
    
    if (_map)
        _map.setCenter([aLocation latLng]);
    
    if ([delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)])
        [delegate mapView:self regionDidChangeAnimated:animated];
}

- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)aRegion
{
    
}

@end

@implementation MKMapView (Annotations)

- (void)addAnnotation:(MKAnnotation)anAnnotation
{
    if ([annotations containsObject:anAnnotation])
        return;
    
    annotations.push(anAnnotation);
    
    if (_map)
    {
        var view = [self viewForAnnotation:anAnnotation];
        [view setMapView:self];
        
        if ([delegate respondsToSelector:@selector(mapView:didAddAnnotationView:)])
            [delegate mapView:self didAddAnnotationView:view];
    }
}

- (void)addAnnotations:(CPArray)anArray
{
    var annotation;
    while (annotation = anArray.pop())
        [self addAnnotation:annotation];
}

- (void)removeAnnotation:(MKAnnotation)anAnnotation
{
    if (![annotations containsObject:anAnnotation])
        return;
    
    [annotations removeObject:anAnnotation];
    
    var view = [self viewForAnnotation:anAnnotation];
    [view setMapView:nil];
}

- (void)removeAnnotations:(CPArray)anArray
{
    var annotation;
    while (annotation = anArray.pop())
        [self removeAnnotation:annotation];
}

- (MKAnnotationView)viewForAnnotation:(MKAnnotation)anAnnotation
{
    var identifier;
    if ([anAnnotation respondsToSelector:@selector(identifier)])
        identifier = [anAnnotation identifier];
    else
        identifier = [anAnnotation UID];
    
    var view = _annotationViews[identifier];
    if (!view)
    {
        if ([delegate respondsToSelector:@selector(mapView:viewForAnnotation:)])
            view = [delegate mapView:self viewForAnnotation:anAnnotation];
        
        if (!view)
        {
            var viewClass = MKAnnotationView;
            if (anAnnotation === userLocation)
                viewClass = _MKUserLocationView;
            
            view = [[viewClass alloc] initWithAnnotation:anAnnotation];
        }
        
        _annotationViews[identifier] = view;
    }
    
    return view;
}

- (void)selectAnnotation:(MKAnnotation)anAnnotation animated:(BOOL)animated
{
    var view = [self viewForAnnotation:anAnnotation];
    [view setSelected:YES animated:animated];
    
    [self deselectAllAnnotationsAnimated:animated];
    
    if ([view isSelected])
        selectedAnnotations.push(anAnnotation);
}

- (void)deselectAnnotation:(MKAnnotation)anAnnotation animated:(BOOL)animated
{
    var view = [self viewForAnnotation:anAnnotation];
    [view setSelected:NO animated:animated];
    
    if (![view isSelected])
        [selectedAnnotations removeObject:anAnnotation];
}

- (void)deselectAllAnnotationsAnimated:(BOOL)animated
{
    for (var i = 0, count = selectedAnnotations.length; i < count; i++)
        [self deselectAnnotation:selectedAnnotations[i] animated:animated];
}

@end

@implementation MKMapView (Conversions)

- (CGPoint)convertCoordinate:(CLLocation)aLocation toPointToView:(CPView)aView
{
    var point = _projection.fromLatLngToContainerPixel(aLocation.isa ? [aLocation latLng] : aLocation);
    return [self convertPoint:CGPointMake(point.x, point.y) toView:aView];
}

- (CLLocation)convertPoint:(CGPoint)aPoint toCoordinateFromView:(CPView)aView
{
    
}

- (MKCoordinateRegion)convertRect:(CGRect)aRect toRegionFromView:(CPView)aView
{
    
}

- (CGRect)convertRegion:(MKCoordinateRegion)aRegion toRectToView:(CPView)aView
{
    
}

@end

@implementation MKMapView (UserLocation)

// You are responsible for tracking the location via -startUpdatingLocation or other methods!
- (void)setShowsUserLocation:(BOOL)aFlag
{
    if (showsUserLocation == aFlag)
        return;
    
    showsUserLocation = aFlag;
    
    if (showsUserLocation)
    {
        [self addAnnotation:[self userLocation]];
        [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationDidChange:) name:CLLocationManagerDidUpdateNotification object:nil];
    }
    else
    {
        [self removeAnnotation:[self userLocation]];
        [[CPNotificationCenter defaultCenter] removeObserver:self name:CLLocationManagerDidUpdateNotification object:nil];
    }
}

- (MKUserLocation)userLocation
{
    if (!userLocation)
        userLocation = [[MKUserLocation alloc] init];
    
    return userLocation;
}

- (void)userLocationDidChange:(CPNotification)aNotification
{
    var annotation = [self userLocation],
        view = [self viewForAnnotation:annotation];
    
    [view update];
}

@end

@implementation MKMapView (Events)

- (void)mouseDown:(CPEvent)anEvent
{
    [[[anEvent window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[[anEvent window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[[anEvent window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)_mouseDown:(CPEvent)anEvent
{
    [self deselectAllAnnotationsAnimated:YES];
}

@end

@implementation MKMapView (GoogleMaps)

- (void)layoutSubviews
{
    if (!_map && centerCoordinate && zoom)
    {
        var options = {
            backgroundColor: [[CPColor clearColor] cssString],
            center: [centerCoordinate latLng],
            mapTypeId: MapTypeMappings[mapType],
            keyboardShortcuts: NO,
            draggable: scrollEnabled,
            navigationControl: scrollEnabled,
            scrollwheel: zoomEnabled,
            scaleControl: zoomEnabled,
            disableDoubleClickZoom: !zoomEnabled,
            disableDefaultUI: !useDefaultControls,
            zoom: zoom
        }
        
        _map = new google.maps.Map(_DOMElement, options);
        
        var overlay = new NilOverlay(_map);
        
        setTimeout(function(){
            _projection = overlay.getProjection();
        }, 100);
        
        google.maps.event.addListener(_map, 'tilesloaded', function() {[self _finishLoadingTiles]});
        google.maps.event.addListener(_map, 'center_changed', function() {[self _centerChanged]});
        google.maps.event.addListener(_map, 'zoom_changed', function() {[self _zoomChanged]});
        google.maps.event.addListener(_map, 'maptypeid_changed', function() {[self _mapTypeChanged]});
        google.maps.event.addListener(_map, 'click', function(e) {[self _mouseDown:e]});
        
        var oldAnnotations = annotations;
        annotations = [];
        
        [self addAnnotations:oldAnnotations];
    }
}

- (void)resizeSubviewsWithOldSize:(CGSize)aSize
{
    [super resizeSubviewsWithOldSize:aSize];
    
    if (_map)
        google.maps.event.trigger(_map, 'resize');
}

- (void)_startLoadingTiles
{
    if ([delegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)])
        [delegate mapViewWillStartLoadingMap:self];
}

- (void)_finishLoadingTiles
{
    if ([delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)])
        [delegate mapViewDidFinishLoadingMap:self];
}

- (void)_centerChanged
{
    
}

- (void)_zoomChanged
{
    if (_map)
        var newZoom = _map.getZoom();
    
    if(newZoom == zoom)
        return;
    
    [self setZoom:newZoom animated:NO];
    
    if ([delegate respondsToSelector:@selector(mapViewDidChangeZoom:)])
        [delegate mapViewDidChangeZoom:self];
}

- (void)_mapTypeChanged
{
    if (_map)
        var newType = [MapTypeMappings indexOfObject:_map.getMapTypeId()];
    
    if (newType == mapType)
        return;
    
    [self setMapType:mapType];
    
    if ([delegate respondsToSelector:@selector(mapViewDidChangeMapType:)])
        [delegate mapViewDidChangeMapType:self];
}

@end

var NilOverlay = function(map) { this.setMap(map); };
NilOverlay.prototype = new google.maps.OverlayView();
NilOverlay.prototype.onAdd = function() {};
NilOverlay.prototype.onRemove = function() {};
NilOverlay.prototype.draw = function() {};
