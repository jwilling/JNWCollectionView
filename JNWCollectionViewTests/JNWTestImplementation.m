/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

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