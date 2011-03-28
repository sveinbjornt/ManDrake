//
//  MyTextViewContainer.m
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

#import "MyTextViewContainer.h"


@implementation MyTextViewContainer

- (NSRect)lineFragmentRectForProposedRect:(NSRect)proposedRect 
        sweepDirection:(NSLineSweepDirection)sweepDirection 
        movementDirection:(NSLineMovementDirection)movementDirection 
        remainingRect:(NSRect *)remainingRect
{
	proposedRect.origin.x = left_margin_width;

    return [super lineFragmentRectForProposedRect:proposedRect sweepDirection:sweepDirection
                        movementDirection:movementDirection remainingRect:remainingRect];
}

@end
