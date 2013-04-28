//
//  JNWTestImplementation.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/27/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTestImplementation.h"

NSInteger const kTestDataSourceNumberOfItems = 20;
NSInteger const kTestDataSourceNumberOfSections = 3;
NSString * const kTestDataSourceCellIdentifier = @"cell";

@implementation JNWTestDataSource

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return kTestDataSourceNumberOfItems;
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:kTestDataSourceCellIdentifier];
	if (cell == nil) {
		cell = [[JNWCollectionViewCell alloc] initWithReuseIdentifier:kTestDataSourceCellIdentifier];
	}
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return kTestDataSourceNumberOfSections;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section {
	static NSString * const identifier = @"header";
	JNWCollectionViewHeaderFooterView *header = [collectionView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
	if (header == nil) {
		header = [[JNWCollectionViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
	}
	return header;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForFooterInSection:(NSInteger)section {
	static NSString * const identifier = @"footer";
	JNWCollectionViewHeaderFooterView *footer = [collectionView dequeueReusableHeaderFooterViewWithIdentifer:identifier];
	if (footer == nil) {
		footer = [[JNWCollectionViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
	}
	return footer;
}

@end

@implementation JNWTestDelegate



@end

@implementation JNWTestListLayoutDelegate



@end

@implementation JNWTestGridLayoutDelegate



@end