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

@interface JNWCollectionViewListLayoutSection : NSObject
- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows;
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
	if (_rowInfo != NULL)
		free(_rowInfo);
}

@end

@interface JNWCollectionViewListLayout()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) id<JNWCollectionViewListLayoutDelegate> delegate;
@end

@implementation JNWCollectionViewListLayout

- (NSMutableArray *)sections {
	if (_sections == nil) {
		_sections = [NSMutableArray array];
	}
	return _sections;
}

- (void)prepareLayout {
	[self.sections removeAllObjects];
	
	if (![self.collectionView.delegate conformsToProtocol:@protocol(JNWCollectionViewListLayoutDelegate)]) {
		NSLog(@"delegate does not conform to JNWCollectionViewListLayoutDelegate!");
	}	
	self.delegate = (id<JNWCollectionViewListLayoutDelegate>)self.collectionView.delegate;
	
	NSUInteger numberOfSections = [self.collectionView numberOfSections];
	CGFloat totalHeight = 0;
	
	for (NSUInteger section = 0; section < numberOfSections; section++) {
		NSInteger numberOfRows = [self.collectionView numberOfItemsInSection:section];
		NSInteger headerHeight = [self.delegate collectionView:self.collectionView heightForHeaderInSection:section];
		NSInteger footerHeight = [self.delegate collectionView:self.collectionView heightForFooterInSection:section];
		
		JNWCollectionViewListLayoutSection *sectionInfo = [[JNWCollectionViewListLayoutSection alloc] initWithNumberOfRows:numberOfRows];
		sectionInfo.offset = totalHeight + headerHeight;
		sectionInfo.height = 0;
		sectionInfo.headerHeight = headerHeight;
		sectionInfo.footerHeight = footerHeight;
		
		for (NSInteger row = 0; row < numberOfRows; row++) {
			CGFloat rowHeight = 0;
			// TODO: See if delegate responds to the height
			NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForItem:row inSection:section];
			rowHeight = [self.delegate collectionView:self.collectionView heightForItemAtIndexPath:indexPath];
			
			sectionInfo.rowInfo[row].height = rowHeight;
			sectionInfo.rowInfo[row].yOffset = sectionInfo.height;
			sectionInfo.height += rowHeight;
		}
		
		totalHeight += sectionInfo.height + footerHeight + headerHeight;
		[self.sections addObject:sectionInfo];
	}
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewListLayoutSection *section = self.sections[indexPath.section];
	CGFloat offset = section.offset + section.rowInfo[indexPath.item].yOffset;
	CGFloat width = CGRectGetWidth(self.collectionView.documentVisibleRect);
	CGFloat height = section.rowInfo[indexPath.item].height;
	return CGRectMake(0, offset, width, height);
}

- (CGRect)rectForHeaderAtIndex:(NSInteger)index {
	JNWCollectionViewListLayoutSection *section = self.sections[index];
	CGFloat width = CGRectGetWidth(self.collectionView.documentVisibleRect);
	return CGRectMake(0, section.offset - section.headerHeight, width, section.headerHeight);
}

- (CGRect)rectForFooterAtIndex:(NSInteger)index {
	JNWCollectionViewListLayoutSection *section = self.sections[index];
	CGFloat width = CGRectGetWidth(self.collectionView.documentVisibleRect);
	return CGRectMake(0, section.offset + section.height, width, section.footerHeight);
}

@end
