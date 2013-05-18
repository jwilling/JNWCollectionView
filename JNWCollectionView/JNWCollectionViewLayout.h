//
//  JNWCollectionViewLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JNWCollectionViewDirection) {
	JNWCollectionViewDirectionLeft,
	JNWCollectionViewDirectionRight,
	JNWCollectionViewDirectionUp,
	JNWCollectionViewDirectionDown
};

@interface JNWCollectionViewLayoutAttributes : NSObject
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat alpha;
@end

@class JNWCollectionView;
@interface JNWCollectionViewLayout : NSObject

@property (nonatomic, weak, readonly) JNWCollectionView *collectionView;

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

- (void)prepareLayout;

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)section kind:(NSString *)kind;

- (BOOL)wantsIndexPathsForItemsInRect;
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

// Returning YES to this method will inform the collection view that the
// layout implements -rectForSectionAtIndex:.
//
// Default implementation returns NO.
- (BOOL)wantsRectForSectionAtIndex;

// This method decreases the time taken to recalculate layout information
// since the layout can usually provide a pre-calculated rect far faster than
// the collection view itself can calculate it.
//
// Be sure to account for supplementary views, in addition to cells when calculating
// this rect. The behavior when the returned rect is incorrect is undefined.
- (CGRect)rectForSectionAtIndex:(NSInteger)index;


// Subclasses must implement this method for arrowed selection to work.
- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath;

@end
