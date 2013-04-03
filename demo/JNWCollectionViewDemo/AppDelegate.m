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
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self.tableView reloadData];
}

- (JNWCollectionViewCell *)tableView:(JNWCollectionView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const identifier = @"CELL";
	TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[TableViewCell alloc] initWithReuseIdentifier:identifier];
	}

	cell.cellLabelText = [NSString stringWithFormat:@"%ld", indexPath.row];
	
	return cell;
}

- (JNWCollectionViewHeaderFooterView *)tableView:(JNWCollectionView *)tableView viewForHeaderInSection:(NSInteger)section {
	static NSString * const identifier = @"HEADER";
	TableViewHeader *header = (TableViewHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
	
	if (header == nil) {
		header = [[TableViewHeader alloc] initWithReuseIdentifier:identifier];
	}
	
	header.headerLabelText = [NSString stringWithFormat:@"Header %ld", section];
	
	return header;
}

//- (JNWTableViewHeaderFooterView *)tableView:(JNWTableView *)tableView viewForFooterInSection:(NSInteger)section {
//	static NSString * const identifier = @"FOOTER";
//	TableViewHeader *footer = (TableViewHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
//	
//	if (footer == nil) {
//		footer = [[TableViewHeader alloc] initWithReuseIdentifier:identifier];
//	}
//	
//	footer.headerLabelText = [NSString stringWithFormat:@"Footer %ld", section];
//	
//	return footer;
//}

- (CGFloat)tableView:(JNWCollectionView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

- (NSUInteger)tableView:(JNWCollectionView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 100;
}

-  (NSInteger)numberOfSectionsInTableView:(JNWCollectionView *)tableView {
	return 8;
}

- (CGFloat)tableView:(JNWCollectionView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.f;
}

//- (CGFloat)tableView:(JNWTableView *)tableView heightForFooterInSection:(NSInteger)section {
//	return 24.f;
//}

@end
