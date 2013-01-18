//
//  PlaySliderCell.m
//  VK Player
//
//  Created by mihael on 08.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import "PlaySliderCell.h"

@implementation PlaySliderCell

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    if ([self numberOfTickMarks] > 0) tracking = YES;
    return [super startTrackingAt:startPoint inView:controlView];
}

#define MD_SNAPPING 10.0

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
    if (tracking) {
        NSUInteger count = [self numberOfTickMarks];
        for (NSUInteger i = 0; i < count; i++) {
            NSRect tickMarkRect = [self rectOfTickMarkAtIndex:i];
            if (ABS(tickMarkRect.origin.x - currentPoint.x) <= MD_SNAPPING) {
                [self setAllowsTickMarkValuesOnly:YES];
            } else if (ABS(tickMarkRect.origin.x - currentPoint.x) >= MD_SNAPPING &&
                       ABS(tickMarkRect.origin.x - currentPoint.x) <= MD_SNAPPING *2) {
                [self setAllowsTickMarkValuesOnly:NO];
            }
        }
    }
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint
              inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}

@end
