//
//  JNWCollectionViewReusableView.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JNWCollectionViewReusableView : NSView

- (instancetype)initWithFrame:(NSRect)frameRect;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;
@property (nonatomic, copy, readonly) NSString *kind;

@end
