//
//  JNWCollectionViewHeaderFooterViewSpec.m
//  JNWCollectionView
//
//  Created by Robert Widmann on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

SpecBegin(JNWCollectionViewHeaderFooterView)

describe(@"-reuseIdentifier", ^{
	__block JNWCollectionViewReusableView *headerFooterView = nil;
	__block NSString *identifier = @"identifier";
	
	beforeAll(^{
		headerFooterView = [[JNWCollectionViewReusableView alloc] initWithReuseIdentifier:identifier];
	});
	
	it(@"should exist", ^{
		expect(headerFooterView).notTo.beNil();
	});
	
	it(@"should return the same reuse identifier it was initialized with", ^{
		expect(headerFooterView.reuseIdentifier).to.equal(identifier);
	});
});

SpecEnd
