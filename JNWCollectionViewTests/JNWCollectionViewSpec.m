//
//  JNWCollectionViewSpec.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/17/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

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
	
	it(@"should use the correct number of rows in each section", ^{
		expect([collectionView numberOfItemsInSection:1]).to.equal(kTestDataSourceNumberOfItems);
	});
	
	it(@"should not be using nil cells", ^{
		expect([collectionView cellForRowAtIndexPath:[NSIndexPath jnw_indexPathForItem:0 inSection:0]]).notTo.beNil();
	});
	
	it(@"should use the cell created in collectionView:cellForItemAtIndexPath:", ^{
		JNWCollectionViewCell *cell = [collectionView cellForRowAtIndexPath:[NSIndexPath jnw_indexPathForItem:0 inSection:0]];
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
		JNWCollectionViewCell *cell = [collectionView cellForRowAtIndexPath:toSelect];
		expect(cell).notTo.beNil();
		expect(cell.selected).to.beTruthy();
	});
});

SpecEnd
