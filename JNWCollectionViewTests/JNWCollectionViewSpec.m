//
//  JNWCollectionViewSpec.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/17/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewDocumentView.h"
#import "JNWTestObject.h"

SpecBegin(JNWCollectionView)

__block JNWCollectionView *collectionView = nil;
__block JNWDatasourceTestObject *validDataSource = nil;

beforeEach(^{
	collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectZero];
	
});

describe(@"documentView property", ^{
	it(@"should be of class JNWCollectionViewDocumentView", ^{
		expect(collectionView.documentView).to.beKindOf(JNWCollectionViewDocumentView.class);
	});
});

describe(@"data source", ^{
	beforeAll(^{
		validDataSource = [[JNWDatasourceTestObject alloc] init];
	});
	
	it(@"should have a nil datasource", ^{
		expect(collectionView.dataSource).to.beNil();
	});
	
	it(@"should not throw an exception with a valid datasource", ^{
		expect(^{
			collectionView.dataSource = validDataSource;
		}).notTo.raise(@"NSInternalInconsistencyException");
	});
});

describe(@"selection", ^{
	__block JNWCollectionView *collectionView = nil;
	
	beforeAll(^{
		collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
	});
	
	it(@"should select and return the same selection", ^{
		NSIndexPath *expected = [NSIndexPath jnw_indexPathForItem:1 inSection:0];
		NSIndexPath *wrong = [NSIndexPath jnw_indexPathForItem:0 inSection:0];
		[collectionView selectItemAtIndexPath:expected atScrollPosition:JNWCollectionViewScrollPositionNone animated:NO];
		expect([collectionView indexPathsForSelectedItems][0]).to.equal(expected);
		expect([collectionView indexPathsForSelectedItems][0]).notTo.equal(wrong);
	});
});

SpecEnd
