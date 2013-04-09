//
//  JNWTableViewSection.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewSection.h"

@implementation JNWCollectionViewSection

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems {
	self = [super init];
	_numberOfItems = numberOfItems;
	_height = 0;
	_width = 0;
	_verticalOffset = 0;
	_horizontalOffset = 0;
	_itemInfo = calloc(numberOfItems, sizeof(JNWCollectionViewItemInfo));
	return self;
}

- (CGFloat)heightForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].size.height;
	return 0.f;
}

- (CGFloat)widthForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].size.width;
	return 0.f;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].size;
	return CGSizeZero;
}

- (CGFloat)relativeVerticalOffsetForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].yOffset;
	return 0.f;
}

- (CGFloat)relativeHorizontalOffsetForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].xOffset;
	return 0.f;
}

- (CGFloat)verticalOffsetForItemAtIndex:(NSInteger)index {
	return self.verticalOffset + [self relativeVerticalOffsetForItemAtIndex:index];
}

- (CGFloat)horizontalOffsetForItemAtIndex:(NSInteger)index {
	return self.horizontalOffset + [self relativeHorizontalOffsetForItemAtIndex:index];
}

- (void)dealloc {
	if (_itemInfo != NULL)
		free(_itemInfo);
}

@end

