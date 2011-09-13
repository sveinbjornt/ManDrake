//
//	UKSyntaxColoredTextDocument.m
//	CocoaTads
//
//	Created by Uli Kusterer on 31.05.2003.
//	Copyright 2003 Uli Kusterer.
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

#import "UKSyntaxColoredTextDocument.h"


@implementation UKSyntaxColoredTextDocument

-(void)	dealloc
{
	[syntaxColoringController setDelegate: nil];
	[syntaxColoringController release];
	syntaxColoringController = nil;
	[sourceCode release];
	sourceCode = nil;
	
	[super dealloc];
}


/* -----------------------------------------------------------------------------
	windowNibName:
		Name of NIB file to use.
   -------------------------------------------------------------------------- */

-(NSString*)	windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"UKSyntaxColoredTextDocument";
}


/* -----------------------------------------------------------------------------
	windowControllerDidLoadNib:
		NIB has been loaded, fill the text view with our text and apply
		initial syntax coloring.
   -------------------------------------------------------------------------- */

-(void)	windowControllerDidLoadNib: (NSWindowController*)aController
{
    [super windowControllerDidLoadNib: aController];
	
	NSAssert( syntaxColoringController == nil, @"windowControllerDidLoadNib possibly called twice." );
	
	syntaxColoringController = [[UKSyntaxColoredTextViewController alloc] init];
	[syntaxColoringController setDelegate: self];
	[syntaxColoringController setView: textView];
		
	// Load source code into text view, if necessary:
	if( sourceCode != nil )
	{
		[textView setString: sourceCode];
		[sourceCode release];
		sourceCode = nil;
	}
	
	// Set up our progress indicator:
	//[progress setStyle: NSProgressIndicatorSpinningStyle];	// NIB forgets that :-(
	[progress setDisplayedWhenStopped: NO];
	[progress setUsesThreadedAnimation: YES];
}


-(void)	textViewControllerWillStartSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender		// Show your progress indicator.
{
	[progress startAnimation: self];
	[progress display];
}


-(void)	textViewControllerDidFinishSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender		// Hide your progress indicator.
{
	[progress stopAnimation: self];
	[progress display];
}


-(void)	selectionInTextViewController: (UKSyntaxColoredTextViewController*)sender						// Update any selection status display.
			changedToStartCharacter: (NSUInteger)startCharInLine endCharacter: (NSUInteger)endCharInLine
			inLine: (NSUInteger)lineInDoc startCharacterInDocument: (NSUInteger)startCharInDoc
			endCharacterInDocument: (NSUInteger)endCharInDoc;
{
	NSString*	statusMsg = nil;
	NSImage*	selKindImg = nil;
	
	if( startCharInDoc < endCharInDoc )
	{
		statusMsg = NSLocalizedString(@"Character %lu to %lu of Line %lu (%lu to %lu in document).",@"selection description in syntax colored text documents.");
		statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, endCharInLine +1, lineInDoc +1, startCharInDoc +1, endCharInDoc +1];
		selKindImg = [NSImage imageNamed: @"SelectionRange"];
	}
	else
	{
		statusMsg = NSLocalizedString(@"Character %lu of Line %lu (%lu in document).",@"insertion mark description in syntax colored text documents.");
		statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, lineInDoc +1, startCharInDoc +1];
		selKindImg = [NSImage imageNamed: @"InsertionMark"];
	}
	
	[selectionKindImage setImage: selKindImg];
	[status setStringValue: statusMsg];
	[status display];
}

// -----------------------------------------------------------------------------
//	stringEncoding
//		The encoding as which we will read/write the file data from/to disk.
// -----------------------------------------------------------------------------

-(NSStringEncoding)	stringEncoding
{
	return NSMacOSRomanStringEncoding;
}


/* -----------------------------------------------------------------------------
	dataRepresentationOfType:
		Save raw text to a file as MacRoman text.
   -------------------------------------------------------------------------- */

-(NSData*)	dataRepresentationOfType: (NSString*)aType
{
    return [[textView string] dataUsingEncoding: [self stringEncoding] allowLossyConversion: YES];
}


