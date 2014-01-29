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
	layout.stickyHeaders = YES;
	layout.delegate = self;
	self.collectionView.collectionViewLayout = layout;
	
	[self.collectionView registerClass:ListCell.class forCellWithReuseIdentifier:cellIdentifier];
	[self.collectionView registerClass:ListHeader.class forSupplementaryViewOfKind:JNWCollectionViewListLayoutHeaderKind withReuseIdentifier:headerIdentifier];
	[self.collectionView registerClass:ListHeader.class forSupplementaryViewOfKind:JNWCollectionViewListLayoutFooterKind withReuseIdentifier:headerIdentifier];

	self.collectionView.animatesSelection = YES;
	
	[self.collectionView reloadData];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ListCell *cell = (ListCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.cellLabelText = [NSString stringWithFormat:@"%ld - %ld", indexPath.jnw_item, indexPath.jnw_section];
	return cell;
}

- (JNWCollectionViewReusableView *)collectionView:(JNWCollectionView *)collectionView viewForSupplementaryViewOfKind:(NSString *)kind inSection:(NSInteger)section {
	ListHeader *header = (ListHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifer:headerIdentifier];
	
	NSString* label = [kind isEqualToString:JNWCollectionViewListLayoutHeaderKind] ? @"Header": @"Footer";
	header.headerLabelText = [NSString stringWithFormat:@"%@ %ld", label,section];
	return header;
}


// Can be used in place of setting the collective height of the layout, as seen above in `-loadView`, if
// a variable-row height list view is wanted.

//- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 44.f;
//}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 3+section;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 200;
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index {
	return 24.f;
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index {
	return 24.f;
}

@end
