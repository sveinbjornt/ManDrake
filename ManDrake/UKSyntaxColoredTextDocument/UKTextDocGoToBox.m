//
//	UKTextDocGoToBox.m
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

#import "UKTextDocGoToBox.h"

@implementation UKTextDocGoToBox

// -----------------------------------------------------------------------------
//	showGoToSheet:
//		Show the "go to line/character" sheet on the specified window. This will
//		return immediately and you should just ignore its existence until the
//		user closes it, at which point targetDocument will get a goToLine: or
//		goToChar message.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) showGoToSheet: (NSWindow*)owner
{
	[[NSApplication sharedApplication] beginSheet:goToPanel modalForWindow:owner modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}


// -----------------------------------------------------------------------------
//	hideGoToSheet:
//		Called by the "Cancel" and "OK" buttons to close the sheet once they're
//		done.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) hideGoToSheet: (id)sender
{
	[[NSApplication sharedApplication] endSheet: goToPanel];
}


// -----------------------------------------------------------------------------
//	sheetDidEnd:
//		Called when endSheet has been called on our sheet to actually unmap
//		the window.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(void) sheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	[sheet orderOut: nil];
}


// -----------------------------------------------------------------------------
//	goToLineOrChar:
//		Button action for the "OK" button. This sends the target document the
//		proper goToLine: or goToChar: message and then calls hideGoToSheet: to
//		close the sheet.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) goToLineOrChar:(id)sender
{
	int		num;
	
	num = [lineNumField intValue];
	
	if( [lineCharChooser selectedRow] == 0 )
		[targetDocument goToLine: num];
	else
		[targetDocument goToCharacter: num];
	
	[self hideGoToSheet: sender];
}

@end
