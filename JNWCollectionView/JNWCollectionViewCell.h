//
//  JNWCollectionViewCell.h
//  JNWCollectionView
//
//  Created by Jonathan Willing on 3/23/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// This view is the base class for all cells. The properties can be set directly on this
// class for customization, or it can be subclassed to provide custom drawing.
@class JNWCollectionView;
@interface JNWCollectionViewCell : NSView

// The dedicated initializer for all subclasses to override.
- (instancetype)initWithFrame:(NSRect)frameRect;

// Called when the cell is about to exit the reuse pool and be dequeued.
//
// Subclasses should call super's implementation.
- (void)prepareForReuse;

@property (nonatomic, weak, readonly) JNWCollectionView *collectionView;

// Sets the selection with no animation. Subclassers should override this method to add side
// effects to the selection process.
@property (nonatomic, assign) BOOL selected;

// Calls -setSelected:, animating any changes to the content of the background view, such as
// settting the background iamge or color.
- (void)setSelected:(BOOL)selected animated:(BOOL)animate;

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

// Determines the duration of the crossfade effect applied to the backgroundImage
// and backgroundColor properties when the animatesSelection property on the collection
// view is set to YES.
//
// Defaults to 0.25.
@property (nonatomic, assign) CGFloat crossfadeDuration;

// The current reuse identifier used by the collection view to reuse the cell.
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

// The current index path.
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;

@end
