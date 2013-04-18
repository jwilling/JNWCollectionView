//
//  JNWTestObject.m
//  JNWCollectionView
//
//  Created by Robert Widmann on 4/17/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTestObject.h"

@implementation JNWTestObject

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 0;
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 0;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section {
	return nil;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForFooterInSection:(NSInteger)section {
	return nil;
}

@end

@implementation JNWDatasourceTestObject

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 1;
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const identifier = @"Identifier";
	JNWCollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:identifier];
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 1;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForHeaderInSection:(NSInteger)section {
	return nil;
}

- (JNWCollectionViewHeaderFooterView *)collectionView:(JNWCollectionView *)collectionView viewForFooterInSection:(NSInteger)section {
	return nil;
}

@end
