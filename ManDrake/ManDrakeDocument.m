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

#import <WebKit/WebKit.h>
#import <stdlib.h>
#import "Common.h"
#import "ManDrakeDocument.h"
#import "CustomACEView.h"
#import "NSWorkspace+Additions.h"
#import "ACEView/ACEThemeNames.h"
#import "ACEView/ACEModes.h"
#import "ManDrakeApplicationDelegate.h"

@interface ManDrakeDocument()
{
    IBOutlet WebView *webView;
    IBOutlet NSPopUpButton *refreshTypePopupButton;
    IBOutlet NSProgressIndicator *refreshProgressIndicator;
    IBOutlet CustomACEView *aceView;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSTextField *warningsTextField;
    IBOutlet NSPopUpButton *themePopupButton;
    IBOutlet NSButton *editorActionButton;
    IBOutlet NSButton *previewActionButton;
    
    NSPoint currentScrollPosition;
    NSTimer *refreshTimer;
    NSTimer *syntaxCheckingTimer;
    NSString *documentTextString;
    
    dispatch_queue_t backgroundQueue;
}

- (IBAction)refresh:(id)sender;

- (IBAction)makeTextLarger:(id)sender;
- (IBAction)makeTextSmaller:(id)sender;
- (IBAction)makePreviewTextLarger:(id)sender;
- (IBAction)makePreviewTextSmaller:(id)sender;

- (IBAction)editorActionButtonPressed:(id)sender;
- (IBAction)previewActionButtonPressed:(id)sender;
- (IBAction)previewInTerminal:(id)sender;

- (IBAction)loadManMdocTemplate:(id)sender;
- (IBAction)loadDefaultManTemplate:(id)sender;

- (IBAction)exportAsHTML:(id)sender;
- (IBAction)exportAsPDF:(id)sender;

@end

@implementation ManDrakeDocument

#pragma mark -

- (void)dealloc {
    [self stopObservingDefaults];
}

#pragma mark - NSDocument

- (NSString *)windowNibName
{
    return @"ManDrakeDocument";
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    BOOL readSuccess = NO;
    NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (fileContents) {
        readSuccess = YES;
        documentTextString = fileContents;
    } else {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
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

    backgroundQueue = dispatch_queue_create("org.sveinbjorn.ManDrake.backgroundQueue", DISPATCH_QUEUE_SERIAL);
    
    [self startObservingDefaults];
    
    // configure editor
    ACETheme theme = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsEditorTheme];
    [aceView setTheme:theme];
    [aceView setDelegate:self];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsEditorSyntaxHighlighting]) {
        [aceView setModeByNameString:@"groff"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsEditorShowInvisibles]) {
        [aceView setShowInvisibles:YES];
    }
    
    [aceView setFontSize:[[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsEditorFontSize]];
    [aceView setEmmet:NO];
    [aceView setUseSoftWrap:[[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsEditorSoftLineWrap]];

    // preview font size
    [self setWebViewFontSize:(int)[[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsPreviewFontSize]];
    
    // set action button menus
    id appDelegate = (ManDrakeApplicationDelegate *)[[NSApplication sharedApplication] delegate];
    [editorActionButton setMenu:[appDelegate editorMenu]];
    [previewActionButton setMenu:[appDelegate previewMenu]];
    
    if (documentTextString) {
        [aceView setString:documentTextString];
        documentTextString = nil;
    } else {
        [self loadDefaultManTemplate:self];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsCheckSyntaxAutomatically]) {
        [self performSelector:@selector(updateAnnotations) withObject:nil afterDelay:1.5];
    }
}

#pragma mark - Defaults observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath hasSuffix:kDefaultsEditorTheme]) {
        ACETheme theme = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorTheme] intValue];
        [aceView setTheme:theme];
    }
    else if ([keyPath hasSuffix:kDefaultsEditorShowInvisibles]) {
        BOOL showInvisibles = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorShowInvisibles] intValue];
        [aceView setShowInvisibles:showInvisibles];
    }
    else if ([keyPath hasSuffix:kDefaultsEditorSyntaxHighlighting]) {
        BOOL highlightSyntax = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorSyntaxHighlighting] intValue];
        if (highlightSyntax) {
            [aceView setModeByNameString:@"groff"];
        } else {
            [aceView setMode:ACEModeText];
        }
    }
    else if ([keyPath hasSuffix:kDefaultsEditorSoftLineWrap]) {
        BOOL softWrap = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorSoftLineWrap] intValue];
        [aceView setUseSoftWrap:softWrap];
    }
    else if ([keyPath hasSuffix:kDefaultsEditorFontSize]) {
        int fontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEditorFontSize] intValue];
        [aceView setFontSize:fontSize];
    }
    else if ([keyPath hasSuffix:kDefaultsPreviewInvert]) {
        [self updatePreview];
    }
}

