/*
    ManDrake - Native open-source Mac OS X man page editor
    Copyright (c) 2004-2016, Sveinbjorn Thordarson <sveinbjornt@gmail.com>

    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may
    be used to endorse or promote products derived from this software without specific
    prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

#import "ManDrakeApplicationDelegate.h"
#import "Common.h"
#import "NSWorkspace+Additions.h"
#import "ACEView/ACEThemeNames.h"

@implementation ManDrakeApplicationDelegate

+ (void)initialize {
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
    defaultPrefs[kDefaultsEditorTheme] = @(ACEThemeXcode);
    defaultPrefs[kDefaultsEditorFontSize] = @(11);
    defaultPrefs[kDefaultsEditorSyntaxHighlighting] = @(YES);
    defaultPrefs[kDefaultsEditorShowInvisibles] = @(YES);
    
    defaultPrefs[kDefaultsCheckSyntaxAutomatically] = @(YES);
    
    defaultPrefs[kDefaultsPreviewRefreshStyle] = @"Delayed";
    defaultPrefs[kDefaultsPreviewFontSize] = @(-1);
    defaultPrefs[kDefaultsPreviewInvert] = @(NO);
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
}

- (void)dealloc {
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:VALUES_KEYPATH(kDefaultsEditorTheme)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:VALUES_KEYPATH(kDefaultsPreviewRefreshStyle)];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorTheme)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsPreviewRefreshStyle)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    // populate themes menu
    int i = 0;
    NSArray *names = [ACEThemeNames humanThemeNames];
    for (NSString *themeName in names) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:themeName
                                                      action:@selector(submenuItemSelected:)
                                               keyEquivalent:@""];
        [item setTarget:self];
        [item setTag:i];
        [[self editorThemesSubmenu] addItem:item];
        i++;
    }
    [self updatePreviewRefreshStylesMenu];
    [self updateEditorThemesMenu];
}

#pragma mark - Defaults Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath hasSuffix:kDefaultsPreviewRefreshStyle]) {
        [self updatePreviewRefreshStylesMenu];
    } else if ([keyPath hasSuffix:kDefaultsEditorTheme]) {
        [self updateEditorThemesMenu];
    }
}

- (void)updateEditorThemesMenu {
    int index = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorTheme] intValue];
    [self checkItemAtIndex:index inSubmenu:[self editorThemesSubmenu]];
}

- (void)updatePreviewRefreshStylesMenu {
    NSString *title = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsPreviewRefreshStyle];
    [self checkItemWithTitle:title inSubmenu:[self previewRefreshStylesSubmenu]];
}

- (void)checkItemAtIndex:(int)index inSubmenu:(NSMenu *)submenu {
    NSArray *items = [submenu itemArray];
    for (int i = 0; i < [items count]; i++) {
        NSMenuItem *item = [items objectAtIndex:i];
        [item setState:(i == index)];
    }
}

- (void)checkItemWithTitle:(NSString *)title inSubmenu:(NSMenu *)submenu {
    NSArray *items = [submenu itemArray];
    for (int i = 0; i < [items count]; i++) {
        NSMenuItem *item = [items objectAtIndex:i];
        [item setState:0];
    }
    [[submenu itemWithTitle:title] setState:1];
}

#pragma mark - Menus

- (IBAction)showReadme:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/sveinbjornt/ManDrake"]];
}

- (IBAction)showLicense:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"License.html" ofType:nil];
    [[NSWorkspace sharedWorkspace] openPathInDefaultBrowser:path];
}

- (IBAction)submenuItemSelected:(id)sender {
    if ([sender menu] == [self editorThemesSubmenu]) {
        [[NSUserDefaults standardUserDefaults] setObject:@([sender tag]) forKey:kDefaultsEditorTheme];
    } else if ([sender menu] == [self previewRefreshStylesSubmenu]) {
        [[NSUserDefaults standardUserDefaults] setObject:[sender title] forKey:kDefaultsPreviewRefreshStyle];
    }
}

@end
