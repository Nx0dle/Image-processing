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
    vector<vector<rgba>> imageStruct(height, vector<rgba>(width));
    
    for (long y = 0; y < height; ++y) {
        for (long x = 0; x < width; ++x) {
            long pixelIndex = (y * width + x) * 4;
            imageStruct[y][x].r = rawImageData[pixelIndex];
            imageStruct[y][x].g = rawImageData[pixelIndex + 1];
            imageStruct[y][x].b = rawImageData[pixelIndex + 2];
        }
    }
    return imageStruct;
}

- (NSImage *) structToImage:(vector<vector<rgba>>)imageStruct withTemplate:(NSImage *)templateImage {
    @autoreleasepool {
        unsigned long height = imageStruct.size();
        unsigned long width = imageStruct[0].size();
        NSBitmapImageRep *bitmapImageRep = [self createBitmapImageRepFromImage:templateImage];
        unsigned char *rawImageData = [bitmapImageRep bitmapData];
        
        for (long y = 0; y < height; ++y) {
            for (long x = 0; x < width; ++x) {
                long pixelIndex = (y * width + x) * 4;
                
                rawImageData[pixelIndex] = imageStruct[y][x].r;
                rawImageData[pixelIndex + 1] = imageStruct[y][x].g;
                rawImageData[pixelIndex + 2] = imageStruct[y][x].b;
                rawImageData[pixelIndex + 3] = imageStruct[y][x].a;
            }
        }
        NSImage *outputImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
        [outputImage addRepresentation:bitmapImageRep];
        
        return outputImage;
    }
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

-(vector<vector<rgba>>) boxBlurToImage:(vector<vector<rgba>>)imageStruct withRadius:(int)radius {
    @autoreleasepool {
        unsigned long height = imageStruct.size();
        unsigned long width = imageStruct[0].size();
        int sumRed = 0, sumGreen = 0, sumBlue = 0;
        int count = 0;
        
        for (long y = 0; y < height; ++y) {
            for (long x = 0; x < width; ++x) {
                sumRed = 0; sumGreen = 0; sumBlue = 0; count = 0;
                rgba pixel;
                
                for (long yr = -radius; yr <= radius; ++yr) {
                    for (long xr = -radius; xr <=radius; ++xr) {
                        long pixelX = x + xr;
                        long pixelY = y + yr;
                        
                        if (pixelX >=  0 && pixelX < width && pixelY >=  0 && pixelY < height) {
                            pixel = imageStruct[pixelY][pixelX];
                            sumRed += pixel.r;
                            sumGreen += pixel.g;
                            sumBlue += pixel.b;
                            count++;
                        }
                    }
                }
                imageStruct[y][x].r = (sumRed / count);
                imageStruct[y][x].g = (sumGreen / count);
                imageStruct[y][x].b = (sumBlue / count);
                imageStruct[y][x].a = 255;
            }
        }
        return imageStruct;
    }
}

-(vector<vector<rgba>>) gaussBlurToImage:(vector<vector<rgba>>)imageStruct withRadius:(int)radius {
    @autoreleasepool {
        unsigned long height = imageStruct.size();
        unsigned long width = imageStruct[0].size();
        vector<vector<double>>kernel = [self generateGaussianKernel2D:radius];
        
        int count = 0;
        double weight = 0., sumRed = 0., sumGreen = 0., sumBlue = 0.;
        
        for (long y = 0; y < height; ++y) {
            for (long x = 0; x < width; ++x) {
                sumRed = 0; sumGreen = 0; sumBlue = 0; count = 0;
                rgba pixel;
                
                for (int yr = -radius; yr <= radius; ++yr) {
                    for (int xr = -radius; xr <=radius; ++xr) {
                        long pixelX = x + xr;
                        long pixelY = y + yr;
                        
                        if (pixelX >=  0 && pixelX < width && pixelY >=  0 && pixelY < height) {
                            pixel = imageStruct[pixelY][pixelX];
                            weight = kernel[yr + radius][xr + radius];
                            sumRed += pixel.r * weight;
                            sumGreen += pixel.g * weight;
                            sumBlue += pixel.b * weight;
                        }
                    }
                }
                imageStruct[y][x].r = sumRed;
                imageStruct[y][x].g = sumGreen;
                imageStruct[y][x].b = sumBlue;
                imageStruct[y][x].a = 255;
            }
        }
        return imageStruct;
    }
}

- (vector<vector<rgba>>) gaussBlurToImageOptimized:(vector<vector<rgba>>)imageStruct withRadius:(int)radius {
    @autoreleasepool {
        unsigned long height = imageStruct.size();
        unsigned long width = imageStruct[0].size();
        
        vector<double> kernel = [self generateGaussianKernel1D:radius];
        double weight = 0., sumRed = 0., sumGreen = 0., sumBlue = 0.;
        
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                sumRed = 0; sumBlue = 0; sumGreen = 0;
                rgba pixel;
                
                for (int yr = -radius; yr <= radius; ++yr) {
                    long pixelY = y + yr;
                    
                    if (pixelY >= 0 && pixelY < height) {
                        pixel = imageStruct[pixelY][x];
                        weight = kernel[yr + radius];
                        sumRed += pixel.r * weight;
                        sumGreen += pixel.g * weight;
                        sumBlue += pixel.b * weight;
                    }
                }
                imageStruct[y][x].r = sumRed;
                imageStruct[y][x].g = sumGreen;
                imageStruct[y][x].b = sumBlue;
                imageStruct[y][x].a = 255;
            }
        }
                
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                sumRed = 0; sumBlue = 0; sumGreen = 0;
                rgba pixel;
                
                for (int xr = -radius; xr <= radius; ++xr) {
                    long pixelX = xr + x;
                    
                    if (pixelX >= 0 && pixelX < width) {
                        pixel = imageStruct[y][pixelX];
                        weight = kernel[xr + radius];
                        sumRed += pixel.r * weight;
                        sumGreen += pixel.g * weight;
                        sumBlue += pixel.b * weight;
                    }
                }
                imageStruct[y][x].r = sumRed;
                imageStruct[y][x].g = sumGreen;
                imageStruct[y][x].b = sumBlue;
                imageStruct[y][x].a = 255;
            }
        }
    }
    return imageStruct;
}