- (void)startObservingDefaults {
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorTheme)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorFontSize)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorShowInvisibles)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorSyntaxHighlighting)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsEditorSoftLineWrap)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsPreviewRefreshStyle)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
                                                              forKeyPath:VALUES_KEYPATH(kDefaultsPreviewInvert)
                                                                 options:NSKeyValueObservingOptionNew
                                                                 context:NULL];
}

- (void)stopObservingDefaults {
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsEditorTheme)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsEditorFontSize)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsEditorShowInvisibles)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsEditorSyntaxHighlighting)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsEditorSoftLineWrap)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsPreviewRefreshStyle)];
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                 forKeyPath:VALUES_KEYPATH(kDefaultsPreviewInvert)];
}

#pragma mark - Editor

- (IBAction)editorActionButtonPressed:(id)sender {
    NSMenu *menu = [(ManDrakeApplicationDelegate *)[[NSApplication sharedApplication] delegate] editorMenu];
    [menu popUpMenuPositioningItem:nil atLocation:[sender frame].origin inView:[sender superview]];
}

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

- (void)textDidChange:(NSNotification *)aNotification {
    NSString *refreshText = [refreshTypePopupButton titleOfSelectedItem];
    
    // set off timer to refresh preview
    if (![[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsPreviewRefreshStyle] isEqualToString:@"Manually"]) {
        if (refreshTimer != nil) {
            [refreshTimer invalidate];
            refreshTimer = nil;
        }
        NSTimeInterval delay = [refreshText isEqualToString:@"Live"] ? 0.01 : 0.2;
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                        target:self
                                                      selector:@selector(updatePreview)
                                                      userInfo:nil
                                                       repeats:NO];
    }
    
    // set off timer to check syntax in background
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsCheckSyntaxAutomatically]) {
        if (syntaxCheckingTimer != nil) {
            [syntaxCheckingTimer invalidate];
            syntaxCheckingTimer = nil;
        }
        syntaxCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateAnnotations)
                                                             userInfo:nil
                                                              repeats:NO];
    }
}

#pragma mark - Web Preview

- (IBAction)previewActionButtonPressed:(id)sender {
    NSMenu *menu = [(ManDrakeApplicationDelegate *)[[NSApplication sharedApplication] delegate] previewMenu];
    [menu popUpMenuPositioningItem:nil atLocation:[sender frame].origin inView:[sender superview]];
}

- (IBAction)refresh:(id)sender {
	// generate preview
	[refreshProgressIndicator startAnimation:self];
	[self refreshWebView];
}

