//
//  BindingsViewController.m
//  JNWCollectionViewDemo
//
//  Created by Deadpikle on 8/4/16.
//  Copyright © 2016 AppJon. All rights reserved.
//
//  http://www.tomdalling.com/blog/cocoa/implementing-your-own-cocoa-bindings/

#import "BindingsViewController.h"

#import <JNWCollectionView/JNWCollectionView.h>
#import "Person.h"
#import "PersonCell.h"

@interface BindingsViewController () <JNWCollectionViewDelegate, JNWCollectionViewDataSource>

@property (nonatomic, weak) IBOutlet JNWCollectionView *collectionView;

@property NSMutableArray<Person*> *listData;

@property NSString *test;

@property Person *p;

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
    self.test = @"Magic!";
    self.p = [[Person alloc] initWithName:@"Cow"];
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
    //[self.collectionView registerClass:ListCell.class forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.animatesSelection = YES;
    
    [self.collectionView reloadData];
    self.listData[5].name = @"Binding update!";
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 300;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
    return 1;
}

- (JNWCollectionViewCell*)collectionView:(JNWCollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
 //   cell.dataLabel.stringValue = [NSString stringWithFormat:@"%ld - %ld", indexPath.jnw_item, indexPath.jnw_section];
    //cell.objectValue = self.listData[indexPath.jnw_item];
    return cell;
}

- (id)collectionView:(JNWCollectionView *)collectionView objectValueForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.jnw_item >= 0 && self.listData.count > indexPath.jnw_item) {
        return self.listData[indexPath.jnw_item];
    }
    return nil;
}

-(id)selection {
    NSLog(@"HI");
    return nil;
}

@end
