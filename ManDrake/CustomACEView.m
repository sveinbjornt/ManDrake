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

- (void)setAnnotations:(NSArray *)annotations {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:annotations
                                                        options:kNilOptions
                                                          error:nil];

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *js = [NSString stringWithFormat:@"editor.getSession().setAnnotations(%@);", jsonString];
    
    [self performSelector:@selector(executeScriptWhenLoaded:) withObject:js];
}

@end
