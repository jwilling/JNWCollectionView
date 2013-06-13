//
//  JNWCollectionViewReusableView.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// The base class for all supplementary views.
@interface JNWCollectionViewReusableView : NSView

// The dedicated initializer. Do not use the frame parameter for layout calculations
// as it will most likely be a zero rect.
- (instancetype)initWithFrame:(NSRect)frameRect;

// The reuse identifier.
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

// The reusable view kind. There can only be one kind of supplementary view in each section.
@property (nonatomic, copy, readonly) NSString *kind;

@end
