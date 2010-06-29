/*
 * MKCalloutView.j
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


var BackgroundColor;

@implementation MKCalloutView : CPView
{
    CPView      view                @accessors;
    CPString    stringValue         @accessors;
    
    CPView      leftAccessoryView   @accessors;
    CPView      rightAccessoryView  @accessors;
    
    CPTextField _titleLabel;
}

+ (void)initialize
{
    if (BackgroundColor)
        return;
    
    var bundle = [CPBundle bundleForClass:MKCalloutView];
    
    BackgroundColor = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:[
        CPImageInBundle(@"Callout/0.png", CGSizeMake(18.0, 117.0), bundle),
        CPImageInBundle(@"Callout/1.png", CGSizeMake(1.0, 117.0), bundle),
        CPImageInBundle(@"Callout/2.png", CGSizeMake(18.0, 117.0), bundle),
        CPImageInBundle(@"Callout/3.png", CGSizeMake(18.0, 1.0), bundle),
        CPImageInBundle(@"Callout/4.png", CGSizeMake(1.0, 1.0), bundle),
        CPImageInBundle(@"Callout/5.png", CGSizeMake(18.0, 1.0), bundle),
        CPImageInBundle(@"Callout/6.png", CGSizeMake(18.0, 23.0), bundle),
        CPImageInBundle(@"Callout/7.png", CGSizeMake(1.0, 23.0), bundle),
        CPImageInBundle(@"Callout/8.png", CGSizeMake(18.0, 23.0), bundle)
    ]]];
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 0.0, 40.0)];
    
    if (self)
    {
        [self setBackgroundColor:BackgroundColor];
        [self setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin | CPViewMaxXMargin | CPViewMaxYMargin];
    }
    
    return self;
}

- (void)setView:(CPView)aView
{
    [view removeFromSuperview];
    
    view = aView;
    
    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

- (void)setStringValue:(CPString)aString
{
    if (!_titleLabel)
    {
        _titleLabel = [[CPTextField alloc] init];
        [_titleLabel setFont:[CPFont boldSystemFontOfSize:12]];
        [_titleLabel setTextShadowColor:[CPColor whiteColor]];
        [_titleLabel setTextShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    
    [_titleLabel setStringValue:aString];
    [_titleLabel sizeToFit];
    [self setView:_titleLabel];
}

- (void)setLeftAccessoryView:(CPView)aView
{
    [leftAccessoryView removeFromSuperview];
    
    leftAccessoryView = aView;
    
    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

- (void)setRightAccessoryView:(CPView)aView
{
    [rightAccessoryView removeFromSuperview];
    
    rightAccessoryView = aView;
    
    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

- (void)layoutSubviews
{
    var origin = CGPointMake(10.0, 12.0);
    
    if (leftAccessoryView)
    {
        [leftAccessoryView setFrameOrigin:CGPointMake(origin.x, 9.0)];
        [self addSubview:leftAccessoryView];
    }
    
    if (view)
    {
        [view setFrameOrigin:leftAccessoryView ? CGPointMake(CGRectGetMaxX([leftAccessoryView frame]) + 4.0, origin.y) : origin];
        [self addSubview:view];
    }
    
    if (rightAccessoryView)
    {
        [rightAccessoryView setFrameOrigin:view ? CGPointMake(CGRectGetMaxX([rightAccessoryView frame]) + 4.0, origin.y) : origin];
        [self addSubview:rightAccessoryView];
    }
    
    [self setFrameSize:CGSizeMake(CGRectGetMaxX([(rightAccessoryView || view) frame]) + 14.0, MAX(CGRectGetMaxY([leftAccessoryView frame] || CGRectMakeZero()), CGRectGetMaxY([rightAccessoryView frame] || CGRectMakeZero()), CGRectGetMaxY([view frame] || CGRectMakeZero())) + origin.y)];
}

@end
