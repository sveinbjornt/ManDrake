//
//  MyTextView.m
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

#import "MyTextView.h"
#import "MyTextViewContainer.h"


@implementation MyTextView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initLineMargin: [self frame]];
	}
	
    return self;
}

-(id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
		[self initLineMargin: frame];
    }
	
    return self;
}

- (void) initLineMargin:(NSRect) frame
{
	NSSize				contentSize;
	MyTextViewContainer	*myContainer;
	
	// create a subclass of NSTextContainer that specifies the textdraw area. 
	// This will allow for a left margin for numbering.
	
	contentSize = [[self enclosingScrollView] contentSize];
	frame = NSMakeRect(0, 0, contentSize.width, contentSize.height);
	myContainer = [[MyTextViewContainer allocWithZone:[self zone]] 
				   initWithContainerSize:NSMakeSize(frame.size.width, 100000)];
	
	[myContainer setWidthTracksTextView:YES];
	[myContainer setHeightTracksTextView:NO];
	
	// This controls the inset of our text away from the margin.
	[myContainer setLineFragmentPadding:15];
	
	[self replaceTextContainer:myContainer];
	[myContainer release];
	
	// set all the parameters for the text view - it's was created from scratch, so it doesn't use
	// the values from the Nib file.
	
	[self setMinSize:frame.size];
	[self setMaxSize:NSMakeSize(100000, 100000)];
	
	[self setHorizontallyResizable:YES];
	[self setVerticallyResizable:YES];
	
	[self setAutoresizingMask:NSViewWidthSizable];
	[self setAllowsUndo:YES];
	
	[self setFont:[NSFont fontWithName: @"Courier" size: 14]];
	
	// listen to updates from the window to force a redraw - eg when the window resizes.
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:)
												 name:NSWindowDidUpdateNotification object:[self window]];
	
	marginAttributes = [[NSMutableDictionary alloc] init];
	
	[marginAttributes setObject:[NSFont boldSystemFontOfSize:8] forKey: NSFontAttributeName];
	[marginAttributes setObject:[NSColor darkGrayColor] forKey: NSForegroundColorAttributeName];
	
	drawNumbersInMargin = YES;
	drawLineNumbers = YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [marginAttributes release];
	
    [super dealloc];
}

- (void)drawRect:(NSRect)aRect 
{
    [super drawRect:aRect];
    
    [self drawEmptyMargin: [self marginRect]];
    
    if ( drawNumbersInMargin )
    {
        [self drawNumbersInMargin: [self marginRect]];
    }
}


- (void)windowDidUpdate:(NSNotification *)notification
{
    [self updateMargin];
}

- (void)updateLayout
{
    [self updateMargin];
}


-(void)updateMargin
{
    [self setNeedsDisplayInRect:[self marginRect] avoidAdditionalLayout:NO];
}


-(NSRect)marginRect
{
    NSRect  r;
    
    r = [self bounds];
    r.size.width = left_margin_width;
	
    return r;
}

-(void)drawEmptyMargin:(NSRect)aRect
{
	/*
     These values control the color of our margin. Giving the rect the 'clear' 
     background color is accomplished using the windowBackgroundColor.  Change 
     the color here to anything you like to alter margin contents.
	 */
    [[NSColor controlHighlightColor] set];
    [NSBezierPath fillRect: aRect]; 
    
	// These points should be set to the left margin width.
    NSPoint top = NSMakePoint(aRect.size.width, [self bounds].size.height);
    NSPoint bottom = NSMakePoint(aRect.size.width, 0);
    
	// This draws the dark line separating the margin from the text area.
    [[NSColor grayColor] set];
    [NSBezierPath setDefaultLineWidth:0.75];
    [NSBezierPath strokeLineFromPoint:top toPoint:bottom];
}


-(void) drawNumbersInMargin:(NSRect)aRect;
{
	UInt32		index, lineNumber;
	NSRange		lineRange;
	NSRect		lineRect;
	
	NSLayoutManager* layoutManager = [self layoutManager];
	NSTextContainer* textContainer = [self textContainer];
	
	// Only get the visible part of the scroller view
	NSRect documentVisibleRect = [[self enclosingScrollView] documentVisibleRect];
	
	// Find the glyph range for the visible glyphs
	NSRange glyphRange = [layoutManager glyphRangeForBoundingRect: documentVisibleRect inTextContainer: textContainer];
	
	// Calculate the start and end indexes for the glyphs	
	unsigned start_index = glyphRange.location;
	unsigned end_index = glyphRange.location + glyphRange.length;
	
	index = 0;
	lineNumber = 1;
	
	// Skip all lines that are visible at the top of the text view (if any)
	while (index < start_index)
	{
		lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
		index = NSMaxRange( lineRange );
		++lineNumber;
	}
	
	for ( index = start_index; index < end_index; lineNumber++ )
	{
		lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
		index = NSMaxRange( lineRange );
		
		if ( drawLineNumbers )
        {
            [self drawOneNumberInMargin:lineNumber inRect:lineRect];
        }
        else    // draw character numbers
        {
            [self drawOneNumberInMargin:index inRect:lineRect];
        }
    }
    
    if ( drawLineNumbers )
    {
        lineRect = [layoutManager extraLineFragmentRect];
        [self drawOneNumberInMargin:lineNumber inRect:lineRect];
    }
}


-(void)drawOneNumberInMargin:(unsigned) aNumber inRect:(NSRect)r
{
    NSString    *s;
    NSSize      stringSize;
    
    s = [NSString stringWithFormat:@"%d", aNumber, nil];
    stringSize = [s sizeWithAttributes:marginAttributes];
	
	// Simple algorithm to center the line number next to the glyph.
    [s drawAtPoint: NSMakePoint( r.origin.x - stringSize.width - 1, 
								r.origin.y + ((r.size.height / 2) - (stringSize.height / 2))) 
	withAttributes:marginAttributes];
}


@end
