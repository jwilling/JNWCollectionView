//
//  JNWCollectionViewSection.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/24/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewSection.h"

@implementation JNWCollectionViewSection

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems {
	self = [super init];
	_numberOfItems = numberOfItems;
	_itemInfo = calloc(numberOfItems, sizeof(JNWCollectionViewItemInfo));
	return self;
}

- (CGRect)frameForItemAtIndex:(NSInteger)index {
	if (index < self.numberOfItems && index >= 0)
		return self.itemInfo[index].frame;
	return CGRectZero;
}

- (void)dealloc {
	if (_itemInfo != NULL)
		free(_itemInfo);
}

@end

