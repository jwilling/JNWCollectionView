//
//  DemoWindowController.h
//  JNWCollectionViewDemo
//
//  Created by Jonathan Willing on 4/12/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DemoWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet NSBox *containerBox;

- (IBAction)selectLayout:(id)sender;

@end
