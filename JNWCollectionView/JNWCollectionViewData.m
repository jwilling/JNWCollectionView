//
//  JNWCollectionViewData.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 5/18/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewData.h"
#import "JNWCollectionView+Private.h"
#import "JNWCollectionView.h"

@interface JNWCollectionViewData()
@property (nonatomic, weak) JNWCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *sectionData;
@end

@implementation JNWCollectionViewSection

@end

@implementation JNWCollectionViewData

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView {
	self = [super init];
	if (self == nil) return nil;
	self.collectionView = collectionView;
	self.sectionData = [NSMutableArray array];
	return self;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	if (self.sections.count < section)
		return 0;
	return [self.sections[section] numberOfItems];
}

- (NSArray *)sections {
	return self.sectionData.copy;
}

- (void)recalculate {
	JNWCollectionViewLayout *layout = self.collectionView.collectionViewLayout;
	NSAssert(layout != nil, @"layout cannot be nil.");
	
	[self.sectionData removeAllObjects];
	
	// Find how many sections we have in the collection view.
	// We default to 1 if the data source doesn't implement the optional method.
	self.numberOfSections = 1;
	if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)])
		self.numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
	
	// Run through with empty sections and fill in the numbef of items in each, so that
	// the layouts can query the collection view and get correct values for the number of items
	// in each section.
	for (NSInteger sectionIdx = 0; sectionIdx < self.numberOfSections; sectionIdx++) {
		JNWCollectionViewSection *section = [[JNWCollectionViewSection alloc] init];
		section.index = sectionIdx;
		section.numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIdx];
		[self.sectionData addObject:section];
	}
	
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	[layout prepareLayout];
	NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate] - start;
	NSLog(@"layout time: %f", end);
	
	for (NSInteger sectionIdx = 0; sectionIdx < self.numberOfSections; sectionIdx++) {
		JNWCollectionViewSection *section = self.sections[sectionIdx];
		
		// We're running through all of the items just to find the total size of each section.
		// Although this might seem like a waste, remember that this is only performed each time the
		// collection view is reloaded. The benefits of knowing what area the section encompasses
		// far outweight the cost of effectively running a double-iteration over the data.
		// Additionally, the total size of all of the sections is needed so that we can figure out
		// how large the document view of the collection view needs to be.
		//
		// However, this wastage can be avoided if the collection view layout implements the optional
		// method, -rectForSectionAtIndex: and returns yes in -wantsRectForSectionAtIndex, which allows
		// us to bypass this entire section iteration and increase the speed of the layout reloading.
		
		if (layout.wantsRectForSectionAtIndex) {
			section.frame = [layout rectForSectionAtIndex:sectionIdx];
			continue;
		}
		
		CGRect sectionFrame = CGRectNull;
		for (NSInteger itemIdx = 0; itemIdx < section.numberOfItems; itemIdx++) {
			NSIndexPath *indexPath = [NSIndexPath jnw_indexPathForItem:itemIdx inSection:sectionIdx];
			JNWCollectionViewLayoutAttributes *attributes = [layout layoutAttributesForItemAtIndexPath:indexPath];
			
			sectionFrame = CGRectUnion(sectionFrame, attributes.frame);
		}
		
		for (NSString *identifier in [self.collectionView allSupplementaryViewIdentifiers]) {
			NSString *kind = [self.collectionView kindForSupplementaryViewIdentifier:identifier];
			JNWCollectionViewLayoutAttributes *attributes = [layout layoutAttributesForSupplementaryItemInSection:sectionIdx kind:kind];
			sectionFrame = CGRectUnion(sectionFrame, attributes.frame);
		}
		
		section.frame = sectionFrame;
	}
}

@end
