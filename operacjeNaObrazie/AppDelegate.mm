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
#include <cmath>
#include <thread>
using namespace std;

#define RGBA(i) (i).r, (i).g, (i).b, (i).a
@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

bool grayScaleSwitch = 0, negativeSwitch = 0, boxBlurSwitch = 0, gaussBlurSwitch = 0, gaussOptimizedSwitch = 0, gaussianWThreads = 0;

- (IBAction) grayScaleSwitch:(id)sender {
    grayScaleSwitch = !grayScaleSwitch;
}

- (IBAction) negativeSwitch:(id)sender {
    negativeSwitch = !negativeSwitch;
}

- (IBAction) boxBlurSwitch:(id)sender {
    boxBlurSwitch = !boxBlurSwitch;
}

- (IBAction) gaussBlurSwitch:(id)sender {
    gaussBlurSwitch = !gaussBlurSwitch;
}

- (IBAction) gaussOptimizedSwitch:(id)sender {
    gaussOptimizedSwitch = !gaussOptimizedSwitch;
}

- (IBAction) gaussianWThreads:(id)sender {
    gaussianWThreads = !gaussianWThreads;
}

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

- (rgba) samplePixels:(NSImage *)image withPixel:(long)pickedPixel withPartX:(short)part withOffsetX:(short)offsetX withOffsetY:(short)offsetY {
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
    
    samplePixel = pixels[y + offsetY][x];
    if (offsetX >= 0 || offsetY >= 0) {
        if (y == height && x == width) {
            samplePixel2 = pixels[0][0];
        }
        if (x == width) {
            samplePixel2 = pixels[y + offsetY][0];
        }
        if (y == height) {
            samplePixel2 = pixels[0 + offsetY][x + offsetX];
        }
        if (x != width && y != height) {
            samplePixel2 = pixels[y + offsetY][x + offsetX];
        }
    }
    if (offsetX < 0) {
        if (y == 0 && x == 0) {
            samplePixel2 = pixels[height + offsetY][width];
        }
        if (x == 0) {
            samplePixel2 = pixels[y + offsetY][width];
        }
        if (y == 0) {
            samplePixel2 = pixels[0 + offsetY][x + offsetX];
        }
        if (x != 0 && y != 0) {
            samplePixel2 = pixels[y + offsetY][x + offsetX];
        }
    }
    if (offsetY < 0) {
        if (y == 0 && x == 0) {
            samplePixel2 = pixels[height][width];
        }
        if (x == width) {
            samplePixel2 = pixels[y + offsetY][0 + offsetX];
        }
        if (y == 0) {
            samplePixel2 = pixels[0 + offsetY][x + offsetX];
        }
        if (x != 0 && y != 0) {
            samplePixel2 = pixels[y + offsetY][x + offsetX];
        }
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
    
    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            sumRed = 0;
            sumGreen = 0;
            sumBlue = 0;
            count = 0;
            
            for (long yr = -radius; yr <= radius; ++yr) {
                for (long xr = -radius; xr <=radius; ++xr) {
                    long pixelX = x + xr;
                    long pixelY = y + yr;
                    
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
    
    NSImage *bluredImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [bluredImage addRepresentation:bitmapImageRep];
    
    return bluredImage;
}

- (vector<vector<double>>) generateGaussianKernel2D:(int)radius {
    int size = radius * 2 + 1;
    double x = 0.0, y = 0.0, r = 0.0, weightSum = 0.0, kernelSum = 0.0;
    double output;
    
    vector<vector<double>> kernel(size, vector<double>(size));
        
    // generate kernel weights
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            y = abs(i - radius);
            x = abs(j - radius);
            r = (sqrt((x * x) + (y * y)) * 2 / radius);
            output = pow(M_E, -(pow(r, 2)));
            kernel[i][j] = output;
            weightSum += output;
        }
    }
        
    // normalize 2D kernel
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            kernel[i][j] /= weightSum;
            kernelSum += kernel[i][j];
        }
    }
        
    return kernel;
}

- (vector<double>) generateGaussianKernel1D:(int)radius {
    int size = radius * 2 + 1;
    double x = 0.0, r = 0.0, weightSum = 0.0, kernelSum = 0.0;
    double output;
    vector<double> kernel(size);
    
    // generate kernel weights
    for (int i = 0; i < size; i++) {
        x = abs(i - radius);
        r = (x * 2 / radius);
        output = pow(M_E, -(pow(r, 2)));
        kernel[i] = output;
        weightSum += output;
    }
    
    // normalize 1D kernel
    for (int i = 0; i < size; i++) {
        kernel[i] /= weightSum;
        kernelSum += kernel[i];
    }
    
    return kernel;
}

-(NSImage *) gaussBlurToImage:(NSImage *)image withRadius:(int)radius {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    
    vector<vector<double>>kernel = [self generateGaussianKernel2D:radius];
    vector<vector<rgba>>pixels = [self imageStruct:image];
    
    int sumRed = 0, sumGreen = 0, sumBlue = 0, sumAlpha = 0;
    int count = 0;
    double kernelSum2 = 0.0, weight = 0.0;
    
    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            sumRed = 0;
            sumGreen = 0;
            sumBlue = 0;
            sumAlpha = 0;
            count = 0;
            
            for (int yr = -radius; yr <= radius; ++yr) {
                for (int xr = -radius; xr <=radius; ++xr) {
                    long pixelX = x + xr;
                    long pixelY = y + yr;
                    
                    if (pixelX >=  0 && pixelX < width && pixelY >=  0 && pixelY < height) {
                        rgba pixel = pixels[pixelY][pixelX];
                        weight = kernel[yr + radius][xr + radius];
                        sumRed += roundf(pixel.r * weight);
                        sumGreen += roundf(pixel.g * weight);
                        sumBlue += roundf(pixel.b * weight);
                        kernelSum2 += weight;
                    }
                }
            }
            rgba avgPixel;
            avgPixel.r = roundf(sumRed);
            avgPixel.g = roundf(sumGreen);
            avgPixel.b = roundf(sumBlue);
            
            rawImageData[pixelIndex] = avgPixel.r;
            rawImageData[pixelIndex +  1] = avgPixel.g;
            rawImageData[pixelIndex +  2] = avgPixel.b;
        }
    }
    
    NSImage *bluredImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [bluredImage addRepresentation:bitmapImageRep];
    
    return bluredImage;
}

