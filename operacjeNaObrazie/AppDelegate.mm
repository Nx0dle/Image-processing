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

- (vector<vector<rgba>>) imageStruct:(NSImage *)image {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    vector<vector<rgba>> pixels(height, vector<rgba>(width));
    
    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            pixels[y][x].r = rawImageData[pixelIndex];
            pixels[y][x].g = rawImageData[pixelIndex + 1];
            pixels[y][x].b = rawImageData[pixelIndex + 2];
        }
    }
    return pixels;
}

- (double)gaussianWithX:(double)x {
    return exp(-pow(x,  2));
}

- (rgba) samplePixels:(NSImage *)image withPixel:(long)pickedPixel withPartX:(short)part withOffset:(short)offset {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    rgba samplePixel;
    rgba samplePixel2;
    vector<vector<rgba>>pixels = [self imageStruct:image];
    long pixelCount = 0;
    int x = 0;
    int y = 0;
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            if (pixelCount != pickedPixel) {
                pixelCount++;
            }
            else {
                break;
            }
        }
        if (pixelCount == pickedPixel) {
            break;
        }
    }
    
    samplePixel = pixels[y + offset][x];
    if (y == height && x == width) {
        samplePixel2 = pixels[0][0];
    }
    if (x == width) {
        samplePixel2 = pixels[y + offset][0];
    }
    if (y == height) {
        samplePixel2 = pixels[0 + offset][x + 1];
    }
    if (x != width && y != height) {
        samplePixel2 = pixels[y + offset][x + 1];
    }
    
    double samplePixelPart = samplePixel.r * part / 10;
    double samplePixel2Part = samplePixel2.r * (10 - part) / 10;
    double outputRed = samplePixelPart + samplePixel2Part;
    
    samplePixelPart = samplePixel.g * part / 10;
    samplePixel2Part = samplePixel2.g * (10 - part) / 10;
    double outputGreen = samplePixelPart + samplePixel2Part;
    
    samplePixelPart = samplePixel.b * part / 10;
    samplePixel2Part = samplePixel2.b * (10 - part) / 10;
    double outputBlue = samplePixelPart + samplePixel2Part;
    
    samplePixelPart = samplePixel.a * part / 10;
    samplePixel2Part = samplePixel2.a * (10 - part) / 10;
    double outputAlpha = samplePixelPart + samplePixel2Part;
    
    rgba outputSample;
    outputSample.r = outputRed;
    outputSample.g = outputGreen;
    outputSample.b = outputBlue;
    outputSample.a = outputAlpha;
    
    return outputSample;
}

-(rgba) sampleSquarePixels:(NSImage *)image withSample:(rgba)firstSampleX withSecondSample:(rgba)secondSampleX withPartY:(short)partY {
    
    double sampleY = firstSampleX.r * partY / 10;
    double secondSampleY = secondSampleX.r * (10 - partY) / 10;
    double outputRed = sampleY + secondSampleY;
    
    sampleY = firstSampleX.g * partY / 10;
    secondSampleY = secondSampleX.g * (10 - partY) / 10;
    double outputGreen = sampleY + secondSampleY;
    
    sampleY = firstSampleX.b * partY / 10;
    secondSampleY = secondSampleX.b * (10 - partY) / 10;
    double outputBlue = sampleY + secondSampleY;
    
    sampleY = firstSampleX.a * partY / 10;
    secondSampleY = secondSampleX.a * (10 - partY) / 10;
    double outputAlpha = sampleY + secondSampleY;
    
    rgba squareSample;
    squareSample.r = outputRed;
    squareSample.g = outputGreen;
    squareSample.b = outputBlue;
    squareSample.a = outputAlpha;
    
    return squareSample;
}

-(rgba) pickPixelFromImage:(NSImage *)image withPixel:(long)pixelNumer withOffset:(int)offset{
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    vector<vector<rgba>>pixels = [self imageStruct:image];
    long pixelCount = 0;
    int x = 0;
    int y = 0;
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            if (pixelCount != pixelNumer) {
                pixelCount++;
            }
            else {
                break;
            }
        }
        if (pixelCount == pixelNumer) {
            break;
        }
    }
    rgba pixel = pixels[y][x + offset];
    return pixel;
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

-(NSImage *) boxBlurToImage:(NSImage *)image withRadius:(int)radius {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    
    vector<vector<rgba>>pixels = [self imageStruct:image];
    
    int sumRed = 0, sumGreen = 0, sumBlue = 0;
    int count = 0;
    
    for (int i = 0; i < 2; i++) {
        for (long y = 0; y < height; ++y) {
            for (long x = 0; x < width; ++x) {
                long pixelIndex = (y * width + x) * 4;
                sumRed = 0;
                sumGreen = 0;
                sumBlue = 0;
                count = 0;
                
                for (long i = -radius; i <= radius; ++i) {
                    for (long j = -radius; j <=radius; ++j) {
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
                
                rawImageData[pixelIndex] = avgPixel.r;
                rawImageData[pixelIndex +  1] = avgPixel.g;
                rawImageData[pixelIndex +  2] = avgPixel.b;
            }
        }
    }
    
    NSImage *bluredImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [bluredImage addRepresentation:bitmapImageRep];
    
    return bluredImage;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    @autoreleasepool {
        NSString *filePath = @"/Users/motionvfx/Documents/twoColor.avif";
    
        [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        inputImage = [self loadImageFromFilePath:filePath];
        [[self.window contentView] addSubview:imageView];
        
        NSLog(@"Generic pixel: %d %d %d %d", RGBA([self pickPixelFromImage:inputImage withPixel:100 withOffset:0]));
        
        int genericPixel = 331;
        int partX = 7;
        int partY = 4;
        
        NSLog(@"Pixel sampled with next: %d %d %d %d", RGBA([self sampleSquarePixels:inputImage withSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffset:0] withSecondSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffset:1] withPartY:partY]));
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
    NSLog(@"Time for %@: %.5f seconds", buttonTitle, elapsedTime);
}
    
@end
