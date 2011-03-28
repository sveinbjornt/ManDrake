//
//  MyDocument.m
//  ManDrake2
//
//  Created by Sveinbjorn Thordarson on 8/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ManDrakeDocument.h"
#import "UKSyntaxColoredTextViewController.H"

@implementation ManDrakeDocument

- (id)init
{
    self = [super init];
    if (self) 
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
    [scrollView setRulersVisible:YES];
	
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

#pragma mark Syntax checking

- (IBAction)checkSyntax:(id)sender
{
	NSTask			*cmd;
	NSPipe			*outputPipe = [NSPipe pipe];
	NSFileHandle	*readHandle;
		
	cmd = [[NSTask alloc] init];
	[cmd setLaunchPath: @"/usr/bin/nroff"];
	[cmd setArguments: [NSArray arrayWithObjects: @"-c", @"/tmp/ManDrakeTemp.manText", nil]];

	//direct the output of the task into a file handle for reading
	[cmd setStandardOutput: outputPipe];
	[cmd setStandardError: outputPipe];
	readHandle = [outputPipe fileHandleForReading];
	
	//launch task
	[cmd launch];
	[cmd waitUntilExit];
	
	//get output in string
	NSString *outputStr = [[[NSString alloc] initWithData: [readHandle readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
	
	if ([outputStr length] == 0) //if the syntax report string is empty, we report syntax as OK
		outputStr = [NSString stringWithString: @"Syntax OK"];
		
	[cmd release];//release the NSTask
	
	//report the result
	[NSApp beginSheet:	syntaxCheckerWindow
	   modalForWindow: [webView window] 
		modalDelegate:nil
	   didEndSelector: @selector(syntaxClosed)
		  contextInfo:nil];
	[NSApp runModalForWindow: syntaxCheckerWindow];
	
    [syntaxCheckerWindow orderOut: self];
}

- (void) syntaxClosed 
{
	[NSApp endSheet:syntaxCheckerWindow];
	[NSApp stopModal];
}

#pragma mark Web Preview

- (IBAction)refresh:(id)sender
{	
	// generate preview
	[refreshProgressIndicator startAnimation: self];
	[self drawWebView];
	[refreshProgressIndicator stopAnimation: self];
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
