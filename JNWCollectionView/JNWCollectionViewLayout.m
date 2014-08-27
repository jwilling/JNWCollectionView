
#import "JNWCollectionViewLayout.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionViewLayout+Private.h"

@implementation JNWCollectionViewLayoutAttributes
@end

@implementation JNWCollectionViewLayout

- (void)invalidateLayout {
	// Forward this onto the collection view itself.
	[self.collectionView collectionViewLayoutWasInvalidated:self];
}

- (void)prepareLayout {
	// For subclasses
}

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	return [super init];
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

- (JNWCollectionViewScrollDirection)scrollDirection {
	return JNWCollectionViewScrollDirectionVertical;
}

- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)d currentIndexPath:(NSIndexPath *)currentIndexPath {
	return currentIndexPath;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return YES;
}

- (BOOL)shouldApplyExistingLayoutAttributesOnLayout {
	return YES;
}

@end