- (NSImage *) gaussBlurToImageOptimized:(NSImage *)image withRadius:(int)radius {
    NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:image];
    
    const NSInteger width = bitmapImageRep.pixelsWide;
    const NSInteger height = bitmapImageRep.pixelsHigh;
    unsigned char *rawImageData = [bitmapImageRep bitmapData];
    
    vector<double>kernel = [self generateGaussianKernel1D:radius];
    vector<vector<rgba>>pixels = [self imageStruct:image];
    
    int sumRed = 0, sumGreen = 0, sumBlue = 0, sumAlpha = 0;
    int count = 0;
    double kernelSum2 = 0.0, weight = 0.0;
    
    NSImage *bluredImageVertical;
    NSBitmapImageRep *bitmapImageRepVertical;
    unsigned char *rawImageDataVertical;
    NSImage *bluredImage;
    
    for (long y = 0; y < height; y++) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            rgba pixel;
            sumRed = 0;
            sumGreen = 0;
            sumBlue = 0;
            sumAlpha = 0;
            count = 0;
            
            for (int yr = -radius; yr <= radius; yr++) {
                long pixelY = y + yr;
                
                if (pixelY >= 0 && pixelY < height) {
                    pixel = pixels[pixelY][x];
                    weight = kernel[yr + radius];
                    sumRed += roundf(pixel.r * weight);
                    sumGreen += roundf(pixel.g * weight);
                    sumBlue += roundf(pixel.b * weight);
                    kernelSum2 += weight;
                }
            }
            
            pixel.r = sumRed;
            pixel.g = sumGreen;
            pixel.b = sumBlue;
            
            rawImageData[pixelIndex] = pixel.r;
            rawImageData[pixelIndex +  1] = pixel.g;
            rawImageData[pixelIndex +  2] = pixel.b;
        }
    }
    
    bluredImageVertical = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [bluredImageVertical addRepresentation:bitmapImageRep];
    pixels = [self imageStruct:bluredImageVertical];
    bitmapImageRepVertical = [self createBitmapImageRepFromImage:bluredImageVertical];
    rawImageDataVertical = [bitmapImageRepVertical bitmapData];
    
    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            rgba avgPixel;
            rgba pixel;
            sumRed = 0;
            sumGreen = 0;
            sumBlue = 0;
            sumAlpha = 0;
            count = 0;
            
            for (int xr = -radius; xr <= radius; xr++) {
                long pixelX = x + xr;
                
                if (pixelX >= 0 && pixelX < width) {
                    pixel = pixels[y][pixelX];
                    weight = kernel[xr + radius];
                    sumRed += roundf(pixel.r * weight);
                    sumGreen += roundf(pixel.g * weight);
                    sumBlue += roundf(pixel.b * weight);
                    kernelSum2 += weight;
                }
            }
            
            avgPixel.r = sumRed;
            avgPixel.g = sumGreen;
            avgPixel.b = sumBlue;
            
            rawImageDataVertical[pixelIndex] = avgPixel.r;
            rawImageDataVertical[pixelIndex +  1] = avgPixel.g;
            rawImageDataVertical[pixelIndex +  2] = avgPixel.b;
        }
    }
    
    bluredImage = [[NSImage alloc] initWithSize:[bitmapImageRepVertical size]];
    [bluredImage addRepresentation:bitmapImageRepVertical];
    
    return bluredImage;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    @autoreleasepool {
        NSString *filePath = @"/Users/motionvfx/Documents/smallImage.avif";
    
        [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        inputImage = [self loadImageFromFilePath:filePath];
        
        NSLog(@"Generic pixel: %d %d %d %d", RGBA([self pickPixelFromImage:inputImage withPixel:100 withOffset:0]));
        
        int genericPixel = 331;
        int partX = 7;
        int partY = 4;
        
        NSLog(@"Pixel square sampled with next: %d %d %d %d", RGBA([self sampleSquarePixels:inputImage withSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffsetX:0 withOffsetY:0] withSecondSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffsetX:-1 withOffsetY:0] withPartY:partY]));
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (IBAction) buttonAction:(id)sender {
    NSString *senderTitle = [sender title];
    NSImage *outputImage;
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    outputImage = [self renderImage:inputImage];
    
    if ([senderTitle isEqual:@"Render image"]) {
        if (negativeSwitch == 1) {
            outputImage = [self imageToNegative:outputImage];
        }
        
        if (grayScaleSwitch == 1) {
            outputImage = [self imageToGrayScale:outputImage];
        }
        
        if (boxBlurSwitch == 1) {
            outputImage = [self boxBlurToImage:outputImage withRadius:10];
        }
        
        if (gaussBlurSwitch == 1) {
            outputImage = [self gaussBlurToImage:outputImage withRadius:10];
        }
        
        if (gaussOptimizedSwitch == 1) {
            outputImage = [self gaussBlurToImageOptimized:outputImage withRadius:10];
        }
        
    }
    else {
        NSLog(@"invalid action");
    }
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval elapsedTime = endTime - startTime;
    
    [imageView setImage:outputImage];
    NSLog(@"Time for %@: %.5f seconds", senderTitle, elapsedTime);
}
    
@end
