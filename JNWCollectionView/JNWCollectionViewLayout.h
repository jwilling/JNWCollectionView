//
//  JNWCollectionViewLayout.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNWCollectionView.h"

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

// Subclasses should an array of index paths that the layout decides should be inside the
// specified rect. Implementing this method can provide far more optimized performance during scrolling.
//
// Default return value is nil.
- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;

// Subclasses should override this method to return the size of the specified section.
//
// Overriding this method significantly decreases the time taken to recalculate layout
// information since the layout can usually provide a pre-calculated rect far faster
// than the collection view itself can calculate it.
//
// Be sure to account for supplementary views, in addition to cells when calculating
// this rect. The behavior when the returned rect is incorrect is undefined.
//
// The default return value is CGRectNull.
- (CGRect)rectForSectionAtIndex:(NSInteger)index;

// The complete size of all sections combined. Overriding this method is optional,
// however if a different size is desired than what can be inferred from the section
// frames, it should be overridden.
//
// Note that the collection view will discard any values smaller than the frame size, so
// if if an axis does not need to be scrolled a value of 0 can be provided.
//
// Defaults to CGSizeZero, which means it will fit the collection view's frame.
- (CGSize)contentSize;

// Subclasses must implement this method for arrowed selection to work.
- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath;

// Subclasses can implement this method to optinally decline a layout invalidation.
//
// The default return value is YES.
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds;

@end

@interface JNWCollectionView()

// Returns whether an index path contains a valid item.
- (BOOL)validateIndexPath:(NSIndexPath *)indexPath;

// Returns the next index path after the specified index path, or nil if it is the last index.
- (NSIndexPath *)indexPathForNextSelectableItemAfterIndexPath:(NSIndexPath *)indexPath;

// Returns the next index path before the specified index path, or nil if it is the last index.
- (NSIndexPath *)indexPathForNextSelectableItemBeforeIndexPath:(NSIndexPath *)indexPath;

@end
