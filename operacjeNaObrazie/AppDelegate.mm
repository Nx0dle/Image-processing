//
//  AppDelegate.m
//  operacjeNaObrazie
//
//  Created by MotionVFX on 12/02/2024.
//

#import "AppDelegate.h"
#include <vector>
#include <cstdint>
#include <cstring>
using namespace std;

#define RGBA(i) (i).r, (i).g, (i).b, (i).a
#define GRGBA(i) (i).r, (i).g, (i).b, (i).a

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

typedef struct rgba {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} rgba;

- (NSImage *) loadImageFromFilePath:(NSString *)filePath {
    return [[NSImage  alloc] initWithContentsOfFile:filePath];
}

- (NSBitmapImageRep *) createBitmapImageRepFromImage:(NSImage *)image {
    return [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    @autoreleasepool {
        NSString *filePath = @"/Users/motionvfx/Documents/testImg.jpeg";
        
        imageView = [[NSImageView alloc] initWithFrame:[self.window.contentView bounds]];
        [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        test2 = [self loadImageFromFilePath:filePath];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

-(IBAction) displayImg:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:test2];
    NSImage *colorImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [colorImage addRepresentation:bitmapImageRep];
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval elapsedTime = endTime - startTime;
    
    [imageView setImage:test2];
    [[self.window contentView] addSubview:imageView];
    NSLog(@"Time for color: %.5f seconds", elapsedTime);
}

-(IBAction) grayScaleCalc:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:test2];
    
    unsigned char *rawImageData = [bitmapImageRep bitmapData];

    NSInteger allPixelCount = bitmapImageRep.pixelsHigh * bitmapImageRep.pixelsWide;

    for (NSInteger i =  0; i < allPixelCount; ++i) {

        NSInteger pixelIndex = i *  4;
        
        uint8_t red = rawImageData[pixelIndex];
        uint8_t green = rawImageData[pixelIndex +  1];
        uint8_t blue = rawImageData[pixelIndex +  2];
        
        uint8_t grayValue = (red *  0.3 + green *  0.59 + blue *  0.11);
        
        rawImageData[pixelIndex] = grayValue;
        rawImageData[pixelIndex +  1] = grayValue;
        rawImageData[pixelIndex +  2] = grayValue;
        
    }

    NSImage *grayscaleImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [grayscaleImage addRepresentation:bitmapImageRep];
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval elapsedTime = endTime - startTime;
    
    [imageView setImage:grayscaleImage];
    [[self.window contentView] addSubview:imageView];
    NSLog(@"Time for gray scale: %.5f seconds", elapsedTime);
}
@end
