//
//  JNWCollectionViewListLayout.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/9/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewListLayout.h"

typedef struct {
	CGFloat height;
	CGFloat yOffset;
} JNWCollectionViewListLayoutRowInfo;

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

- (void)prepareLayout {
	[self.sections removeAllObjects];
	
	if (![self.delegate conformsToProtocol:@protocol(JNWCollectionViewListLayoutDelegate)]) {
		NSLog(@"delegate does not conform to JNWCollectionViewListLayoutDelegate!");
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
		sectionInfo.frame = CGRectMake(0, sectionInfo.offset, collectionView.contentSize.width, sectionInfo.height);
		
		totalHeight += sectionInfo.height;
		[self.sections addObject:sectionInfo];
	}
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = [self rectForItemAtIndex:indexPath.item section:indexPath.section];
	attributes.alpha = 1.f;
	return attributes;
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemInSection:(NSInteger)idx kind:(NSString *)kind {
	JNWCollectionViewListLayoutSection *section = self.sections[idx];
	CGFloat width = self.collectionView.contentSize.width;
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

- (BOOL)wantsIndexPathsForItemsInRect {
	return YES;
}

- (CGRect)rectForItemAtIndex:(NSInteger)index section:(NSInteger)section {
	JNWCollectionViewListLayoutSection *sectionInfo = self.sections[section];
	CGFloat offset = sectionInfo.offset + sectionInfo.rowInfo[index].yOffset;
	CGFloat width = self.collectionView.contentSize.width;
	CGFloat height = sectionInfo.rowInfo[index].height;
	return CGRectMake(0, offset, width, height);
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
	NSMutableArray *indexPaths = [NSMutableArray array];
	
	for (JNWCollectionViewListLayoutSection *section in self.sections) {
		if (CGRectIntersectsRect(section.frame, rect)) {
			
			// Since this is a linear set of data, we run a binary search for optimization
			// purposes, finding the rects of the upper and lower bound.
			NSInteger lowerRow = [self nearestIntersectingRowInSection:section inRect:rect ascending:NO];
			NSInteger upperRow = [self nearestIntersectingRowInSection:section inRect:rect ascending:YES];
			
			for (NSInteger item = lowerRow; item <= upperRow; item++) {
				[indexPaths addObject:[NSIndexPath jnw_indexPathForItem:item inSection:section.index]];
			}
		}
	}
				 
	return indexPaths;
}

- (NSInteger)nearestIntersectingRowInSection:(JNWCollectionViewListLayoutSection *)section inRect:(CGRect)containingRect ascending:(BOOL)ascending {
	NSInteger low = 0;
	NSInteger high = section.numberOfRows - 1;
	NSInteger mid;
	
	CGFloat absoluteOffset = (ascending ? CGRectGetMaxY(containingRect) : containingRect.origin.y);
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
	if (ascending) {
		while (mid < section.numberOfRows && section.rowInfo[mid].yOffset + section.offset < relativeOffset) {
			mid++;
		}
		
		return mid;
	} else {
		while (mid > 0 && section.rowInfo[mid].yOffset + section.offset > relativeOffset) {
			mid--;
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
