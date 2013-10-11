//
//  GridDemoViewController.h
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/15/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView/JNWCollectionView.h>

@interface GridDemoViewController : NSViewController <JNWCollectionViewDataSource, JNWCollectionViewGridLayoutDelegate>

@property (nonatomic, weak) IBOutlet JNWCollectionView *collectionView;

@end
