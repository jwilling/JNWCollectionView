//
//  DemoImageCache.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 5/19/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "DemoImageCache.h"

@interface DemoImageCache()
@property (nonatomic, strong) NSMutableDictionary *cache;
@end

@implementation DemoImageCache

- (id)init {
	self = [super init];
	if (self == nil) return nil;
	self.cache = [NSMutableDictionary dictionary];
	return self;
}

- (void)cacheImage:(NSImage *)image withIdentifier:(NSString *)identifier size:(CGSize)size {
	NSString *key = [NSString stringWithFormat:@"%@%@", identifier, NSStringFromSize(size)];
	self.cache[key] = image;
}

- (NSImage *)cachedImageWithIdentifier:(NSString *)identifier size:(CGSize)size withCreationBlock:(NSImage *(^)(CGSize))block {
	NSParameterAssert(identifier);
	NSString *key = [NSString stringWithFormat:@"%@%@", identifier, NSStringFromSize(size)];
	NSImage *cachedImage = self.cache[key];
	
	if (cachedImage == nil) {
		cachedImage = block(size);
		[self cacheImage:cachedImage withIdentifier:identifier size:size];
	}
	
	return cachedImage;
}

+ (instancetype)sharedCache {
	static DemoImageCache *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[self alloc] init];
	});
	return cache;
}

@end