/* -----------------------------------------------------------------------------
	loadDataRepresentation:ofType:
		Load plain MacRoman text from a text file.
   -------------------------------------------------------------------------- */

-(BOOL)	loadDataRepresentation: (NSData*)data ofType: (NSString*)aType
{
	// sourceCode is a member variable:
	if( sourceCode )
	{
		[sourceCode release];   // Release any old text.
		sourceCode = nil;
	}
	sourceCode = [[NSString alloc] initWithData:data encoding: [self stringEncoding]]; // Load the new text.
	
	/* Try to load it into textView and syntax colorize it: */
	[textView setString: sourceCode];

	// Try to get selection info if possible:
	NSAppleEventDescriptor*  evt = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
	if( evt )
	{
		NSAppleEventDescriptor*  param = [evt paramDescriptorForKeyword: keyAEPosition];
		if( param )		// This is always false when Xcode calls us???
		{
			NSData*					data = [param data];
			struct SelectionRange   range;
			
			memmove( &range, [data bytes], sizeof(range) );
			
			if( range.lineNum >= 0 )
				[syntaxColoringController goToLine: range.lineNum +1];
			else
				[syntaxColoringController goToRangeFrom: range.startRange toChar: range.endRange];
		}
	}
	
	return YES;
}


/* -----------------------------------------------------------------------------
	toggleAutoSyntaxColoring:
		Action for menu item that toggles automatic syntax coloring on and off.
   -------------------------------------------------------------------------- */

-(IBAction)	toggleAutoSyntaxColoring: (id)sender
{
	[syntaxColoringController toggleAutoSyntaxColoring: sender];
}


/* -----------------------------------------------------------------------------
	toggleMaintainIndentation:
		Action for menu item that toggles indentation maintaining on and off.
   -------------------------------------------------------------------------- */

-(IBAction)	toggleMaintainIndentation: (id)sender
{
	[syntaxColoringController toggleMaintainIndentation: sender];
}


/* -----------------------------------------------------------------------------
	showGoToPanel:
		Action for menu item that shows the "Go to line" panel.
   -------------------------------------------------------------------------- */

-(IBAction) showGoToPanel: (id)sender
{
	[gotoPanel showGoToSheet: [self windowForSheet]];
}


// -----------------------------------------------------------------------------
//	indentSelection:
//		Action method for "indent selection" menu item.
// -----------------------------------------------------------------------------

-(IBAction) indentSelection: (id)sender
{
	[syntaxColoringController indentSelection: sender];
}


// -----------------------------------------------------------------------------
//	unindentSelection:
//		Action method for "un-indent selection" menu item.
// -----------------------------------------------------------------------------

-(IBAction) unindentSelection: (id)sender
{
	[syntaxColoringController unindentSelection: sender];
}


/* -----------------------------------------------------------------------------
	toggleCommentForSelection:
		Add a comment to the start of this line/remove an existing comment.
   -------------------------------------------------------------------------- */

-(IBAction)	toggleCommentForSelection: (id)sender
{
	[syntaxColoringController toggleCommentForSelection: sender];
}


/* -----------------------------------------------------------------------------
	validateMenuItem:
		Make sure check marks of the "Toggle auto syntax coloring" and "Maintain
		indentation" menu items are set up properly.
   -------------------------------------------------------------------------- */

-(BOOL)	validateMenuItem:(NSMenuItem*)menuItem
{
	if( [menuItem action] == @selector(toggleAutoSyntaxColoring:) )
	{
		[menuItem setState: [syntaxColoringController autoSyntaxColoring]];
		return YES;
	}
	else if( [menuItem action] == @selector(toggleMaintainIndentation:) )
	{
		[menuItem setState: [syntaxColoringController maintainIndentation]];
		return YES;
	}
	else
		return [super validateMenuItem: menuItem];
}


/* -----------------------------------------------------------------------------
	recolorCompleteFile:
		IBAction to do a complete recolor of the whole friggin' document.
   -------------------------------------------------------------------------- */

-(IBAction)	recolorCompleteFile: (id)sender
{
	[syntaxColoringController recolorCompleteFile: sender];
}

@end
