//
//  JNWTableViewHeaderFooterView.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JNWCollectionViewHeaderFooterView : NSView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

@end
