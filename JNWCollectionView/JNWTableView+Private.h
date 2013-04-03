//
//  JNWTableView_Private.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWTableView.h"

@class JNWTableViewCell;
@interface JNWTableView ()

- (void)mouseDownInTableViewCell:(JNWTableViewCell *)cell withEvent:(NSEvent *)event;

@end
