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

@interface ListDemoViewController () <NSPasteboardWriting>
@property (nonatomic, strong) JNWCollectionView *collectionView;
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
	[self.collectionView registerClass:ListHeader.class forSupplementaryViewOfKind:JNWCollectionViewListLayoutHeaderIdentifier withReuseIdentifier:headerIdentifier];
	
	self.collectionView.animatesSelection = YES;
	
	[self.collectionView reloadData];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ListCell *cell = (ListCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.cellLabelText = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
	return cell;
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

- (id<NSPasteboardWriting>)collectionView:(JNWCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)index {
	return self;
}

// Asks the data source to write the cells that are being dragged to the pasteboard.
- (BOOL)collectionView:(JNWCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard {
	return YES;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 300;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 5;
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index {
	return 24.f;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
	return @[ NSPasteboardTypeString ];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
	return [type dataUsingEncoding:NSUTF8StringEncoding];
}

@end
