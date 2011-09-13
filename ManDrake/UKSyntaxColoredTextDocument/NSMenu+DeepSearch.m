//
//  NSMenu+DeepSearch.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
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

#import "NSMenu+DeepSearch.h"


@implementation NSMenu (UKDeepSearch)

// -----------------------------------------------------------------------------
//	findItemWithTarget:andAction:
//		Calls indexOfItemWithTarget:andAction: on the menu, and if it doesn't
//		find an item, calls itself recursively on the submenus of all items
//		in the specified menu.
//
//  REVISIONS:
//		2004-05-18  witness Created.
// -----------------------------------------------------------------------------

-(NSMenuItem*)  findItemWithTarget: (id)targ andAction: (SEL)action
{
	// Look in this menu:
	int itemIndex = [self indexOfItemWithTarget: targ andAction: action];
	if( itemIndex >= 0 )
		return [self itemAtIndex: itemIndex];   // Return the item we found in this menu.
	
	// If not found, search our items' submenus:
	NSArray*		items = [self itemArray];
	NSEnumerator*   enny = [items objectEnumerator];
	NSMenuItem*		currItem = nil;
	
	while( (currItem = [enny nextObject]) )
	{
		if( [currItem hasSubmenu] )
		{
			currItem = [[currItem submenu] findItemWithTarget: targ andAction: action]; // Recurse deeper.
			if( currItem )
				return currItem;	// Found, exit & return item from submenu.
		}
	}
	
	// Nothing found? Report failure:
	return nil;
}

@end
