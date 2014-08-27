
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
