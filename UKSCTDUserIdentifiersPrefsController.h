//
//  UKSCTDUserIdentifiersPrefsController.h
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

/*
	This is a simple controller class that handles changing the list of user-
	defined identifiers that UKSyntaxColoredTextDocument uses (except if the
	Syntax definition provides its own). You simply set up "add" and "remove"
	buttons and a table view, connect them to an instance of this object, and
	it will take care of the rest.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Class:
// -----------------------------------------------------------------------------

@interface UKSCTDUserIdentifiersPrefsController : NSObject
{
	IBOutlet NSTableView*		identifiersList;	// The list view for editing and viewing identifiers. This object is its data source and delegate.
	IBOutlet NSButton*			removeButton;		// The "remove" button so we can enable/disable it.
	NSMutableArray*				identifiers;		// Our internal, editable copy of the list of identifiers.
}

-(IBAction) createNewIdentifier: (id)sender;		// Action for "Add" button.
-(IBAction) deleteIdentifier: (id)sender;			// Action for "Remove" button.

-(void) tableViewSelectionDidChange:(NSNotification *)notification;

// Private:
-(NSMutableArray*)  identifiers;					// Accessor that lazily instantiates the "identifiers" array when first needed.

@end
