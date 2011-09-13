//
//  ManDrakeApplicationDelegate.m
//  ManDrake
//
//  Created by Sveinbjorn Thordarson on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ManDrakeApplicationDelegate.h"

@implementation ManDrakeApplicationDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void)initialize
{
    // create and register the user defaults here if none exists
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject: @"delayed" forKey: @"Refresh"];
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

@end
