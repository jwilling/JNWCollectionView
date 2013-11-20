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

#import "JNWCollectionViewGridLayout.h"

typedef struct {
	CGPoint origin;
} JNWCollectionViewGridLayoutItemInfo;

NSString * const JNWCollectionViewGridLayoutHeaderKind = @"JNWCollectionViewGridLayoutHeader";
NSString * const JNWCollectionViewGridLayoutFooterKind = @"JNWCollectionViewGridLayoutFooter";

@interface JNWCollectionViewGridLayout()
@property (nonatomic, assign) CGRect lastInvalidatedBounds;
@end

@interface JNWCollectionViewGridLayoutSection : NSObject
- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) JNWCollectionViewGridLayoutItemInfo *itemInfo;
@end

@implementation JNWCollectionViewGridLayoutSection

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems {
	self = [super init];
	if (self == nil) return nil;
	_numberOfItems = numberOfItems;
	self.itemInfo = calloc(numberOfItems, sizeof(JNWCollectionViewGridLayoutItemInfo));
	return self;
}

- (void)dealloc {
	if (_itemInfo != NULL)
		free(_itemInfo);
}

@end

static const CGSize JNWCollectionViewGridLayoutDefaultSize = (CGSize){ 44.f, 44.f };

@interface JNWCollectionViewGridLayout()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat itemPadding;
@end

@implementation JNWCollectionViewGridLayout

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	self = [super initWithCollectionView:collectionView];
	if (self == nil) return nil;
	self.itemSize = JNWCollectionViewGridLayoutDefaultSize;
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

	if (self.delegate != nil && ![self.delegate conformsToProtocol:@protocol(JNWCollectionViewGridLayoutDelegate)]) {
		NSLog(@"*** grid delegate does not conform to JNWCollectionViewGridLayoutDelegate!");
	}
	
	CGSize itemSize = self.itemSize;
	if ([self.delegate respondsToSelector:@selector(sizeForItemInCollectionView:)]) {
		itemSize = [self.delegate sizeForItemInCollectionView:self.collectionView];
		self.itemSize = itemSize;
	}
	
	BOOL delegateHeightForHeader = [self.delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)];
	BOOL delegateHeightForFooter = [self.delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)];
	
	CGFloat totalWidth = self.collectionView.visibleSize.width;
	NSUInteger numberOfColumns = totalWidth / itemSize.width;
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	
	CGFloat totalPadding = totalWidth - (numberOfColumns * itemSize.width);
	CGFloat minimumPadding = (numberOfColumns+1) * self.minimumInteritemSpacing;
	if (totalPadding < minimumPadding && numberOfColumns > 1) {
		CGFloat extraPaddingNeeded = minimumPadding - totalPadding;
		numberOfColumns -= ceil(extraPaddingNeeded / itemSize.width);
		totalPadding = totalWidth - (numberOfColumns * itemSize.width);
	}
	self.itemPadding = floorf(totalPadding / (numberOfColumns + 1));

	if (numberOfColumns < 1) {
		self.itemPadding = 0;
		numberOfColumns = 1;
	}
	self.numberOfColumns = numberOfColumns;
	
	CGFloat totalHeight = 0;
	for (NSUInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
		NSInteger headerHeight = delegateHeightForHeader ? [self.delegate collectionView:self.collectionView heightForHeaderInSection:section] : 0;
		NSInteger footerHeight = delegateHeightForFooter ? [self.delegate collectionView:self.collectionView heightForFooterInSection:section] : 0;
		
		JNWCollectionViewGridLayoutSection *sectionInfo = [[JNWCollectionViewGridLayoutSection alloc] initWithNumberOfItems:numberOfItems];
		sectionInfo.offset = totalHeight + headerHeight;
		sectionInfo.height = 0;
		sectionInfo.index = section;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		
		for (NSInteger item = 0; item < numberOfItems; item++) {
			CGPoint origin = CGPointZero;
            NSInteger column = item % numberOfColumns;
            NSInteger row = (NSInteger)floor(item / numberOfColumns);
            origin.x = self.itemPadding + column * (itemSize.width + self.itemPadding);
            origin.y = row * (itemSize.height + self.minimumLineSpacing);
			sectionInfo.itemInfo[item].origin = origin;
		}

        NSUInteger numberOfRowsInSection = (NSUInteger)ceilf((float)numberOfItems / (float)numberOfColumns);
        CGFloat totalVerticalSpacing = fmax(self.minimumInteritemSpacing*(numberOfRowsInSection-1), 0); // In case numberOfRowsInSection is 0
        sectionInfo.height = itemSize.height * numberOfRowsInSection + totalVerticalSpacing;
		totalHeight += sectionInfo.height + footerHeight + headerHeight;
		[self.sections addObject:sectionInfo];
	}
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewGridLayoutSection *section = self.sections[indexPath.jnw_section];
	JNWCollectionViewGridLayoutItemInfo itemInfo = section.itemInfo[indexPath.jnw_item];
	CGFloat offset = section.offset;
	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = CGRectMake(itemInfo.origin.x, itemInfo.origin.y + offset, self.itemSize.width, self.itemSize.height);
	attributes.alpha = 1.f;
	return attributes;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)idx kind:(NSString *)kind {
	JNWCollectionViewGridLayoutSection *section = self.sections[idx];
	CGFloat width = self.collectionView.visibleSize.width;
	CGRect frame = CGRectZero;
	
	if ([kind isEqualToString:JNWCollectionViewGridLayoutHeaderKind]) {
		frame = CGRectMake(0, section.offset - section.headerHeight, width, section.headerHeight);
	} else if ([kind isEqualToString:JNWCollectionViewGridLayoutFooterKind]) {
		frame = CGRectMake(0, section.offset + section.height, width, section.footerHeight);
	}
	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = frame;
	attributes.alpha = 1.f;
	return attributes;
}

