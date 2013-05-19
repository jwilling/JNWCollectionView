//
//  DemoImageCache.h
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 5/19/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoImageCache : NSObject

+ (instancetype)sharedCache;

- (NSImage *)cachedImageWithIdentifier:(NSString *)identifier size:(CGSize)size withCreationBlock:(NSImage * (^)(CGSize size))block;

@end
