//
//  MyTextView.h
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyTextView : NSTextView
{
    BOOL                drawNumbersInMargin;
    BOOL                drawLineNumbers;
    NSMutableDictionary *marginAttributes;
}

-(void)initLineMargin:(NSRect)frame;

-(void)updateMargin;
-(void)updateLayout;

-(void)drawEmptyMargin:(NSRect)aRect;
-(void)drawNumbersInMargin:(NSRect)aRect;
-(void)drawOneNumberInMargin:(unsigned) aNumber inRect:(NSRect)aRect;

-(NSRect)marginRect;

@end
