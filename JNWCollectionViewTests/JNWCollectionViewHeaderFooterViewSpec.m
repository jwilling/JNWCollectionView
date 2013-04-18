//
//  JNWCollectionViewHeaderFooterViewSpec.m
//  JNWCollectionView
//
//  Created by Robert Widmann on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

SpecBegin(JNWCollectionViewHeaderFooterView)

__block JNWCollectionViewHeaderFooterView *headerFooterView = nil;

describe(@"-reuseIdentifier", ^{
	beforeAll(^{
		headerFooterView = [[JNWCollectionViewHeaderFooterView alloc] initWithReuseIdentifier:@"Identifier"];
	});
	
	it(@"should exist", ^{
		expect(headerFooterView).notTo.beNil();
	});
	
	it(@"should return the same reuse identifier it was initialized with", ^{
		expect(headerFooterView.reuseIdentifier).to.equal(@"Identifier");
	});
});

SpecEnd
