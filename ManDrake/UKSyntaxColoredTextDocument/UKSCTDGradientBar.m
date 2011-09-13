//
//  UKSCTDGradientBar.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on 07.03.10.
//  Copyright 2010 Uli Kusterer.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import "UKSCTDGradientBar.h"


@implementation UKSCTDGradientBar

-(void)	drawRect: (NSRect)dirtyRect
{
    NSGradient*		sGradient = nil;
	if( !sGradient )
		sGradient = [[NSGradient alloc] initWithColorsAndLocations:
			[NSColor whiteColor], 0.0,
			[NSColor whiteColor], 0.15,
			[NSColor colorWithCalibratedWhite: 0.9 alpha: 1.0], 0.5,
			[NSColor whiteColor], 0.85,
			[NSColor whiteColor], 1.0,
			nil];
	
	[sGradient drawInRect: [self bounds] angle: 90.0];
}

@end
