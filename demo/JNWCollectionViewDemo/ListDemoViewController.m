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

@interface ListDemoViewController ()
@property (nonatomic, strong) JNWCollectionView *collectionView;
@end

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
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const cellIdentifier = @"CELL";
	ListCell *cell = (ListCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [[ListCell alloc] initWithReuseIdentifier:cellIdentifier];
		cell.backgroundColor = [NSColor redColor];
	}
	
	cell.cellLabelText = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
	return cell;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section {
	static NSString * const identifier = @"HEADER";
	ListHeader *header = (ListHeader *)[collectionView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
	
	if (header == nil) {
		header = [[ListHeader alloc] initWithReuseIdentifier:identifier];
	}
	
	header.headerLabelText = [NSString stringWithFormat:@"Header %ld", section];
	return header;
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

@end
