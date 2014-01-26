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

#import "JNWCollectionViewListLayout.h"

typedef struct {
	CGFloat height;
	CGFloat yOffset;
} JNWCollectionViewListLayoutRowInfo;

typedef NS_ENUM(NSInteger, JNWListEdge) {
	JNWListEdgeTop,
	JNWListEdgeBottom
};

NSString * const JNWCollectionViewListLayoutHeaderKind = @"JNWCollectionViewListLayoutHeader";
NSString * const JNWCollectionViewListLayoutFooterKind = @"JNWCollectionViewListLayoutFooter";

@interface JNWCollectionViewListLayoutSection : NSObject
- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, assign) JNWCollectionViewListLayoutRowInfo *rowInfo;
@end

@implementation JNWCollectionViewListLayoutSection

- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows {
	self = [super init];
	if (self == nil) return nil;
	_numberOfRows = numberOfRows;
	self.rowInfo = calloc(numberOfRows, sizeof(JNWCollectionViewListLayoutRowInfo));
	return self;
}

- (void)dealloc {
	if (_rowInfo != nil)
		free(_rowInfo);
}

@end

@interface JNWCollectionViewListLayout()
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation JNWCollectionViewListLayout

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;
	self.rowHeight = 44.f;
	return self;
}

- (NSMutableArray *)sections {
	if (_sections == nil) {
		_sections = [NSMutableArray array];
	}
	return _sections;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return NO;
}

- (void)prepareLayout {
	[self.sections removeAllObjects];
	
	if (self.delegate != nil && ![self.delegate conformsToProtocol:@protocol(JNWCollectionViewListLayoutDelegate)]) {
		NSLog(@"*** list delegate does not conform to JNWCollectionViewListLayoutDelegate!");
	}
	
	BOOL delegateHeightForRow = [self.delegate respondsToSelector:@selector(collectionView:heightForRowAtIndexPath:)];
	BOOL delegateHeightForHeader = [self.delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)];
	BOOL delegateHeightForFooter = [self.delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)];
	JNWCollectionView *collectionView = self.collectionView;
	
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	CGFloat totalHeight = 0;
	CGFloat verticalSpacing = self.verticalSpacing;
	
	for (NSUInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfRows = [collectionView numberOfItemsInSection:section];
		NSInteger headerHeight = delegateHeightForHeader ? [self.delegate collectionView:collectionView heightForHeaderInSection:section] : 0;
		NSInteger footerHeight = delegateHeightForFooter ? [self.delegate collectionView:collectionView heightForFooterInSection:section] : 0;
		
		JNWCollectionViewListLayoutSection *sectionInfo = [[JNWCollectionViewListLayoutSection alloc] initWithNumberOfRows:numberOfRows];
		sectionInfo.offset = totalHeight;
		sectionInfo.height = 0;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		sectionInfo.index = section;
		
		sectionInfo.height += headerHeight; // the footer height is added after cells have determined their offsets
		
		for (NSInteger row = 0; row < numberOfRows; row++) {
			CGFloat rowHeight = self.rowHeight;
			NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForItem:row inSection:section];
			if (delegateHeightForRow)
				rowHeight = [self.delegate collectionView:collectionView heightForRowAtIndexPath:indexPath];
			
			sectionInfo.rowInfo[row].height = rowHeight;
			sectionInfo.rowInfo[row].yOffset = sectionInfo.height;
			sectionInfo.height += rowHeight;
			sectionInfo.height += verticalSpacing;
		}
		
		sectionInfo.height -= verticalSpacing; // We don't want spacing after the last cell.
		
		sectionInfo.height += footerHeight;
		sectionInfo.frame = CGRectMake(0, sectionInfo.offset, collectionView.visibleSize.width, sectionInfo.height);
		
		totalHeight += sectionInfo.height;
		[self.sections addObject:sectionInfo];
	}
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = [self rectForItemAtIndex:indexPath.jnw_item section:indexPath.jnw_section];
	attributes.alpha = 1.f;
	return attributes;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)sectionIdx kind:(NSString *)kind {
	JNWCollectionViewListLayoutSection *section = self.sections[sectionIdx];
	CGFloat width = self.collectionView.visibleSize.width;
	CGRect frame = CGRectZero;
	
	if ([kind isEqualToString:JNWCollectionViewListLayoutHeaderKind]) {
		frame = CGRectMake(0, section.offset, width, section.headerHeight);
		
		if (self.stickyHeaders) {
			// Thanks to http://blog.radi.ws/post/32905838158/sticky-headers-for-uicollectionview-using for the inspiration.
			CGPoint contentOffset = self.collectionView.documentVisibleRect.origin;
			CGPoint nextHeaderOrigin = CGPointMake(FLT_MAX, FLT_MAX);
			
			if (sectionIdx + 1 < self.sections.count) {
				JNWCollectionViewLayoutAttributes *nextHeaderAttributes = [self layoutAttributesForSupplementaryItemInSection:sectionIdx + 1 kind:kind];
				nextHeaderOrigin = nextHeaderAttributes.frame.origin;
			}
			
			frame.origin.y = MIN(MAX(contentOffset.y, frame.origin.y), nextHeaderOrigin.y - CGRectGetHeight(frame));
		}
	} else if ([kind isEqualToString:JNWCollectionViewListLayoutFooterKind]) {
		frame = CGRectMake(0, section.offset + section.height - section.footerHeight, width, section.footerHeight);
	}
	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = frame;
	attributes.alpha = 1.f;
	attributes.zIndex = NSIntegerMax;
	return attributes;
}

