//
//  GridDemoViewController.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/15/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "GridDemoViewController.h"
#import "GridCell.h"

static NSString * const identifier = @"CELL";

@implementation GridDemoViewController

- (id)init {
	return [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (void)awakeFromNib {
	JNWCollectionViewGridLayout *gridLayout = [[JNWCollectionViewGridLayout alloc] initWithCollectionView:self.collectionView];
	gridLayout.delegate = self;
	self.collectionView.collectionViewLayout = gridLayout;
	self.collectionView.dataSource = self;
	[self.collectionView registerClass:GridCell.class forCellWithReuseIdentifier:@"CELL"];
	
	[self.collectionView reloadData];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithIdentifier:identifier];
	cell.labelText = [NSString stringWithFormat:@"%ld",indexPath.item];
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 5;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 500;
}

- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView {
	return CGSizeMake(128.f, 128.f);
}

- (id<NSPasteboardWriting>)collectionView:(JNWCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)index {
	if (self.collectionView.indexPathsForSelectedItems.count == 0) return nil;
	NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
	NSString *text = [(GridCell *)[self.collectionView cellForRowAtIndexPath:index] labelText];
	[pboardItem setString:text forType:(__bridge NSString *)kUTTypeUTF8PlainText];
	return pboardItem;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
	return @[ NSPasteboardTypeString ];
}

@end