//struct {
//    const vector<vector<rgba>> &inputImage;
//    vector<vector<rgba>> &outputImage;
//    const vector<double> &kernel;
//    int startY, int endY, int radius
//} inputData;

void gaussX(const vector<vector<rgba>> &inputImage, vector<vector<rgba>> *outputImage, const vector<double> &kernel, int startY, int endY, int radius, unsigned long width) {

    double weight = 0., sumRed = 0., sumGreen = 0., sumBlue = 0.;
    
    for (int y = startY; y < endY; ++y) {
        for (int x = 0; x < width; ++x) {
            sumRed = 0; sumBlue = 0; sumGreen = 0;
            rgba pixel;
            
            for (int xr = -radius; xr <= radius; ++xr) {
                long pixelX = xr + x;
                
                if (pixelX >= 0 && pixelX < width) {
                    pixel = inputImage[y][pixelX];
                    weight = kernel[xr + radius];
                    sumRed += pixel.r * weight;
                    sumGreen += pixel.g * weight;
                    sumBlue += pixel.b * weight;
                }
            }
            (*outputImage)[y][x].r = sumRed;
            (*outputImage)[y][x].g = sumGreen;
            (*outputImage)[y][x].b = sumBlue;
            (*outputImage)[y][x].a = 255;
        }
    }
}

- (vector<vector<rgba>>) gaussBlurToImageWThreads:(vector<vector<rgba>>)imageStruct withRadius:(int)radius withThreads:(int)threadsNo {
    vector<thread> threadV(threadsNo);
    vector<vector<rgba>> outputStruct(imageStruct);
    vector<double> kernel = [self generateGaussianKernel1D:radius];
    
    unsigned long height = imageStruct.size();
    unsigned long width = imageStruct[0].size();
    
    int stripeheight = (int)height / threadsNo;
    for (int s = 0; s < threadsNo; ++s) {
        int startY = s * stripeheight, endY = (s == threadsNo - 1) ? (int)height : (s + 1) * stripeheight;
        threadV[s]= thread(gaussX, imageStruct, &outputStruct, kernel, startY, endY, radius, width);
    }
    for (int s = 0; s < threadsNo; ++s) {
        threadV[s].join();
    }
    
    return outputStruct;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    @autoreleasepool {
        NSString *filePath = @"/Users/motionvfx/Documents/big.jpeg";
    
        [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        inputImage = [self loadImageFromFilePath:filePath];
        
        NSLog(@"Generic pixel: %d %d %d %d", RGBA([self pickPixelFromImage:inputImage withPixel:100 withOffset:0]));
        
        int genericPixel = 331;
        int partX = 7;
        int partY = 4;
        
        NSLog(@"Pixel square sampled with next: %d %d %d %d", RGBA([self sampleSquarePixels:inputImage withSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffsetX:0 withOffsetY:0] withSecondSample:[self samplePixels:inputImage withPixel:genericPixel withPartX:partX withOffsetX:-1 withOffsetY:0] withPartY:partY]));
        
        NSLog(@"%d", thread::hardware_concurrency());
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
    
    outputImage = [self renderImage:inputImage];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    if ([senderTitle isEqual:@"Render image"]) {
        if (negativeSwitch == 1) {
            outputImage = [self imageToNegative:outputImage];
        }
        
        if (grayScaleSwitch == 1) {
            outputImage = [self imageToGrayScale:outputImage];
        }
        
        if (boxBlurSwitch == 1) {
            outputImage = [self structToImage:[self boxBlurToImage:[self imageStruct:outputImage] withRadius:10] withTemplate:outputImage];
        }
        
        if (gaussBlurSwitch == 1) {
            outputImage = [self structToImage:[self gaussBlurToImage:[self imageStruct:outputImage] withRadius:10] withTemplate:outputImage];
        }
        
        if (gaussOptimizedSwitch == 1) {
            outputImage = [self structToImage:[self gaussBlurToImageOptimized:[self imageStruct:outputImage] withRadius:40] withTemplate:outputImage];
        }
        
        if (gaussianWThreads == 1) {
            outputImage = [self structToImage:[self gaussBlurToImageWThreads:[self imageStruct:outputImage] withRadius:40 withThreads:8] withTemplate:outputImage];
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
