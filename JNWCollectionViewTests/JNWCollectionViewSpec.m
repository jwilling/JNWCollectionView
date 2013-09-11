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

#import "JNWCollectionViewDocumentView.h"
#import "JNWTestImplementation.h"

SpecBegin(JNWCollectionView)

describe(@"documentView property", ^{
	__block JNWCollectionView *collectionView = nil;
	
	beforeEach(^{
		collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectZero];
	});
	
	it(@"should be of class JNWCollectionViewDocumentView", ^{
		expect(collectionView.documentView).to.beKindOf(JNWCollectionViewDocumentView.class);
	});
});

describe(@"data source", ^{
	__block JNWCollectionView *collectionView = nil;
	__block JNWCollectionViewLayout *collectionViewLayout = nil;
	__block JNWTestDataSource *testDataSource = nil;
		
	beforeAll(^{
		collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
		collectionViewLayout = [[JNWCollectionViewLayout alloc] initWithCollectionView:collectionView];
		collectionView.collectionViewLayout = collectionViewLayout;
		testDataSource = [[JNWTestDataSource alloc] init];
		collectionView.dataSource = testDataSource;
		
		[collectionView registerClass:JNWCollectionViewCell.class forCellWithReuseIdentifier:kTestDataSourceCellIdentifier];
		
		[collectionView reloadData];
	});
	
	it(@"should not throw an exception with a valid datasource", ^{
		expect(^{
			collectionView.dataSource = testDataSource;
		}).notTo.raise(@"NSInternalInconsistencyException");
	});
	
	it(@"should use the correct number of sections", ^{
		expect(collectionView.numberOfSections).to.equal(kTestDataSourceNumberOfSections);
	});
	
	it(@"should use the correct number of items in each section", ^{
		expect([collectionView numberOfItemsInSection:1]).to.equal(kTestDataSourceNumberOfItems);
	});
	
	it(@"should not be using nil cells", ^{
		expect([collectionView cellForItemAtIndexPath:[NSIndexPath jnw_indexPathForItem:0 inSection:0]]).notTo.beNil();
	});
	
	it(@"should use the cell created in collectionView:cellForItemAtIndexPath:", ^{
		JNWCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath jnw_indexPathForItem:0 inSection:0]];
		expect(cell.reuseIdentifier).to.equal(kTestDataSourceCellIdentifier);
	});
});

describe(@"-selectItemAtIndexPath:atScrollPosition:animated:", ^{
	__block JNWCollectionView *collectionView = nil;
	__block JNWCollectionViewLayout *collectionViewLayout = nil;
	__block JNWTestDataSource *dataSource = nil;
	
	beforeAll(^{
		collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
		collectionViewLayout = [[JNWCollectionViewLayout alloc] initWithCollectionView:collectionView];
		collectionView.collectionViewLayout = collectionViewLayout;
		dataSource = [[JNWTestDataSource alloc] init];
		collectionView.dataSource = dataSource;
		[collectionView reloadData];
	});
	
	beforeEach(^{
		[collectionView deselectAllItems];
	});
	
	it(@"should add the correct index path to the selection array", ^{
		NSIndexPath *expected = [NSIndexPath jnw_indexPathForItem:1 inSection:0];
		NSIndexPath *wrong = [NSIndexPath jnw_indexPathForItem:0 inSection:0];
		[collectionView selectItemAtIndexPath:expected atScrollPosition:JNWCollectionViewScrollPositionNone animated:NO];
		expect([collectionView indexPathsForSelectedItems][0]).to.equal(expected);
		expect([collectionView indexPathsForSelectedItems][0]).notTo.equal(wrong);
	});
	
	it(@"should select the cell", ^{
		NSIndexPath *toSelect = [NSIndexPath jnw_indexPathForItem:1 inSection:0];
		[collectionView selectItemAtIndexPath:toSelect atScrollPosition:JNWCollectionViewScrollPositionNone animated:NO];
		JNWCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:toSelect];
		expect(cell).notTo.beNil();
		expect(cell.selected).to.beTruthy();
	});
});

SpecEnd
