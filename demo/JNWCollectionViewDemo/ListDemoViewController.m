//
//  ListDemoViewController.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/12/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "ListDemoViewController.h"
#import "ListHeader.h"
#import "ListCell.h"
#import "ListMarker.h"

@interface ListDemoViewController ()
@property (nonatomic, strong) JNWCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *sections;
@end

static NSString * const cellIdentifier = @"CELL";
static NSString * const headerIdentifier = @"HEADER";

@implementation ListDemoViewController

- (id)init {
	return [super initWithNibName:nil bundle:nil];
}

- (void)loadView {
	self.view = [[NSView alloc] initWithFrame:CGRectZero];
	self.view.wantsLayer = YES;
	
	self.collectionView = [[JNWCollectionView alloc] initWithFrame:self.view.bounds];
	self.collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	self.collectionView.dataSource = self;
	[self.view addSubview:self.collectionView];
	
	JNWCollectionViewListLayout *layout = [[JNWCollectionViewListLayout alloc] initWithCollectionView:self.collectionView];
	layout.rowHeight = 44.f;
	layout.delegate = self;
	self.collectionView.collectionViewLayout = layout;
	
	[self.collectionView registerClass:ListCell.class forCellWithReuseIdentifier:cellIdentifier];
	[self.collectionView registerClass:ListHeader.class forSupplementaryViewOfKind:JNWCollectionViewListLayoutHeaderKind withReuseIdentifier:headerIdentifier];
	
	self.collectionView.animatesSelection = YES;
	
	_sections = [NSMutableArray array];
	for (NSUInteger section = 0; section < 5; ++section) {
		NSMutableArray *sectionArray = [NSMutableArray array];
		for (NSUInteger item = 0; item < 100; ++item) {
			[sectionArray addObject:@((section * 1000) + item)];
		}
		[_sections addObject:sectionArray];
	}
	
	[self.collectionView reloadData];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ListCell *cell = (ListCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSArray *sectionArray = [_sections objectAtIndex:indexPath.jnw_section];
	cell.cellLabelText = [[sectionArray objectAtIndex:indexPath.jnw_item] description];
	return cell;
}

- (NSView *)collectionView:(JNWCollectionView *)collectionView dropMarkerViewWithFrame:(NSRect)frame {
	frame.size.height += 1;
	frame.origin.y -= 1;
	return [[ListMarker alloc] initWithFrame:frame];
}

- (JNWCollectionViewReusableView *)collectionView:(JNWCollectionView *)collectionView viewForSupplementaryViewOfKind:(NSString *)kind inSection:(NSInteger)section {
	ListHeader *header = (ListHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifer:headerIdentifier];
	header.headerLabelText = [NSString stringWithFormat:@"Header %ld", section];
	return header;
}

// Can be used in place of setting the collective height of the layout, as seen above in `-loadView`, if
// a variable-row height list view is wanted.

//- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 44.f;
//}

- (id<NSPasteboardWriting>)collectionView:(JNWCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
	NSArray *sectionArray = [_sections objectAtIndex:indexPath.jnw_section];
	NSString *text = [[sectionArray objectAtIndex:indexPath.jnw_item] description];
	[pboardItem setString:text forType:NSPasteboardTypeString];
	return pboardItem;
}

- (NSArray *)draggedTypesForCollectionView:(JNWCollectionView *)collectionView
{
	return @[ NSStringPboardType ];
}

- (BOOL)collectionView:(JNWCollectionView *)collectionView performDragOperation:(id<NSDraggingInfo>)sender fromIndexPaths:(NSArray *)dragIndexPaths toIndexPath:(JNWCollectionViewDropIndexPath *)dropIndexPath
{
	NSMutableArray *toSectionArray = [_sections objectAtIndex:dropIndexPath.jnw_section];
	
	if (dragIndexPaths.count == 0) {
		// Drag from outside.
		NSString *text = [[sender draggingPasteboard] stringForType:NSStringPboardType];
		if (text) {
			[toSectionArray insertObject:text atIndex:dropIndexPath.jnw_item];
			[_collectionView reloadData];
			return YES;
		}
	} else {
		// Dragged a row.
		// TODO: This doesn't work correctly with multiple rows.
		for (NSIndexPath *fromPath in dragIndexPaths) {
			NSMutableArray *fromSectionArray = [_sections objectAtIndex:fromPath.jnw_section];
			if (fromSectionArray == toSectionArray) {
				// Move within a section.
				id object = [toSectionArray objectAtIndex:fromPath.jnw_item];
				if (fromPath.jnw_item < dropIndexPath.jnw_item) {
					[toSectionArray insertObject:object atIndex:dropIndexPath.jnw_item];
					[toSectionArray removeObjectAtIndex:fromPath.jnw_item];
				} else {
					[toSectionArray removeObjectAtIndex:fromPath.jnw_item];
					[toSectionArray insertObject:object atIndex:dropIndexPath.jnw_item];
				}
			} else {
				// Move between sections.
				id object = [fromSectionArray objectAtIndex:fromPath.jnw_item];
				[toSectionArray insertObject:object atIndex:dropIndexPath.jnw_item];
				[fromSectionArray removeObjectAtIndex:fromPath.jnw_item];
			}
		}
		[_collectionView reloadData];
		return YES;
	}
	
	return NO;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	NSArray *sectionArray = [_sections objectAtIndex:section];
	return [sectionArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return [_sections count];
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index {
	return 24.f;
}

@end