- (void)refreshWebView {
    NSString *manText = [aceView string];
    if (manText == nil || [manText length] == 0) {
        [[webView mainFrame] loadHTMLString:@"" baseURL:nil];
        return;
    }
    
    dispatch_async(backgroundQueue, ^{
        
        // Create nroff task
        NSTask *nroffTask = [[NSTask alloc] init];
        [nroffTask setLaunchPath:@"/usr/bin/nroff"];
        [nroffTask setArguments:@[@"-mandoc"]];
        
        NSPipe *nroffOutputPipe = [NSPipe pipe];
        NSPipe *nroffInputPipe = [NSPipe pipe];
        [nroffTask setStandardOutput:nroffOutputPipe];
        [nroffTask setStandardInput:nroffInputPipe];
        
        NSFileHandle *nroffWriteHandle = [nroffInputPipe fileHandleForWriting];
        
        // Create cat2html task
        NSTask *catTask = [[NSTask alloc] init];
        [catTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"cat2html" ofType:nil]];
        [catTask setArguments:@[]];
        
        NSPipe *catOutputPipe = [NSPipe pipe];
        [catTask setStandardOutput:catOutputPipe];
        [catTask setStandardInput:nroffOutputPipe];
        
        NSFileHandle *catReadHandle = [catOutputPipe fileHandleForReading];
        
        [nroffTask launch];
        [catTask launch];
        
        // Write string to nroff's stdin
        [nroffWriteHandle writeData:[manText dataUsingEncoding:NSUTF8StringEncoding]];
        [nroffWriteHandle closeFile];
        
        [nroffTask waitUntilExit];
        [catTask waitUntilExit];
        
        // Read output from cat2html's stdout
        NSMutableString *htmlString = [[NSMutableString alloc] initWithData:[catReadHandle readDataToEndOfFile]
                                                                   encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if ([htmlString length] == 0 || htmlString == nil) {
                [[webView mainFrame] loadHTMLString:@"<strong>Nil output from cat2html</strong>" baseURL:nil];
                NSLog(@"Nil output from cat2html");
                return;
            }
            
            // get the current scroll position of the document view of the web view
            NSScrollView *theScrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
            NSRect scrollViewBounds = [[theScrollView contentView] bounds];
            currentScrollPosition = scrollViewBounds.origin;
            
            // invert black/white
            BOOL invert = [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsPreviewInvert] boolValue];
            if (invert) {
                NSString *bgColor = invert ? @"black" : @"white";
                NSString *fgColor = invert ? @"white" : @"black";
                NSString *bodyTag = [NSString stringWithFormat:@"<body bgcolor=\"%@\" text=\"%@\">", bgColor, fgColor];
                [htmlString replaceOccurrencesOfString:@"<body>"
                                            withString:bodyTag
                                               options:NSCaseInsensitiveSearch
                                                 range:NSMakeRange(0, 50)];
            }
            
            [[webView mainFrame] loadHTMLString:htmlString baseURL:nil];
            [refreshProgressIndicator stopAnimation:self];
        });
    });
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	// restore the scroll position
	[[[[webView mainFrame] frameView] documentView] scrollPoint:currentScrollPosition];
}

- (void)updatePreview {
	[self refresh:self];
	[refreshTimer invalidate];
	refreshTimer = nil;
}

- (IBAction)previewInTerminal:(id)sender {
    NSString *path = [[self fileURL] path];
    if ([self fileURL] == nil) {
        path = [[NSWorkspace sharedWorkspace] createTempFileWithContents:[aceView string]];
    }
    NSString *cmd = [NSString stringWithFormat:@"/usr/bin/nroff -mandoc '%@' | less", path];
    [[NSWorkspace sharedWorkspace] runCommandInTerminal:cmd];
}

#pragma mark - Check syntax

- (IBAction)checkSyntaxButtonPressed:(id)sender {
    [self updateAnnotations];
}

- (void)updateAnnotations {
    [syntaxCheckingTimer invalidate];
    syntaxCheckingTimer = nil;
    
    dispatch_async(backgroundQueue, ^{
    
        NSDictionary *syntaxCheckDict = [self checkSyntax];
        NSArray *annotations = syntaxCheckDict[@"annotations"];
        int errCount = [syntaxCheckDict[@"errors"] intValue];
        int warnCount = [syntaxCheckDict[@"warnings"] intValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Generate error and warning count info string
            NSMutableString *status = [NSMutableString stringWithString:@""];
            NSColor *color = [NSColor orangeColor];
            if (errCount) {
                [status appendFormat:@"%d errors", errCount];
                color = [NSColor redColor];
            }
            if (warnCount) {
                if ([status length]) {
                    [status appendString:@", "];
                }
                [status appendFormat:@"%d warnings", warnCount];
            }
            
            [warningsTextField setStringValue:status];
            [warningsTextField setTag:[annotations count]];
            [warningsTextField setTextColor:color];

            [aceView setAnnotations:annotations];
        });
    });
}

