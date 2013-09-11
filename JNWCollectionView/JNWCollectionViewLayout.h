/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions 
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

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


// Dedicated initializer. Subclasses should override this method for their custom
// initializers.
- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

// Called when the layout is invalidated and should be recalculated.
//
// This is an appropriate time to calculate geometry for the layout. Ideally
// this data should be cached to provide faster access when the collection view
// needs the layout information at a later point in time.
//
// Will be called every time the collection view is resized, unless
// -shouldInvalidateLayoutForBoundsChange: is overridden for custom
// invalidation behavior.
- (void)prepareLayout;

// Subclasses should override these methods (if applicable) to return the layout attributes
// for the item at the specified index path, or the supplementary item for the specified
// section and kind.
//
// As these methods will be called quite frequently during scrolling of the collection view,
// time-intensive calculations should not be performed in these methods. It is better to
// do as many calculations as possible beforehand in -prepareLayout, and return
// cached information in these methods.
//
// Return values should be non-nil.
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

// Subclasses can implement this method to optionally decline a layout invalidation.
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
