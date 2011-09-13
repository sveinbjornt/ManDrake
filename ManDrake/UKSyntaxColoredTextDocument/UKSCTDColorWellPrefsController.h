//
//  UKSCTDColorWellPrefsController.h
//  CocoaTADS
//
//  Created by Uli Kusterer on Wed Feb 11 2004.
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
	This is a simple controller class for displaying and changing the colors
	used for syntax coloring.
	
	Simply hook up the outlets to the NSColorWells of your "Preferences" window
	and then connect their actions to the corresponding takeXXXColorFrom:
	methods of an instance of this object.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//  Class:
// -----------------------------------------------------------------------------

@interface UKSCTDColorWellPrefsController : NSObject
{
	IBOutlet NSColorWell*		commentsColor;		// Make these point at the NSColorWells.
	IBOutlet NSColorWell*		identifiersColor;
	IBOutlet NSColorWell*		preprocessorColor;
	IBOutlet NSColorWell*		stringsColor;
	IBOutlet NSColorWell*		tagsColor;
	IBOutlet NSColorWell*		identifiers2Color;
	IBOutlet NSColorWell*		comments2Color;
}

// Actions for NSColorWells:
-(IBAction)		takeCommentsColorFrom: (NSColorWell*)cw;
-(IBAction)		takeIdentifiersColorFrom: (NSColorWell*)cw;
-(IBAction)		takePreprocessorColorFrom: (NSColorWell*)cw;
-(IBAction)		takeStringsColorFrom: (NSColorWell*)cw;
-(IBAction)		takeTagsColorFrom: (NSColorWell*)cw;
-(IBAction)		takeIdentifiers2ColorFrom: (NSColorWell*)cw;
-(IBAction)		takeComments2ColorFrom: (NSColorWell*)cw;

-(IBAction)		resetColors: (id)sender;	// For "reset to defaults" button.

// Private:
-(void)			updateUIFromPrefs: (id)sender;

@end
