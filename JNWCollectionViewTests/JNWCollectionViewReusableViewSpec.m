//
//  JNWCollectionViewReusableViewSpec.m
//  JNWCollectionView
//
//  Created by Robert Widmann on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

SpecBegin(JNWCollectionViewReusableView)

describe(@"-reuseIdentifier", ^{
	__block JNWCollectionViewReusableView *reusableView = nil;
	
	beforeAll(^{
		reusableView = [[JNWCollectionViewReusableView alloc] initWithFrame:CGRectZero];
	});
	
	it(@"should exist", ^{
		expect(reusableView).notTo.beNil();
	});
});

SpecEnd
