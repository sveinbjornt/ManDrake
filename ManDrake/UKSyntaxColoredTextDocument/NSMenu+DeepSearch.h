//
//  NSMenu+DeepSearch.h
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

/*
	This category adds a method to NSMenu that lets you perform a deep search
	in a menu for an item with a particular target and action. This is e.g.
	very handy when you're looking for an item and don't know what menu it is
	in. Simply pass [NSApp mainMenu] as the menu, and get back the menu item,
	which knows what menu it belongs to.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Interface:
// -----------------------------------------------------------------------------

@interface NSMenu (UKDeepSearch)

// Perform a deep search on a menu and its submenus: (returns NIL if the item couldn't be found)
-(NSMenuItem*)  findItemWithTarget: (id)targ andAction: (SEL)action;

@end
