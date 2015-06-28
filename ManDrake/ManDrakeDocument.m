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


#import "ManDrakeDocument.h"
#import "UKSyntaxColoredTextViewController.H"

@implementation ManDrakeDocument

- (instancetype)init
{
    if (self = [super init]) 
	{
		refreshTimer = NULL;
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"ManDrakeDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	// set up line numbering for text view
	scrollView = [textView enclosingScrollView];
	lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    
    [refreshTypePopupButton selectItemWithTitle: [[NSUserDefaults standardUserDefaults] objectForKey: @"Refresh"]];
	
	// Register for "text changed" notifications of the text storage:
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textDidChange:)
												 name: NSTextStorageDidProcessEditingNotification
											   object: [textView textStorage]];
		
    [super windowControllerDidLoadNib: aController];
}

-(void)dealloc
{
	[lineNumberView release];
	[super dealloc];
}

#pragma mark Web Preview

- (IBAction)refresh:(id)sender
{	
	// generate preview
	[refreshProgressIndicator startAnimation: self];
	[self drawWebView];
	[refreshProgressIndicator stopAnimation: self];
}

- (IBAction)refreshChanged:(id)sender
{
    NSLog(@"REFRESH CHANGED");
    [[NSUserDefaults standardUserDefaults] setObject: [refreshTypePopupButton titleOfSelectedItem] forKey: @"Refresh"];
}



- (void)textDidChange:(NSNotification *)aNotification
{
	NSString *refreshText = [refreshTypePopupButton titleOfSelectedItem];
	
	// use delayed timer
	if ([refreshText isEqualToString: @"delayed"])
	{
		if (refreshTimer != NULL)
		{
			[refreshTimer invalidate];
			refreshTimer = NULL;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePreview) userInfo:nil repeats:NO];
		
	}
	// or else do it for every change
	else if ([refreshText isEqualToString: @"live"])
	{
		[self refresh: self];
	}
}

- (void)drawWebView
{
	// write man text to tmp document
	[[textView string] writeToFile: @"/tmp/ManDrakeTemp.manText" atomically: YES encoding: NSUTF8StringEncoding error: NULL];

	// generate command string to create html from man text using nroff and cat2html
	NSString *cmdString = [NSString stringWithFormat: @"/usr/bin/nroff -mandoc /tmp/ManDrakeTemp.manText | %@ > /tmp/ManDrakeTemp.html", 
						   [[NSBundle mainBundle] pathForResource: @"cat2html" ofType: NULL]
						   ];
	
	// run the command
	system([cmdString cStringUsingEncoding: NSUTF8StringEncoding]);
	
	// get the current scroll position of the document view of the web view
	NSScrollView *theScrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	NSRect scrollViewBounds = [[theScrollView contentView] bounds];
	currentScrollPosition=scrollViewBounds.origin; 	

	// tell the web view to load the generated, local html file
	[[webView mainFrame] loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: @"/tmp/ManDrakeTemp.html"]]];
	
}

// delegate method we receive when it's done loading the html file. 
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	// restore the scroll position
	[[[[webView mainFrame] frameView] documentView] scrollPoint:currentScrollPosition];
}

- (void)updatePreview
{
	[self refresh: self];
	[refreshTimer invalidate];
	refreshTimer = NULL;
}

#pragma mark UKSyntaxColored stuff

-(NSString*) syntaxDefinitionFilename 
{
	return @"Man";
}

-(NSStringEncoding) stringEncoding 
{
    return NSUTF8StringEncoding;
}

#pragma mark UKSyntaxColoredTextViewDelegate methods

-(NSString *)syntaxDefinitionFilenameForTextViewController: (UKSyntaxColoredTextViewController *)sender 
{
	return @"Man";
}

-(NSDictionary*) syntaxDefinitionDictionaryForTextViewController: (UKSyntaxColoredTextViewController*)sender
{
    NSBundle* theBundle = [NSBundle mainBundle];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile: [theBundle pathForResource: @"Man" ofType:@"plist"]];
    if (!dict) 
	{
        NSLog(@"Failed to find the syntax dictionary");
    }
    return dict;
}




@end
