//
//  JNWCollectionViewSpec.m
//  JNWCollectionView
//
//  Created by Jonathan Willing on 4/17/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionViewDocumentView.h"

SpecBegin(JNWCollectionView)

describe(@"document view", ^{
	__block JNWCollectionView *collectionView = nil;
	
	beforeAll(^{
		collectionView = [[JNWCollectionView alloc] initWithFrame:CGRectZero];
	});
	
	it(@"should exist", ^{
		expect(collectionView.documentView).notTo.beNil();
	});
	
	it(@"should be of class JNWCollectionViewDocumentView", ^{
		expect(collectionView.documentView).to.beKindOf(JNWCollectionViewDocumentView.class);
	});
});

describe(@"data source", ^{
	
});

SpecEnd
