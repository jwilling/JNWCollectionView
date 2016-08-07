//
//  BindingsViewController.m
//  JNWCollectionViewDemo
//
//  Created by Deadpikle on 8/4/16.
//  Copyright © 2016 AppJon. All rights reserved.
//

#import "BindingsViewController.h"

#import <JNWCollectionView/JNWCollectionView.h>
#import "Person.h"
#import "PersonCell.h"

@interface BindingsViewController () <JNWCollectionViewDelegate, JNWCollectionViewDataSource>

@property (nonatomic, weak) IBOutlet JNWCollectionView *collectionView;

@property NSMutableArray<Person*> *listData;

@end

static NSString * const cellIdentifier = @"PersonCellID";

@implementation BindingsViewController

- (id)init {
	return [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)awakeFromNib {
	// Initialize data for binding
	self.listData = [NSMutableArray array];
	NSUInteger numItems = [self collectionView:self.collectionView numberOfItemsInSection:1];
	for (NSUInteger i = 0; i < numItems; i++) {
		[self.listData addObject:[[Person alloc] initWithName:[NSString stringWithFormat:@"Person #%ld", i + 1]]];
	}

	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	JNWCollectionViewListLayout *layout = [[JNWCollectionViewListLayout alloc] init];
	layout.rowHeight = 44.f;
	self.collectionView.collectionViewLayout = layout;

	[self.collectionView registerNib:[[NSNib alloc] initWithNibNamed:@"PersonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellIdentifier];
	self.collectionView.animatesSelection = YES;

	[self.collectionView reloadData];
	self.listData[5].name = @"Updated via binding! (Person #6)";
	[self performSelector:@selector(updateAfterTime) withObject:nil afterDelay:2];
}

-(void)updateAfterTime {
	self.listData[0].name = @"Updated after 2 seconds! (Person #1)";
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 300;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 1;
}

- (JNWCollectionViewCell*)collectionView:(JNWCollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
	return cell;
}

- (id)collectionView:(JNWCollectionView *)collectionView objectValueForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.jnw_item >= 0 && self.listData.count > indexPath.jnw_item) {
		return self.listData[indexPath.jnw_item];
	}
	return nil;
}

@end
