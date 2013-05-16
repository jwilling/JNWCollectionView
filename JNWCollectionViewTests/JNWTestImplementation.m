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
NSString * const kTestDataSourceHeaderIdentifier = @"header";
NSString * const kTestDataSourceFooterIdentifier = @"footer";


@implementation JNWTestDataSource

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return kTestDataSourceNumberOfItems;
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	JNWCollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:kTestDataSourceCellIdentifier];
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return kTestDataSourceNumberOfSections;
}

- (JNWCollectionViewReusableView *)collectionView:(JNWCollectionView *)collectionView viewForSupplementaryViewOfKind:(NSString *)kind inSection:(NSInteger)section {
	if ([kind isEqualToString:JNWCollectionViewListLayoutHeaderIdentifier]) {
		JNWCollectionViewReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifer:kTestDataSourceHeaderIdentifier];
		return header;
	} else {
		JNWCollectionViewReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifer:kTestDataSourceFooterIdentifier];
		return footer;
	}
}

@end

@implementation JNWTestDelegate



@end

@implementation JNWTestListLayoutDelegate



@end

@implementation JNWTestGridLayoutDelegate



@end