- (CGRect)rectForSectionAtIndex:(NSInteger)index {
	JNWCollectionViewGridLayoutSection *section = self.sections[index];
	CGFloat height = section.height + section.headerHeight + section.footerHeight;
	return CGRectMake(0, section.offset, self.collectionView.visibleSize.width, height);
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	NSMutableArray *visibleRows = [NSMutableArray array];
	
	NSRange columns = [self columnsInRect:rect];
	
	for (JNWCollectionViewGridLayoutSection *section in self.sections) {
		NSRange rows = [self rowsInRect:rect fromSection:section];
		
		for (NSUInteger rowIdx = rows.location; rowIdx < NSMaxRange(rows); rowIdx++) {
			for (NSUInteger columnIdx = columns.location; columnIdx < NSMaxRange(columns); columnIdx++) {
				NSUInteger itemIdx = (self.numberOfColumns * rowIdx) + columnIdx;
				if (itemIdx >= section.numberOfItems)
					break;
				[visibleRows addObject:[NSIndexPath jnw_indexPathForItem:itemIdx inSection:section.index]];
			}
		}
	}
	
	return visibleRows;
}

- (NSIndexPath *)indexPathForNextItemInDirection:(JNWCollectionViewDirection)direction currentIndexPath:(NSIndexPath *)currentIndexPath {
	NSIndexPath *newIndexPath = currentIndexPath;
	
	if (direction == JNWCollectionViewDirectionRight) {
		newIndexPath = [self.collectionView indexPathForNextSelectableItemAfterIndexPath:currentIndexPath];
	} else if (direction == JNWCollectionViewDirectionLeft) {
		newIndexPath = [self.collectionView indexPathForNextSelectableItemBeforeIndexPath:currentIndexPath];
	} else if (direction == JNWCollectionViewDirectionUp) {
		CGPoint origin = [self.collectionView rectForItemAtIndexPath:currentIndexPath].origin;
		// Bump the origin up to the cell directly above this one.
		origin.y -= 1; // TODO: Use padding here when implemented.
		newIndexPath = [self.collectionView indexPathForItemAtPoint:origin];
	} else if (direction == JNWCollectionViewDirectionDown) {
		CGRect frame = [self.collectionView rectForItemAtIndexPath:currentIndexPath];
		CGPoint origin = frame.origin;
		// Bump the origin down to the cell directly below this one.
		origin.y += frame.size.height + 1; // TODO: Use padding here when implemented.
		newIndexPath = [self.collectionView indexPathForItemAtPoint:origin];
	}
	
	if (newIndexPath == nil && (direction == JNWCollectionViewDirectionUp || direction == JNWCollectionViewDirectionDown)) {
		CGRect frame = [self.collectionView rectForItemAtIndexPath:currentIndexPath];
		CGPoint origin = frame.origin;
		// This can occur if we have items in a grid section that don't completely fill the section on the
		// last row. Because there still might be a cell above or below, we attempt to skip a row to see if
		// this is the case.
		origin.y += (direction == JNWCollectionViewDirectionDown ? self.itemSize.height + frame.size.height + 1 : -(self.itemSize.height + 1));
		newIndexPath = [self.collectionView indexPathForItemAtPoint:origin];
	}
	
	return newIndexPath;
}

- (NSRange)columnsInRect:(CGRect)rect {
	NSRange result = NSMakeRange(0, 0);
	
	CGPoint point = CGPointMake(0, CGRectGetMinY(rect));
	for (NSUInteger column = 0; column < self.numberOfColumns; column++) {
		point.x += self.itemPadding;
		
		if (CGRectContainsPoint(rect, point)) {
			if (result.length == 0) {
				result = NSMakeRange(column, 1);
			}
			else {
				result.length++;
			}
		}
		
		point.x += self.itemSize.width;
	}
	
	return result;
}

- (NSRange)rowsInRect:(CGRect)rect fromSection:(JNWCollectionViewGridLayoutSection *)section {
	if (section.offset + section.height < CGRectGetMinY(rect) || section.offset > CGRectGetMaxY(rect)) {
		return NSMakeRange(0, 0);
	}
	
	CGFloat relativeRectTop = MAX(0, CGRectGetMinY(rect) - section.offset);
	CGFloat relativeRectBottom = CGRectGetMaxY(rect) - section.offset;
	NSInteger rowBegin = relativeRectTop / (self.itemSize.height + self.minimumLineSpacing);
	NSInteger rowEnd = ceilf(relativeRectBottom / (self.itemSize.height + self.minimumLineSpacing));
	return NSMakeRange(rowBegin, 1 + rowEnd - rowBegin);
}

@end
