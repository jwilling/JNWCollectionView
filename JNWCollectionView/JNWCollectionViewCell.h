//
//  JNWCollectionViewCell.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JNWCollectionView;
@interface JNWCollectionViewCell : NSView

// The dedicated initializer for all subclasses to override.
- (instancetype)initWithFrame:(NSRect)frameRect;

// Called when the cell is about to exit the reuse pool and be dequeued.
- (void)prepareForReuse;

@property (nonatomic, weak, readonly) JNWCollectionView *collectionView;

@property (nonatomic, assign) BOOL selected;

// Any content added to the cell should be added as a subview of
// the content view. The content view is guaranteed to be in front
// of the background color or image.
@property (nonatomic, strong, readonly) NSView *contentView;

// Sets the background image or background color on a dedicated
// background view that is always beneath the content view.
//
// If both are set, the image takes precedence over the color.
@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSColor *backgroundColor;

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;

@end
