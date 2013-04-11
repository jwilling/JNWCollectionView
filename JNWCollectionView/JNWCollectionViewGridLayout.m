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

@interface JNWCollectionViewGridLayoutSection : NSObject
- (instancetype)initWithNumberOfItems:(NSInteger)numberOfItems;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
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
@property (nonatomic, weak) id<JNWCollectionViewGridLayoutDelegate> delegate;
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
	
	if (![self.collectionView.delegate conformsToProtocol:@protocol(JNWCollectionViewGridLayoutDelegate)]) {
		NSLog(@"delegate does not conform to JNWCollectionViewGridLayoutDelegate!");
	}
	self.delegate = (id<JNWCollectionViewGridLayoutDelegate>)self.collectionView.delegate;
	
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	
	CGSize itemSize = self.itemSize;
	if ([self.delegate respondsToSelector:@selector(sizeForItemInCollectionView:)]) {
		itemSize = [self.delegate sizeForItemInCollectionView:self.collectionView];
		self.itemSize = itemSize;
	}
	
	CGFloat totalHeight = 0;
	NSInteger numberOfColumns = CGRectGetWidth(self.collectionView.documentVisibleRect) / itemSize.width;
	
	for (NSUInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
		NSInteger headerHeight = [self.delegate collectionView:self.collectionView heightForHeaderInSection:section];
		NSInteger footerHeight = [self.delegate collectionView:self.collectionView heightForFooterInSection:section];
		
		JNWCollectionViewGridLayoutSection *sectionInfo = [[JNWCollectionViewGridLayoutSection alloc] initWithNumberOfItems:numberOfItems];
		sectionInfo.offset = totalHeight + headerHeight;
		sectionInfo.height = 0;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		
		for (NSInteger item = 0; item < numberOfItems; item++) {
			CGPoint origin = CGPointZero;
			// TODO: This does not provide padding
			origin.x = (item % numberOfColumns) * itemSize.width;
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

@end
