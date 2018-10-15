//
//  CustomACEView.h
//  ManDrake
//
//  Created by Sveinbjorn Thordarson on 21/01/16.
//
//

#import <ACEView/ACEView.h>

@interface ACEView ()
- (void)executeScriptWhenLoaded:(NSString *)script; // Silence warnings
@end

@interface CustomACEView : ACEView

- (void)setModeByNameString:(NSString *)nameString;
- (void)setAnnotations:(NSArray *)annotations;
- (NSString *)fontSize;

@end
