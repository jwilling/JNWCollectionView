//
//  JNWCollectionViewFlowLayout.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/11/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewFlowLayout.h"

typedef struct {
	CGPoint origin;
	CGSize size;
} JNWCollectionViewFlowLayoutItemInfo;

@interface JNWCollectionViewFlowLayoutSection : NSObject
- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) JNWCollectionViewFlowLayoutItemInfo *itemInfo;
@end

@implementation JNWCollectionViewFlowLayoutSection

- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems {
	self = [super init];
	if (self == nil) return nil;
	_numberOfItems = numberOfItems;
	self.itemInfo = calloc(numberOfItems, sizeof(JNWCollectionViewFlowLayoutItemInfo));
	return self;
}

- (void)dealloc {
	if (_itemInfo != NULL)
		free(_itemInfo);
}

@end

@interface JNWCollectionViewFlowLayout()
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation JNWCollectionViewFlowLayout

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	self = [super initWithCollectionView:collectionView];
	if (self == nil) return nil;
	_minimumItemHorizontalSeparation = 10.f;
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
	
	if (![self.delegate conformsToProtocol:@protocol(JNWCollectionViewFlowLayoutDelegate)]) {
		NSLog(@"delegate does not conform to JNWCollectionViewFlowLayoutDelegate!");
	}
	
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	CGFloat totalHeight = 0;
	
	for (NSUInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
		NSInteger headerHeight = [self.delegate collectionView:self.collectionView heightForHeaderInSection:section];
		NSInteger footerHeight = [self.delegate collectionView:self.collectionView heightForFooterInSection:section];
		
		JNWCollectionViewFlowLayoutSection *sectionInfo = [[JNWCollectionViewFlowLayoutSection alloc] initWithNumberOfItems:numberOfItems];
		sectionInfo.offset = totalHeight + headerHeight;
		sectionInfo.height = 0;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		
		CGRect lastAddedItemFrame = CGRectZero;
		for (NSInteger item = 0; item < numberOfItems; item++) {
			NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForItem:item inSection:section];
			CGSize itemSize = [self.delegate collectionView:self.collectionView sizeForItemAtIndexPath:indexPath];
			sectionInfo.itemInfo[item].size = itemSize;
			
			CGPoint itemOrigin = lastAddedItemFrame.origin;
			itemOrigin.x += lastAddedItemFrame.size.width + self.minimumItemHorizontalSeparation;
			
			CGRect usableRect = CGRectMake(0, 0, self.collectionView.contentSize.width, sectionInfo.height);
			
			// TODO: This will likely not work if the item size is bigger than the visible frame
			if (CGRectIntersection(usableRect, (CGRect){ .size = itemSize, .origin = itemOrigin}).size.width != itemSize.width) {
				// The item would be placed off the edge, so we bump to the next line.
				itemOrigin.x = self.minimumItemHorizontalSeparation;
				itemOrigin.y = sectionInfo.height;
				
				//TODO: This will fail horribly when the item size used for height is smalller than the rest in the row
				sectionInfo.height += itemSize.height;
			}
			
			sectionInfo.itemInfo[item].origin = itemOrigin;
			sectionInfo.itemInfo[item].size = itemSize;
			lastAddedItemFrame = (CGRect){ .origin = itemOrigin, .size = itemSize };
		}
		
		totalHeight += sectionInfo.height + footerHeight + headerHeight;
		[self.sections addObject:sectionInfo];
	}
}

- (JNWCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewFlowLayoutSection *section = self.sections[indexPath.section];
	JNWCollectionViewFlowLayoutItemInfo itemInfo = section.itemInfo[indexPath.item];
	CGFloat offset = section.offset;
	
	JNWCollectionViewLayoutAttributes *attributes = [[JNWCollectionViewLayoutAttributes alloc] init];
	attributes.frame = CGRectMake(itemInfo.origin.x, itemInfo.origin.y + offset, itemInfo.size.width, itemInfo.size.height);
	attributes.alpha = 1.f;
	return attributes;
}

@end