- (BOOL)shouldApplyExistingLayoutAttributesOnLayout {
	return self.stickyHeaders;
}

- (CGRect)rectForItemAtIndex:(NSInteger)index section:(NSInteger)section {
	JNWCollectionViewListLayoutSection *sectionInfo = self.sections[section];
	CGFloat offset = sectionInfo.offset + sectionInfo.rowInfo[index].yOffset;
	CGFloat width = self.collectionView.visibleSize.width;
	CGFloat height = sectionInfo.rowInfo[index].height;
	return CGRectMake(0, offset, width, height);
}

- (CGRect)rectForSectionAtIndex:(NSInteger)index {
	JNWCollectionViewListLayoutSection *section = self.sections[index];
	return section.frame;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	NSMutableArray *indexPaths = [NSMutableArray array];
	
	for (JNWCollectionViewListLayoutSection *section in self.sections) {
		if (CGRectIntersectsRect(section.frame, rect)) {
			
			// Since this is a linear set of data, we run a binary search for optimization
			// purposes, finding the rects of the upper and lower bound.
			NSInteger upperRow = [self nearestIntersectingRowInSection:section inRect:rect edge:JNWListEdgeTop];
			NSInteger lowerRow = [self nearestIntersectingRowInSection:section inRect:rect edge:JNWListEdgeBottom];
			
			for (NSInteger item = upperRow; item <= lowerRow; item++) {
				[indexPaths addObject:[NSIndexPath jnw_indexPathForItem:item inSection:section.index]];
			}
		}
	}
				 
	return indexPaths;
}

- (NSInteger)nearestIntersectingRowInSection:(JNWCollectionViewListLayoutSection *)section inRect:(CGRect)containingRect edge:(JNWListEdge)edge {
	NSInteger low = 0;
	NSInteger high = section.numberOfRows - 1;
	NSInteger mid = 0;
	
	CGFloat absoluteOffset = (edge == JNWListEdgeTop ? containingRect.origin.y : containingRect.origin.y + containingRect.size.height);
	CGFloat relativeOffset = absoluteOffset - section.offset;
	
	while (low <= high) {
		mid = (low + high) / 2;
		JNWCollectionViewListLayoutRowInfo midInfo = section.rowInfo[mid];
		
		if (midInfo.yOffset == relativeOffset) {
			return mid;
		}
		if (midInfo.yOffset > relativeOffset) {
			high = mid - 1;
		}
		if (midInfo.yOffset < relativeOffset) {
			low = mid + 1;
		}
	}
	
	// We haven't found a row that exactly aligns with the rect, which is quite often.
	if (edge == JNWListEdgeTop) {
		// Start from the current top row, and keep decreasing the index so we keep travelling up
		// until we're past the boundaries.
		while (mid > 0 && section.rowInfo[mid].yOffset > relativeOffset) {
			mid--;
		}
		
		return mid;
	} else {
		// Start from the current bottom row and keep increasing the index until we hit the lower boundary
		while (mid < (section.numberOfRows - 1) && section.rowInfo[mid].yOffset + section.rowInfo[mid].height + section.offset < relativeOffset) {
			mid++;
		}
	}
	
	return mid;
}

- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath {
	NSIndexPath *newIndexPath = currentIndexPath;
	
	if (direction == JNWCollectionViewDirectionUp) {
		newIndexPath  = [self.collectionView indexPathForNextSelectableItemBeforeIndexPath:currentIndexPath];
	} else if (direction == JNWCollectionViewDirectionDown) {
		newIndexPath = [self.collectionView indexPathForNextSelectableItemAfterIndexPath:currentIndexPath];
	}
	
	return newIndexPath;
}

@end
