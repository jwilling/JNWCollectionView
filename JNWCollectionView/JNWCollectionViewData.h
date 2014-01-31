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

#import <Foundation/Foundation.h>

@class JNWCollectionView;

/// This class holds information about the state of the items (not cells) in the collection view.
/// It is not exposed publicly.
@interface JNWCollectionViewSection : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger numberOfItems;
@end

@interface JNWCollectionViewData : NSObject

- (instancetype)initWithCollectionView:(JNWCollectionView *)collectionView;

/// Recalculates the local section cache from the layout and data source, optionally
/// re-preparing the layout.
- (void)recalculateAndPrepareLayout:(BOOL)prepareLayout;

-(NSUInteger)indexOfSectionForPoint:(CGPoint)point;

-(NSIndexSet*)indexesOfSectionsInRect:(CGRect)rect;

@property (nonatomic, assign) NSInteger numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/// Contains all of the sections cached from the last -recalculate call.
@property (nonatomic, strong, readonly) NSArray *sections;

/// The size that contains all of the sections. This size is used to determine
/// the content size of the scroll view.
@property (nonatomic, assign) CGSize encompassingSize;

@end
