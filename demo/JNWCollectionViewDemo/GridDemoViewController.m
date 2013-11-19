//
//  GridDemoViewController.m
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/15/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>
#import "GridDemoViewController.h"
#import "GridCell.h"

@interface GridDemoViewController()

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic) NSUInteger freshInteger;

@end

static NSString * const identifier = @"CELL";

@implementation GridDemoViewController

- (id)init {
	return [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (void)awakeFromNib {
	JNWCollectionViewGridLayout *gridLayout = [[JNWCollectionViewGridLayout alloc] initWithCollectionView:self.collectionView];
	gridLayout.delegate = self;
	self.collectionView.collectionViewLayout = gridLayout;
	self.collectionView.dataSource = self;
	[self.collectionView registerClass:GridCell.class forCellWithReuseIdentifier:identifier];
	self.collectionView.animatesSelection = NO; // (this is the default option)

    NSMutableArray* items = [NSMutableArray array];
    for(NSUInteger i = 0; i < 10; i++) {
        [items addObject:[self freshItem]];
    }
    self.items = items;

    [self.collectionView reloadData];
}

- (id)freshItem
{
    return @{
            @"text": [@(self.freshInteger++) description],
            @"image": self.generateImage
    };
}

#pragma mark Data source

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary* item = self.items[indexPath.jnw_item];
	cell.labelText = [item[@"text"] stringByAppendingString:[@(arc4random()) description]];
	cell.image = item[@"image"];
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView {
	return 1;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView {
	return CGSizeMake(150.f, 150.f);
}


- (NSImage*)generateImage
{
// Just get a randomly-tinted template image.
    NSImage *image = [NSImage imageWithSize:CGSizeMake(150.f, 150.f) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			[[NSImage imageNamed:NSImageNameUser] drawInRect:dstRect fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1];

			CGFloat hue = arc4random() % 256 / 256.0;
			CGFloat saturation = arc4random() % 128 / 256.0 + 0.5;
			CGFloat brightness = arc4random() % 128 / 256.0 + 0.5;
			NSColor *color = [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:1];

			[color set];
			NSRectFillUsingOperation(dstRect, NSCompositeDestinationAtop);

			return YES;
		}];
    return image;
}

- (IBAction)addItem:(id)sender {
    [self.items insertObject:self.freshItem atIndex:1];
    [self.items insertObject:self.freshItem atIndex:6];
    NSIndexPath* indexPath = [NSIndexPath jnw_indexPathForItem:5 inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath, [NSIndexPath jnw_indexPathForItem:1 inSection:0]]];
}

- (IBAction)deleteItem:(id)sender {
    [self.items insertObject:self.freshItem atIndex:5];
    [self.items insertObject:self.freshItem atIndex:6];
    [self.items removeObjectAtIndex:2];
    NSIndexPath* path = [NSIndexPath jnw_indexPathForItem:5 inSection:0];
    NSIndexPath* secondPath = [NSIndexPath jnw_indexPathForItem:6 inSection:0];
    NSIndexPath* otherPath = [NSIndexPath jnw_indexPathForItem:2 inSection:0];
    [self.collectionView performBatchUpdates:^{

        [self.collectionView insertItemsAtIndexPaths:@[path, secondPath]];
        [self.collectionView deleteItemsAtIndexPaths:@[otherPath]];
    } completion:^(BOOL completed) {
        NSLog(@"completed");
    }];
}

@end
