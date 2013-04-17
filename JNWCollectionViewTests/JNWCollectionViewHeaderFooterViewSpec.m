//
//  JNWCollectionViewHeaderFooterViewSpec.m
//  JNWCollectionView
//
//  Created by Robert Widmann on 4/16/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

SpecBegin(JNWCollectionViewHeaderFooterView)

describe(@"-reuseIdentifier", ^{
	JNWCollectionViewHeaderFooterView *headerFooterView = [[JNWCollectionViewHeaderFooterView alloc]initWithReuseIdentifier:@"Identifier"];
	
	it(@"Should return the same reuse identifier it was initialized with", ^{
		expect(headerFooterView.reuseIdentifier).to.equal(@"Identifier");
	});
});

SpecEnd
