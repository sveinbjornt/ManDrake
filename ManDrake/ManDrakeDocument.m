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
#import <stdlib.h>

#import "ManDrakeDocument.h"
#import "UKSyntaxColoredTextViewController.H"
#import "NoodleLineNumberView.h"
#import "MarkerLineNumberView.h"

#define kManTextTempPath @"/tmp/ManDrakeTemp.manText"
#define kManHTMLTempPath @"/tmp/ManDrakeTemp.html"

#define kDefaultsUserFontSize @"ManDrakeUserFontSize"

@interface ManDrakeDocument()
{
    IBOutlet WebView *webView;
    IBOutlet NSPopUpButton *refreshTypePopupButton;
    IBOutlet NSProgressIndicator *refreshProgressIndicator;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSWindow *syntaxCheckerWindow;
    IBOutlet NSTextField *syntaxCheckResultTextField;

    NoodleLineNumberView *lineNumberView;
    NSPoint currentScrollPosition;
    NSTimer *refreshTimer;
}

- (IBAction)refresh:(id)sender;
- (IBAction)refreshChanged:(id)sender;
- (IBAction)makeTextLarger:(id)sender;
- (IBAction)makeTextSmaller:(id)sender;

@end

@implementation ManDrakeDocument

- (NSString *)windowNibName
{
    return @"ManDrakeDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
	// set up line numbering for text view
	scrollView = [textView enclosingScrollView];
	lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    
    [refreshTypePopupButton selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"Refresh"]];
	
	// Register for "text changed" notifications of the text storage:
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
												 name:NSTextStorageDidProcessEditingNotification
											   object:[textView textStorage]];
    
    NSFont *font = [textView font];
    CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsUserFontSize] floatValue];
    font = [[NSFontManager sharedFontManager] convertFont:font toSize:fontSize];
    [textView setFont:font];
    
    lineNumberView.font = font;;
}

#pragma mark - Text size

- (void)changeFontSize:(CGFloat)delta {
    
    // web view
    if (delta > 0)
    {
        [webView makeTextLarger:self];
    }
    else
    {
        [webView makeTextSmaller:self];
    }

    // text field
    NSFont *font = [textView font];
    CGFloat newFontSize = [font pointSize] + delta;
    font = [[NSFontManager sharedFontManager] convertFont:font toSize:newFontSize];
    [textView setFont:font];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:newFontSize]
                                              forKey:kDefaultsUserFontSize];
    [textView didChangeText];
}

- (IBAction)makeTextLarger:(id)sender {
    [self changeFontSize:1];
}

- (IBAction)makeTextSmaller:(id)sender {
    [self changeFontSize:-1];
}

#pragma mark - Web Preview

- (IBAction)refresh:(id)sender
{	
	// generate preview
	[refreshProgressIndicator startAnimation:self];
	[self refreshWebView];
	[refreshProgressIndicator stopAnimation:self];
}

- (IBAction)refreshChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[refreshTypePopupButton titleOfSelectedItem]
                                              forKey:@"Refresh"];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	NSString *refreshText = [refreshTypePopupButton titleOfSelectedItem];
	
	// use delayed timer
	if ([refreshText isEqualToString:@"Delayed"])
	{
		if (refreshTimer != nil)
		{
			[refreshTimer invalidate];
			refreshTimer = nil;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(updatePreview)
                                                      userInfo:nil
                                                       repeats:NO];
		
	}
	// or else do it for every change
	else if ([refreshText isEqualToString:@"Live"])
	{
		[self refresh:self];
	}
}

- (void)refreshWebView
{
	// write man text to tmp document
    NSError *err;
	BOOL success = [[textView string] writeToFile:kManTextTempPath
                                       atomically:YES
                                         encoding:NSUTF8StringEncoding
                                            error:&err];
    if (!success)
    {
        NSLog(@"Failed to write to path \"%@\": %@", kManTextTempPath, [err localizedDescription]);
        return;
    }

	// generate command string to create html from man text using nroff and cat2html
	NSString *cmdString = [NSString stringWithFormat:@"/usr/bin/nroff -mandoc \"%@\" | \"%@\" > \"%@\"",
                           kManTextTempPath,
                           [[NSBundle mainBundle] pathForResource:@"cat2html" ofType:nil],
                           kManHTMLTempPath];
	
	// run the command
	system([cmdString cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// get the current scroll position of the document view of the web view
	NSScrollView *theScrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	NSRect scrollViewBounds = [[theScrollView contentView] bounds];
	currentScrollPosition = scrollViewBounds.origin;

	// tell the web view to load the generated, local html file
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:@"/tmp/ManDrakeTemp.html"]]];
}

// delegate method we receive when it's done loading the html file. 
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	// restore the scroll position
	[[[[webView mainFrame] frameView] documentView] scrollPoint:currentScrollPosition];
}

- (void)updatePreview
{
	[self refresh:self];
	[refreshTimer invalidate];
	refreshTimer = nil;
}

#pragma mark UKSyntaxColored stuff

- (NSString *)syntaxDefinitionFilename
{
	return @"Man";
}

- (NSStringEncoding)stringEncoding
{
    return NSUTF8StringEncoding;
}

#pragma mark UKSyntaxColoredTextViewDelegate methods

- (NSString *)syntaxDefinitionFilenameForTextViewController:(UKSyntaxColoredTextViewController *)sender
{
	return @"Man";
}

- (NSDictionary *)syntaxDefinitionDictionaryForTextViewController:(UKSyntaxColoredTextViewController*)sender
{
    NSBundle *theBundle = [NSBundle mainBundle];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[theBundle pathForResource:@"Man" ofType:@"plist"]];
    if (!dict)
	{
        NSLog(@"Failed to find syntax dictionary");
    }
    return dict;
}

@end
