/*
    ManDrake - Native open-source Mac OS X man page editor
    Copyright (c) 2006-2015, Sveinbjorn Thordarson <sveinbjornt@gmail.com>

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

#import <WebKit/WebKit.h>
#import <stdlib.h>
#import "Common.h"
#import "ManDrakeDocument.h"
#import "CustomACEView.h"
#import "NSWorkspace+Additions.h"
#import "ACEView/ACEThemeNames.h"

@interface ManDrakeDocument()
{
    IBOutlet WebView *webView;
    IBOutlet NSPopUpButton *refreshTypePopupButton;
    IBOutlet NSProgressIndicator *refreshProgressIndicator;
    IBOutlet CustomACEView *aceView;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSTextField *warningsTextField;
    IBOutlet NSPopUpButton *themePopupButton;
    
    NSPoint currentScrollPosition;
    NSTimer *refreshTimer;
    NSString *fileString;
}

- (IBAction)refresh:(id)sender;

- (IBAction)makeTextLarger:(id)sender;
- (IBAction)makeTextSmaller:(id)sender;
- (IBAction)makePreviewTextLarger:(id)sender;
- (IBAction)makePreviewTextSmaller:(id)sender;

- (IBAction)loadManMdocTemplate:(id)sender;
- (IBAction)loadDefaultManTemplate:(id)sender;

@end

@implementation ManDrakeDocument

#pragma mark - NSDocument

- (NSString *)windowNibName
{
    return @"ManDrakeDocument";
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    BOOL readSuccess = NO;
    NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!fileContents && outError) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadUnknownError userInfo:nil];
    }
    if (fileContents) {
        readSuccess = YES;
        fileString = fileContents;
    }
    return readSuccess;
}

- (BOOL)writeToURL:(NSURL *)url
            ofType:(NSString *)typeName
  forSaveOperation:(NSSaveOperationType)saveOperation
originalContentsURL:(NSURL *)originalContentsURL
             error:(NSError **)outError {
    return [[aceView string] writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:outError];
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError * _Nullable *)outError {
    NSPrintInfo *printInfo = [self printInfo];
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:webView printInfo:printInfo];
    return printOp;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    ACETheme theme = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorTheme] intValue];
    [aceView setTheme:theme];
    
    [themePopupButton removeAllItems];
    [themePopupButton addItemsWithTitles:[ACEThemeNames humanThemeNames]];
    [themePopupButton selectItemAtIndex:theme];
    
    [aceView setDelegate:self];
    [aceView setModeByNameString:@"groff"];
    [aceView setShowInvisibles:YES];
    [aceView setFontSize:[[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorFontSize] intValue]];
    
    if (fileString) {
        [aceView setString:fileString];
    } else {
        [self loadDefaultManTemplate:self];
    }
   
    [self setWebViewFontSize:[[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsPreviewFontSize] intValue]];
}

#pragma mark - Editor

- (IBAction)themeChanged:(id)sender {
    [aceView setTheme:[themePopupButton indexOfSelectedItem]];
}

- (void)changeFontSize:(CGFloat)delta {
//    NSLog([aceView fontSize]);
    //    [[NSUserDefaults standardUserDefaults] setObject:@([aceView fontSize])
//                                              forKey:@"EditorFontSize"];
}

- (IBAction)makeTextLarger:(id)sender {
    [self changeFontSize:1];
}

- (IBAction)makeTextSmaller:(id)sender {
    [self changeFontSize:-1];
}

- (void)setWebViewFontSize:(int)delta {
    while (delta != 0) {
        if (delta < 0) {
            [self changePreviewFontSize:-1];
            delta++;
        } else {
            [self changePreviewFontSize:1];
            delta--;
        }
    }
}

- (void)changePreviewFontSize:(CGFloat)delta {
    (delta > 0) ? [webView makeTextLarger:self] : [webView makeTextSmaller:self];
}

- (IBAction)makePreviewTextLarger:(id)sender {
    int currentSizeDelta = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsPreviewFontSize] intValue];
    currentSizeDelta += 1;
    [[NSUserDefaults standardUserDefaults] setObject:@(currentSizeDelta) forKey:kDefaultsPreviewFontSize];
    [self changePreviewFontSize:1];
}

- (IBAction)makePreviewTextSmaller:(id)sender {
    int currentSizeDelta = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsPreviewFontSize] intValue];
    currentSizeDelta -= 1;
    [[NSUserDefaults standardUserDefaults] setObject:@(currentSizeDelta) forKey:kDefaultsPreviewFontSize];
    [self changePreviewFontSize:-1];
}

#pragma mark - Web Preview

- (IBAction)refresh:(id)sender {
	// generate preview
	[refreshProgressIndicator startAnimation:self];
	[self refreshWebView];
	[refreshProgressIndicator stopAnimation:self];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	NSString *refreshText = [refreshTypePopupButton titleOfSelectedItem];
	
	// use delayed timer
	if ([refreshText isEqualToString:@"Delayed"])
	{
		if (refreshTimer != nil)
		{
			[refreshTimer invalidate];
			refreshTimer = nil;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                        target:self
                                                      selector:@selector(updatePreview)
                                                      userInfo:nil
                                                       repeats:NO];
	}
	// or else do it for every change
	else if ([refreshText isEqualToString:@"Live"])
	{
		[self refresh:self];
	}
}

- (void)refreshWebView {
	// write man text to tmp document
    NSError *err;
	BOOL success = [[aceView string] writeToFile:kManTextTempPath
                                       atomically:YES
                                         encoding:NSUTF8StringEncoding
                                            error:&err];
    if (!success)
    {
        NSLog(@"Failed to write to path \"%@\": %@", kManTextTempPath, [err localizedDescription]);
        return;
    }

	// generate command string to create html from man text using nroff and cat2html
	NSString *cmdString = [NSString stringWithFormat:@"/usr/bin/nroff -mandoc \"%@\" | \"%@\" > \"%@\"",
                           kManTextTempPath,
                           [[NSBundle mainBundle] pathForResource:@"cat2html" ofType:nil],
                           kManHTMLTempPath];
	
	// run the command
	system([cmdString cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// get the current scroll position of the document view of the web view
	NSScrollView *theScrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	NSRect scrollViewBounds = [[theScrollView contentView] bounds];
	currentScrollPosition = scrollViewBounds.origin;

    NSMutableString *htmlString = [NSMutableString stringWithContentsOfFile:@"/tmp/ManDrakeTemp.html"
                                                                   encoding:NSUTF8StringEncoding
                                                                      error:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsInvertPreview] boolValue]) {
        [htmlString replaceOccurrencesOfString:@"<body>"
                                    withString:@"<body bgcolor=\"black\" text=\"white\">"
                                       options:NSCaseInsensitiveSearch
                                         range:NSMakeRange(0, 100)];
    }
    
    [[webView mainFrame] loadHTMLString:htmlString baseURL:nil];
    
	// tell the web view to load the generated, local html file
//	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:]]];
}

// delegate method we receive when done loading the html file.
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	// restore the scroll position
	[[[[webView mainFrame] frameView] documentView] scrollPoint:currentScrollPosition];
}

- (void)updatePreview {
	[self refresh:self];
	[refreshTimer invalidate];
	refreshTimer = nil;
}

#pragma mark - Check syntax

- (IBAction)checkSyntaxButtonPressed:(id)sender {
    [self updateAnnotations];
}

- (void)updateAnnotations {
    NSArray *warningAnnotations = [self checkSyntax];
    [aceView setAnnotations:warningAnnotations];
    if ([warningAnnotations count]) {
        [warningsTextField setStringValue:[NSString stringWithFormat:@"%lu warnings", (unsigned long)[warningAnnotations count]]];
    }
}

- (NSArray *)checkSyntax {
    NSString *manString = [aceView string];
    NSString *tmpFilePath = [[NSWorkspace sharedWorkspace] createTempFileWithContents:manString];
    
    // run task "mandoc -T lint [tempFile]"
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"mandoc" ofType:nil]];
    [task setArguments:@[@"-T", @"lint", tmpFilePath]];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];

    // read output into string
    NSString *outputStr = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile]
                                                encoding:NSUTF8StringEncoding];
    if ([outputStr length] == 0 || outputStr == nil) {
        return @[];
    }
    
    NSArray *lines = [outputStr componentsSeparatedByString:@"\n"];
    NSMutableArray *annotations = [NSMutableArray array];
    
    // parse each line of output and create annotation dict
    for (NSString *line in lines) {
        if ([line length] == 0) {
            continue;
        }
        
        NSArray *components = [line componentsSeparatedByString:[NSString stringWithFormat:@"%@:", tmpFilePath]];
        if ([components count] < 2) {
            continue;
        }
        
        NSString *warnString = components[1];
        NSArray *warnComponents = [warnString componentsSeparatedByString:@":"];
        if ([warnComponents count] < 2) {
            continue;
        }
        
        NSNumber *row = @([warnComponents[0] intValue] - 1);
        NSNumber *col = @([warnComponents[1] intValue]);
        
        NSDictionary *annotation = @{ @"row": row,
                                      @"column": col,
                                      @"text": warnString,
                                      @"type": @"warning" };
        
        [annotations addObject:annotation];
    }
    
    return annotations;
}

#pragma mark - Load templates

- (IBAction)loadManMdocTemplate:(id)sender {
    NSString *str = [NSString stringWithContentsOfFile:@"/usr/share/misc/mdoc.template"
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    [aceView setString:str];
}

- (IBAction)loadDefaultManTemplate:(id)sender {
    NSString *defaultManPath = [[NSBundle mainBundle] pathForResource:@"default.man" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:defaultManPath
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    [aceView setString:str];
}

@end
