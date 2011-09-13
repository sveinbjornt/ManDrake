/*
 
 ManDrake - Native open-source Mac OS X man page editor 
 Copyright (C) 2011 Sveinbjorn Thordarson <sveinbjornt@gmail.com>
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 
 */


#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>
#import "UKSyntaxColoredTextDocument.h"
#import "NoodleLineNumberView.h"
#import "MarkerLineNumberView.h"

@interface ManDrakeDocument : UKSyntaxColoredTextDocument
{
	IBOutlet WebView		*webView;
	IBOutlet id				refreshTypePopupButton;
	IBOutlet id				refreshProgressIndicator;
	
	IBOutlet NSScrollView   *scrollView;
	NoodleLineNumberView	*lineNumberView;
	IBOutlet NSWindow		*syntaxCheckerWindow;
	IBOutlet id             syntaxCheckResultTextField;
    
	NSPoint currentScrollPosition;
	NSTimer *refreshTimer;
}
- (IBAction)refresh:(id)sender;
- (IBAction)refreshChanged:(id)sender;
- (IBAction)makeTextLarger:(id)sender;
- (IBAction)makeTextSmaller:(id)sender;
- (void)drawWebView;
@end