- (NSDictionary *)checkSyntax {
    // run task "mandoc -T lint [tempFile]"
    NSTask *mandocTask = [[NSTask alloc] init];
    [mandocTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"mandoc" ofType:nil]];
    [mandocTask setArguments:@[@"-T", @"lint"]];
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *inputPipe = [NSPipe pipe];
    [mandocTask setStandardOutput:outputPipe];
    [mandocTask setStandardError:outputPipe];
    [mandocTask setStandardInput:inputPipe];
    
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    NSFileHandle *writeHandle = [inputPipe fileHandleForWriting];
    
    [mandocTask launch];
    
    // write to stdin
    [writeHandle writeData:[[aceView string] dataUsingEncoding:NSUTF8StringEncoding]];
    [writeHandle closeFile];
    
    [mandocTask waitUntilExit];

    // read output into string
    NSString *outputStr = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile]
                                                encoding:NSUTF8StringEncoding];
    [readHandle closeFile];
    
    if ([outputStr length] == 0 || outputStr == nil) {
        return @{ @"annotations": @[] };
    }
    
    NSArray *lines = [outputStr componentsSeparatedByString:@"\n"];
    NSMutableArray *annotations = [NSMutableArray array];
    int errCount = 0;
    
    // parse each line of output and create annotation dict
    for (NSString *line in lines) {
        if ([line length] == 0) {
            continue;
        }
        
        // mandoc lint output lines have the following format:
        // mandoc: /path/to/manpage.1:160:2: WARNING: sections out of conventional order: Sh FILES
        NSArray *components = [line componentsSeparatedByString:[NSString stringWithFormat:@"<stdin>:"]];
        if ([components count] < 2) {
            NSLog(@"Unable to parse output line: \"%@\"", line);
            continue;
        }
        
        NSString *warnString = components[1];
        NSArray *warnComponents = [warnString componentsSeparatedByString:@":"];
        if ([warnComponents count] < 2) {
            NSLog(@"Unable to parse output line: \"%@\"", line);
            continue;
        }
        
        NSNumber *row = @([warnComponents[0] intValue] - 1);
        NSNumber *col = @([warnComponents[1] intValue]);
        
        BOOL isError = [line containsString:@"ERROR"];
        errCount += isError;
        NSString *typeStr = isError ? @"error" : @"warning";
        NSDictionary *annotation = @{ @"row": row,
                                      @"column": col,
                                      @"text": warnString,
                                      @"type": typeStr,
                                      @"iserror": @(isError)};
        
        [annotations addObject:annotation];
    }
    int warnCount = (int)[annotations count] - errCount;
    
    return @{   @"errors": @(errCount),
                @"warnings": @(warnCount),
                @"annotations": annotations };
}

#pragma mark - Load templates

- (IBAction)loadManMdocTemplate:(id)sender {
    NSString *str = [NSString stringWithContentsOfFile:kMdocTemplatePath
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

#pragma mark - Export

- (IBAction)exportAsHTML:(id)sender {
    NSString *defaultName = [NSString stringWithFormat:@"%@.html", [self displayName]];
    
    NSSavePanel *sPanel = [NSSavePanel savePanel];
    [sPanel setTitle:@"Export as HTML"];
    [sPanel setPrompt:@"Save"];
    [sPanel setNameFieldStringValue:defaultName];
    
    if ([sPanel runModal] != NSFileHandlingPanelOKButton) {
        return;
    }
    
    NSString *filePath = [[sPanel URL] path];
    WebDataSource *source = [[webView mainFrame] dataSource];
    NSData *data = [source data];
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [htmlString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)exportAsPDF:(id)sender {
    NSString *defaultName = [NSString stringWithFormat:@"%@.pdf", [self displayName]];
    
    NSSavePanel *sPanel = [NSSavePanel savePanel];
    [sPanel setTitle:@"Export as PDF"];
    [sPanel setPrompt:@"Save"];
    [sPanel setNameFieldStringValue:defaultName];
    
    if ([sPanel runModal] != NSFileHandlingPanelOKButton) {
        return;
    }
    NSString *pdfOutputPath = [[sPanel URL] path];
    
    // groff -Tps -mandoc -c | pstopdf -i -o pdfOutputPath.pdf
    
    // Create groff task
    NSTask *groffTask = [[NSTask alloc] init];
    [groffTask setLaunchPath:@"/usr/bin/groff"];
    [groffTask setArguments:@[@"-Tps", @"-mandoc", @"-c"]];
    
    NSPipe *groffOutputPipe = [NSPipe pipe];
    NSPipe *groffInputPipe = [NSPipe pipe];
    [groffTask setStandardOutput:groffOutputPipe];
    [groffTask setStandardInput:groffInputPipe];
    
    NSFileHandle *writeHandle = [groffInputPipe fileHandleForWriting];
    
    // Create cat2html task
    NSTask *pstopdfTask = [[NSTask alloc] init];
    [pstopdfTask setLaunchPath:@"/usr/bin/pstopdf"];
    [pstopdfTask setArguments:@[@"-i", @"-o", pdfOutputPath]];
    [pstopdfTask setStandardInput:groffOutputPipe];

    [groffTask launch];
    [pstopdfTask launch];
    
    // Write string to groff's stdin
    [writeHandle writeData:[[aceView string] dataUsingEncoding:NSUTF8StringEncoding]];
    [writeHandle closeFile];
    
    [groffTask waitUntilExit];
    [pstopdfTask waitUntilExit];
}

@end
