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

@implementation JNWCollectionViewLayoutAttributes

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

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)section kind:(NSString *)kind {
	return nil;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	return nil;
}

- (CGRect)rectForSectionAtIndex:(NSInteger)index {
	return CGRectNull;
}

- (CGSize)contentSize {
	return CGSizeZero;
}

- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath {
	return currentIndexPath;
}

@end
