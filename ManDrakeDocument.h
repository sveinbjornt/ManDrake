//
//  MyDocument.h
//  ManDrake2
//
//  Created by Sveinbjorn Thordarson on 8/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
	
	NSPoint currentScrollPosition;
	NSTimer *refreshTimer;
}
- (IBAction)refresh:(id)sender;
- (IBAction)checkSyntax:(id)sender;
- (void)syntaxClosed;
- (void)drawWebView;
@end
