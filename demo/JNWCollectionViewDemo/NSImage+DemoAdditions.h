//
//  NSImage+DemoAdditions.h
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSImage (DemoAdditions)

+ (NSImage *)standardGradientImageWithHeight:(CGFloat)height;
+ (NSImage *)highlightedGradientImageWithHeight:(CGFloat)height;
+ (NSImage *)gradientImageWithHeight:(CGFloat)height color:(NSColor*)c;
@end
