//
//  JNWTableViewCell.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JNWCollectionViewCellBackgroundView, JNWCollectionView;
@interface JNWCollectionViewCell : NSView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)prepareForReuse;
//- (void)setSelected:(BOOL)selected;


@property (nonatomic, assign, readonly) JNWCollectionView *tableView;

@property (nonatomic, assign) BOOL selected;

// Convenience setters for common customizations.
@property (nonatomic, strong) NSImage *backgroundImage;
//@property (nonatomic, assign) CGSize contents

@property (nonatomic, strong) NSColor *backgroundColor;

@property (nonatomic, strong, readonly) NSView *content;
@property (nonatomic, strong, readonly) JNWCollectionViewCellBackgroundView *backgroundView;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;


@end
