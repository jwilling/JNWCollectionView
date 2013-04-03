//
//  AppDelegate.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView/JNWTableView.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, JNWTableViewDelegate, JNWTableViewDataSource>

@property (nonatomic, weak) IBOutlet JNWTableView *tableView;
@property (assign) IBOutlet NSWindow *window;

@end
