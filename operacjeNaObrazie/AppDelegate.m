//
//  AppDelegate.m
//  operacjeNaObrazie
//
//  Created by MotionVFX on 12/02/2024.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(1, 1, 700, 500)];
    [imageView setImage:[NSImage imageNamed:@"testImg"]];
    [[self.window contentView] addSubview:imageView];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(10,10,200,24)];
    [textField setStringValue:@"Your text goes here"];
    
    
    [[self.window contentView] addSubview:textField];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

-(IBAction) button:(id)sender {
}
@end
