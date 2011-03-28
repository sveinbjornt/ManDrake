//
//  UKSyntaxColoredTextDocument.h
//  CocoaTADS
//
//  Created by Uli Kusterer on Tue May 27 2003.
//  Copyright (c) 2003 Uli Kusterer.
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


#import <Cocoa/Cocoa.h>
#import "UKTextDocGotoBox.h"
#import "UKSyntaxColoredTextViewController.h"


// UKSyntaxColoredTextDocument used to read text files as MacRoman-encoded text.
//	If you want that behaviour, put a
//		#define UKSCTD_DEFAULT_TEXTENCODING NSMacOSRomanStringEncoding
//	into your prefix header. Otherwise, this will do the right thing for modern
//	MacOS and read files as UTF-8. Or you can override -stringEncoding make
//	your own decision about what encoding to use.

#ifndef UKSCTD_DEFAULT_TEXTENCODING
#define UKSCTD_DEFAULT_TEXTENCODING		NSUTF8StringEncoding
#endif


// Syntax-colored text file viewer:
@interface UKSyntaxColoredTextDocument : NSDocument <UKSyntaxColoredTextViewDelegate>
{
	IBOutlet NSTextView*				textView;					// The text view used for editing code.
	IBOutlet NSProgressIndicator*		progress;					// Progress indicator while coloring syntax.
	IBOutlet NSTextField*				status;						// Status display for things like syntax coloring or background syntax checks.
	IBOutlet UKTextDocGoToBox*			gotoPanel;					// Controller for our "go to line" panel.
	IBOutlet NSImageView*				selectionKindImage;			// Image indicating whether it's an insertion mark or a selection range.
	NSString*							sourceCode;					// Temp. storage for data from file until NIB has been read.
	UKSyntaxColoredTextViewController*	syntaxColoringController;	// This guy actually does the work of coloring the field.
}

-(IBAction)	toggleAutoSyntaxColoring: (id)sender;
-(IBAction)	toggleMaintainIndentation: (id)sender;
-(IBAction) showGoToPanel: (id)sender;
-(IBAction) indentSelection: (id)sender;
-(IBAction) unindentSelection: (id)sender;
-(IBAction)	toggleCommentForSelection: (id)sender;
-(IBAction)	recolorCompleteFile: (id)sender;

-(NSStringEncoding)	stringEncoding;

@end



// Support for external editor interface:
//	(Doesn't really work yet ... *sigh*)

#pragma options align=mac68k

struct SelectionRange
{
	short   unused1;	// 0 (not used)
	short   lineNum;	// line to select (< 0 to specify range)
	long	startRange; // start of selection range (if line < 0)
	long	endRange;   // end of selection range (if line < 0)
	long	unused2;	// 0 (not used)
	long	theDate;	// modification date/time
};

#pragma options align=reset

