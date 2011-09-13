//
//  UKSCTDUserIdentifiersPrefsController.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Sat May 15 2004.
//  Copyright (c) 2004 Uli Kusterer.
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKSCTDUserIdentifiersPrefsController.h"
#import "UKSyntaxColoredTextViewController.h"


@implementation UKSCTDUserIdentifiersPrefsController

// -----------------------------------------------------------------------------
//	* CONSTRUCTOR:
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(id) init
{
	self = [super init];
	if( self )
	{
		identifiers = nil;  // Is instantiated lazily when we need it.
	}
	
	return self;
}


// -----------------------------------------------------------------------------
//	* DESTRUCTOR:
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(void) dealloc
{
    [identifiers release];
    identifiers = nil;

    [super dealloc];
}


// -----------------------------------------------------------------------------
//	awakeFromNib:
//		Make sure GUI looks right after it's been loaded.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(void) awakeFromNib
{
	[self tableViewSelectionDidChange:nil]; // Make sure "remove" button looks right.
}


// -----------------------------------------------------------------------------
//	createNewIdentifier:
//		Action for "Add Identifier" button. Creates a new untitled identifier
//		entry that the user can then edit.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) createNewIdentifier: (id)sender
{
	[[self identifiers] addObject: NSLocalizedString(@"untitled", nil)];
	NSUInteger		theRow = [[self identifiers] count] -1;

	[identifiersList noteNumberOfRowsChanged];
	
	[identifiersList selectRowIndexes: [NSIndexSet indexSetWithIndex: theRow] byExtendingSelection: NO];
	[identifiersList editColumn: 0 row: theRow withEvent: nil select: YES];
}


// -----------------------------------------------------------------------------
//	deleteIdentifier:
//		Action for "Remove Identifier" button. Removes the selected identifier
//		from the list and the user defaults.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) deleteIdentifier: (id)sender
{
	[identifiers removeObjectAtIndex: [identifiersList selectedRow]];
	[identifiersList noteNumberOfRowsChanged];

	[[NSUserDefaults standardUserDefaults] setObject: [self identifiers]
		forKey: TD_USER_DEFINED_IDENTIFIERS];
}


// -----------------------------------------------------------------------------
//	identifiers:
//		Return and, if needed, lazily instantiate our array of user-defined
//		identifiers.
//
//	REVISIONS:
//		2004-05-18	witness	Documented.
// -----------------------------------------------------------------------------

-(NSMutableArray*)  identifiers
{
	if( !identifiers )
	{
		identifiers = [[[NSUserDefaults standardUserDefaults] objectForKey: TD_USER_DEFINED_IDENTIFIERS] mutableCopy];
		if( !identifiers )
			identifiers = [[NSMutableArray alloc] init];
	}
	
	return identifiers;
}


// -----------------------------------------------------------------------------
//	Table view data source methods:
// -----------------------------------------------------------------------------

-(int)  numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self identifiers] count];
}


-(void) tableViewSelectionDidChange:(NSNotification *)notification
{
	[removeButton setEnabled: ([identifiersList selectedRow] != -1)];   // Make sure "remove" button is only enabled if we have a selection.
}


-(id)   tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	return [[self identifiers] objectAtIndex: row];
}


-(void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	[identifiers replaceObjectAtIndex: row withObject: object];
	
	[[NSUserDefaults standardUserDefaults] setObject: [self identifiers]
		forKey: TD_USER_DEFINED_IDENTIFIERS];
}



@end
