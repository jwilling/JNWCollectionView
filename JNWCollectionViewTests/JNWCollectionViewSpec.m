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

SpecEnd
