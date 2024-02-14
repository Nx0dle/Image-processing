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
@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} rgba;

-(NSImage *) boxBlurToImage:(NSImage *)image withRadius:(int)radius {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    vector<vector<rgba>> pixels(height, vector<rgba>(width));
    
    for (long y = 0; y < height; y++) {
        for (long x = 0; x < width; x++) {
            long pixelIndex = y * width + x;
            pixels[y][x].r = rawImageData[pixelIndex * 4];
            pixels[y][x].g = rawImageData[pixelIndex * 4 + 1];
            pixels[y][x].b = rawImageData[pixelIndex  * 4 + 2];
            pixels[y][x].a = rawImageData[pixelIndex * 4 + 3];
            
            int sumRed = 0, sumGreen = 0, sumBlue = 0;
            int count = 0;
            
            for (long i = -radius; i <= radius; i++) {
                for (long j = -radius; j <=radius; j++) {
                    long pixelX = x + j;
                    long pixelY = y + i;
                    
                    if (pixelX >=  0 && pixelX < width && pixelY >=  0 && pixelY < height) {
                        rgba pixel = pixels[pixelY][pixelX];
                        sumRed += pixel.r;
                        sumGreen += pixel.g;
                        sumBlue += pixel.b;
                        count++;
                    }
                }
            }
            rgba avgPixel;
            avgPixel.r = roundf(sumRed / count);
            avgPixel.g = roundf(sumGreen / count);
            avgPixel.b = roundf(sumBlue / count);
            
            rawImageData[pixelIndex *  4] = avgPixel.r;
            rawImageData[pixelIndex *  4 +  1] = avgPixel.g;
            rawImageData[pixelIndex *  4 +  2] = avgPixel.b;
            rawImageData[pixelIndex * 4 + 3] = pixels[y][x].a;
        }
    }
    
    NSImage *bluredImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [bluredImage addRepresentation:bitmapImageRep];
    
    return bluredImage;
}

- (NSImage *) loadImageFromFilePath:(NSString *)filePath {
    return [[NSImage  alloc] initWithContentsOfFile:filePath];
}

- (NSBitmapImageRep *) createBitmapImageRepFromImage:(NSImage *)image {
    return [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
}

- (NSImage *) renderImage:(NSImage *)image {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    NSImage *colorImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [colorImage addRepresentation:bitmapImageRep];
    
    return colorImage;
}

- (NSImage *) imageToGrayScale:(NSImage *)image {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    

    NSInteger allPixelCount = bitmapImageRep.pixelsHigh * bitmapImageRep.pixelsWide;
    for (NSInteger i = 0; i < allPixelCount; ++i) {

        NSInteger pixelIndex = i * 4;
        
        uint8_t red = rawImageData[pixelIndex];
        uint8_t green = rawImageData[pixelIndex + 1];
        uint8_t blue = rawImageData[pixelIndex + 2];
        
        uint8_t grayValue = (red * 0.3 + green * 0.59 + blue * 0.11);
        
        rawImageData[pixelIndex] = grayValue;
        rawImageData[pixelIndex + 1] = grayValue;
        rawImageData[pixelIndex + 2] = grayValue;
    }

    NSImage *grayScaleImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [grayScaleImage addRepresentation:bitmapImageRep];
    
    return grayScaleImage;
}

- (NSImage *) imageToNegative:(NSImage *)image {
    const uint8_t MAXRGBA = 255;
    
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    unsigned char *rawImageData = [bitmapImageRep bitmapData];

    NSInteger allPixelCount = bitmapImageRep.pixelsHigh * bitmapImageRep.pixelsWide;
    for (NSInteger i = 0; i < allPixelCount; ++i) {

        NSInteger pixelIndex = i * 4;
        
        rawImageData[pixelIndex] = MAXRGBA - rawImageData[pixelIndex];
        rawImageData[pixelIndex + 1] = MAXRGBA - rawImageData[pixelIndex + 1];
        rawImageData[pixelIndex + 2] = MAXRGBA - rawImageData[pixelIndex + 2];
    }

    NSImage *negativeImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [negativeImage addRepresentation:bitmapImageRep];
    
    return negativeImage;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    @autoreleasepool {
        NSString *filePath = @"/Users/motionvfx/Documents/imgVertical.jpeg";
    
        [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        inputImage = [self loadImageFromFilePath:filePath];
        [[self.window contentView] addSubview:imageView];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (IBAction) buttonAction:(id)sender {
    NSString *buttonTitle = [sender title];
    NSImage *outputImage;
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    if ([buttonTitle  isEqual:@"Color"]) {
        outputImage = [self renderImage:inputImage];
    }
    else if ([buttonTitle isEqual:@"Negative"]) {
        outputImage = [self imageToNegative:inputImage];
    }
    
    else if ([buttonTitle isEqual:@"Gray scale"]) {
        outputImage = [self imageToGrayScale:inputImage];
    }
    
    else if ([buttonTitle isEqual:@"Blur"]) {
        outputImage = [self boxBlurToImage:inputImage withRadius:10];
    }
    
    else {
        NSLog(@"Invalid action");
    }
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval elapsedTime = endTime - startTime;
    
    [imageView setImage:outputImage];
    NSLog(@"Time for negative: %.5f seconds", elapsedTime);
}
    
@end
