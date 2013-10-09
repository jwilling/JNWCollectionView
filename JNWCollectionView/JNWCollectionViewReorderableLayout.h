/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#import <JNWCollectionView/JNWCollectionViewLayout.h>

typedef NS_ENUM(NSInteger, JNWReorderingType) {
	JNWReorderingTypeDisplacement,
	JNWReorderingTypeMarker
};

@interface JNWCollectionViewReorderableLayout : JNWCollectionViewLayout

// Determines how the layout should handle reordering.
//
// Reordering by displacement (JNWReorderingTypeDisplacement) occurs by
// determining which cell is closest to the item that is being dragged
// within the bounds of the collection view, and swapping its position
// with that of the nearby item.
//
// Reordering by marker (JNWReorderingTypeMarker) occurs by drawing a
// marker to indicate the proposed drop position. The position of the marker
// is determined by the frame returned from -markerRect.
//
// Defaults to JNWReorderingTypeDisplacement.
@property (nonatomic, assign) JNWReorderingType reorderingType;

// The rect in which the drop marker should be placed. This is only utilized
// if the reorderingType is JNWReorderingTypeMarker.
//
// Specified relative the scroll view, not the visible frame.
//
// Defaults to CGRectZero.
- (CGRect)markerRect;

// The fill color of the marker.
- (NSColor *)markerColor;

@end
