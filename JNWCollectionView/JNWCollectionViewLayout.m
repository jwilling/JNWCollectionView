//
//  JNWCollectionViewLayout.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewLayout.h"

@interface JNWCollectionViewLayout()
@property (nonatomic, weak, readwrite) JNWCollectionView *collectionView;
@end

@implementation JNWCollectionViewLayout

- (void)prepareLayout {
	
}

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	self = [super init];
	if (self == nil) return nil;
	self.collectionView = collectionView;
	return self;
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGRectZero;
}

- (CGRect)rectForSupplementaryItemInSection:(NSInteger)section kind:(NSString *)kind {
	return CGRectZero;
}

- (BOOL)wantsIndexPathsForItemsInRect {
	return NO;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	return nil;
}

- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath {
	return currentIndexPath;
}

@end
