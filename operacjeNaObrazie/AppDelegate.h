//
//  AppDelegate.h
//  operacjeNaObrazie
//
//  Created by MotionVFX on 12/02/2024.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSImageView *imageView;
    IBOutlet NSImageView *modImageView;
    NSImage *inputImage;
}

typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} rgba;

- (NSImage *) imageToGrayScale:(NSImage *)image;
- (NSImage *) imageToNegative:(NSImage *)image;

@end

