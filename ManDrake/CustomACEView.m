//
//  CustomACEView.m
//  ManDrake
//
//  Created by Sveinbjorn Thordarson on 21/01/16.
//
//

#import "CustomACEView.h"

@implementation CustomACEView

- (void)setModeByNameString:(NSString *)nameString {
    [self performSelector:@selector(executeScriptWhenLoaded:) withObject:[NSString stringWithFormat:@"editor.getSession().setMode(\"ace/mode/%@\");", nameString]];
}

@end
