//
//  NSImage+DemoAdditions.h
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (DemoAdditions)

+ (NSImage *)standardGradientImageWithHeight:(CGFloat)height;
+ (NSImage *)highlightedGradientImageWithHeight:(CGFloat)height;

@end
