//
//  AppDelegate.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView/JNWCollectionView.h>
#import <JNWCollectionView/JNWCollectionViewGridLayout.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, JNWCollectionViewDelegate, JNWCollectionViewDataSource, JNWCollectionViewGridLayoutDelegate>

@property (nonatomic, weak) IBOutlet JNWCollectionView *collectionView;
@property (assign) IBOutlet NSWindow *window;

@end
