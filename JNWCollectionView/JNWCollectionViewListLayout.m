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
	self.rowInfo = calloc(numberOfRows - 1, sizeof(JNWCollectionViewListLayoutRowInfo));
	return self;
}

- (void)dealloc {
	if (_rowInfo != nil)
		free(_rowInfo);
}

@end

@interface JNWCollectionViewListLayout()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, assign) CGRect lastInvalidatedBounds;
@property (nonatomic, strong) JNWCollectionViewLayoutAttributes *markerAttributes;
@end

@implementation JNWCollectionViewListLayout

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	self = [super initWithCollectionView:collectionView];
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
	if (newBounds.size.width != self.lastInvalidatedBounds.size.width) {
		self.lastInvalidatedBounds = newBounds;
		return YES;
	}
	
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
		}
		
		sectionInfo.height += footerHeight;
		sectionInfo.frame = CGRectMake(0, sectionInfo.offset, collectionView.visibleSize.width, sectionInfo.height);
		
		totalHeight += sectionInfo.height;
		[self.sections addObject:sectionInfo];
	}
	
	if (self.collectionView.dragContext.dropPath) {
		JNWCollectionViewDropIndexPath *indexPath = self.collectionView.dragContext.dropPath;
		JNWCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
		CGRect frame = attributes.frame;
		frame.size.height = 1;
		attributes.frame = frame;
		
		_markerAttributes = attributes;
	} else {
		_markerAttributes = nil;
	}
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = [self rectForItemAtIndex:indexPath.jnw_item section:indexPath.jnw_section];
	attributes.alpha = 1.f;
	return attributes;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)idx kind:(NSString *)kind {
	JNWCollectionViewListLayoutSection *section = self.sections[idx];
	CGFloat width = self.collectionView.visibleSize.width;
	CGRect frame = CGRectZero;
	
	if ([kind isEqualToString:JNWCollectionViewListLayoutHeaderKind]) {
		frame = CGRectMake(0, section.offset, width, section.headerHeight);
	} else if ([kind isEqualToString:JNWCollectionViewListLayoutFooterKind]) {
		frame = CGRectMake(0, section.offset + section.height - section.footerHeight, width, section.footerHeight);
	}
	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = frame;
	attributes.alpha = 1.f;
	return attributes;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForDropMarker
{
	return _markerAttributes;
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

- (JNWCollectionViewDropIndexPath *)dropIndexPathAtPoint:(NSPoint)point
{
	for (JNWCollectionViewListLayoutSection *section in self.sections) {
		if (CGRectContainsPoint(section.frame, NSPointToCGPoint(point))) {
			NSUInteger index = [self rowInSection:section containingPoint:NSPointToCGPoint(point)];
			if (index == NSNotFound) {
				// Bug?
				return nil;
			} else {
				NSIndexPath *testPath = [NSIndexPath jnw_indexPathForItem:index inSection:section.index];
				if ([self.collectionView.dragContext.dragPaths containsObject:testPath]) {
					// Don't drop on a dragged item.
					return nil;
				} else {
					return [JNWCollectionViewDropIndexPath indexPathForItem:index inSection:section.index dropRelation:JNWCollectionViewDropRelationAt];
				}
			}
		}
	}

	return nil;
}

- (NSInteger)nearestIntersectingRowInSection:(JNWCollectionViewListLayoutSection *)section inRect:(CGRect)containingRect edge:(JNWListEdge)edge {
	NSInteger low = 0;
	NSInteger high = section.numberOfRows - 1;
	NSInteger mid;
	
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

- (NSUInteger)rowInSection:(JNWCollectionViewListLayoutSection *)section containingPoint:(CGPoint)point {
	NSUInteger numberOfRows = section.numberOfRows;
	NSUInteger low = 0;
	NSUInteger high = (numberOfRows > 0) ? numberOfRows - 1 : 0;
	NSUInteger mid;
	
	CGFloat relativeOffset = point.y - section.offset;
	
	while (low <= high) {
		mid = (low + high) / 2;
		JNWCollectionViewListLayoutRowInfo midInfo = section.rowInfo[mid];
		
		if (midInfo.yOffset <= relativeOffset && (midInfo.yOffset + midInfo.height) >= relativeOffset) {
			return mid;
		} else if (midInfo.yOffset > relativeOffset && mid > 0) {
			high = mid - 1;
		} else if (midInfo.yOffset < relativeOffset && mid < numberOfRows) {
			low = mid + 1;
		} else {
			break;
		}
	}
	
	return NSNotFound;
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
