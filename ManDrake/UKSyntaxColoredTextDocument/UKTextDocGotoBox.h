//
//	UKTextDocGoToBox.h
//	UKSyntaxColoredTextDocument
//
//	Created by Uli Kusterer on 18.05.2004.
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

/*
	This class shows a little "Go to character/line" sheet window and handles
	it until the user is finished with it. This is intended to be instantiated
	from a NIB and hooked up to the outlets of a "go to line" window in the NIB
	there.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Text doc goto box delegate/target protocol:
// -----------------------------------------------------------------------------

// targetDocument must support this protocol:
@protocol UKTextDocGoToBoxTarget

-(void) goToLine: (int)num;
-(void) goToCharacter: (int)num;

@end


// -----------------------------------------------------------------------------
//  Class:
// -----------------------------------------------------------------------------

@interface UKTextDocGoToBox : NSObject
{
    IBOutlet NSPanel						*goToPanel;
    IBOutlet NSMatrix						*lineCharChooser;
    IBOutlet NSTextField					*lineNumField;
    IBOutlet NSButton						*okayButton;
    IBOutlet id	<UKTextDocGoToBoxTarget>	targetDocument;		// Object whom we send goToLine or goToCharacter messages.
}

// This is what you want to call:
-(IBAction) showGoToSheet: (NSWindow*)owner;

// Button actions: (Private)
-(IBAction) goToLineOrChar: (id)sender;
-(IBAction) hideGoToSheet: (id)sender;

@end


