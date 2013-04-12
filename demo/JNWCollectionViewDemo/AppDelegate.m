//
//  AppDelegate.m
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "AppDelegate.h"
#import "TableViewCell.h"
#import "TableViewHeader.h"

@implementation AppDelegate

- (void)awakeFromNib {
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.collectionView.collectionViewLayout = [[JNWCollectionViewGridLayout alloc] initWithCollectionView:self.collectionView];
	
	[self.collectionView reloadData];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const identifier = @"CELL";
	TableViewCell *cell = (TableViewCell *)[collectionView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[TableViewCell alloc] initWithReuseIdentifier:identifier];
	}

	char cString[20];
	sprintf(cString, "%ld", (long)indexPath.item);
	cell.cellLabelText = [[NSString alloc] initWithCString:cString encoding:NSUTF8StringEncoding];
	
	return cell;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section {
	static NSString * const identifier = @"HEADER";
	TableViewHeader *header = (TableViewHeader *)[collectionView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
	
	if (header == nil) {
		header = [[TableViewHeader alloc] initWithReuseIdentifier:identifier];
	}
	
	header.headerLabelText = [NSString stringWithFormat:@"Header %ld", section];
	
	return header;
}


- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 500;
}

-  (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)tableView {
	return 3;
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

//- (CGSize)collectionView:(JNWCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//	return CGSizeMake(129.f, 129.f);
//}

- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView {
	return CGSizeMake(128.f, 128.f);
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)section {
	return 24.f;
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)section {
	return 0.f;
}

@end
