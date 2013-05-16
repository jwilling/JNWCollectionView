//
//  JNWCollectionViewGridLayout.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/10/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewGridLayout.h"

typedef struct {
	CGPoint origin;
} JNWCollectionViewGridLayoutItemInfo;

NSString * const JNWCollectionViewGridLayoutHeaderIdentifier = @"JNWCollectionViewGridLayoutHeader";
NSString * const JNWCollectionViewGridLayoutFooterIdentifier = @"JNWCollectionViewGridLayoutFooter";

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

- (void)prepareLayout {
	[self.sections removeAllObjects];
	
	if (![self.delegate conformsToProtocol:@protocol(JNWCollectionViewGridLayoutDelegate)]) {
		NSLog(@"delegate does not conform to JNWCollectionViewGridLayoutDelegate!");
	}
	
	CGSize itemSize = self.itemSize;
	if ([self.delegate respondsToSelector:@selector(sizeForItemInCollectionView:)]) {
		itemSize = [self.delegate sizeForItemInCollectionView:self.collectionView];
		self.itemSize = itemSize;
	}
	
	BOOL delegateHeightForHeader = [self.delegate respondsToSelector:@selector(collectionView:heightForHeaderInSection:)];
	BOOL delegateHeightForFooter = [self.delegate respondsToSelector:@selector(collectionView:heightForFooterInSection:)];
	
	CGFloat totalWidth = CGRectGetWidth(self.collectionView.documentVisibleRect);
	NSUInteger numberOfColumns = totalWidth / itemSize.width;
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	
	self.itemPadding = 0;
	if (numberOfColumns > 0) {
		CGFloat totalPadding = totalWidth - (numberOfColumns * itemSize.width);
		self.itemPadding = floorf(totalPadding / (numberOfColumns + 1));
	}
	else {
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
			origin.x = self.itemPadding + (item % numberOfColumns) * (itemSize.width + self.itemPadding);
			origin.y = ((item - (item % numberOfColumns)) / numberOfColumns) * itemSize.height;
			sectionInfo.itemInfo[item].origin = origin;
		}
		
		sectionInfo.height = itemSize.height * ceilf((float)numberOfItems / (float)numberOfColumns);
		totalHeight += sectionInfo.height + footerHeight + headerHeight;
		[self.sections addObject:sectionInfo];
	}
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewGridLayoutSection *section = self.sections[indexPath.section];
	JNWCollectionViewGridLayoutItemInfo itemInfo = section.itemInfo[indexPath.item];
	CGFloat offset = section.offset;
	return CGRectMake(itemInfo.origin.x, itemInfo.origin.y + offset, self.itemSize.width, self.itemSize.height);
}

- (CGRect)rectForSupplementaryItemInSection:(NSInteger)idx identifier:(NSString *)identifier {
	JNWCollectionViewGridLayoutSection *section = self.sections[idx];
	
	CGFloat width = CGRectGetWidth(self.collectionView.documentVisibleRect);
	
	if ([identifier isEqualToString:JNWCollectionViewGridLayoutHeaderIdentifier]) {
		return CGRectMake(0, section.offset - section.headerHeight, width, section.headerHeight);
	} else if ([identifier isEqualToString:JNWCollectionViewGridLayoutFooterIdentifier]) {
		return CGRectMake(0, section.offset + section.height, width, section.footerHeight);
	}
	
	return CGRectZero;
}

- (BOOL)wantsIndexPathsForItemsInRect {
	return YES;
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
	NSInteger rowBegin = relativeRectTop / self.itemSize.height;
	NSInteger rowEnd = ceilf(relativeRectBottom / self.itemSize.height);
	return NSMakeRange(rowBegin, 1 + rowEnd - rowBegin);
}

@end
