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

#import <JNWCollectionView/JNWCollectionViewReorderableLayout.h>

// The supplementary view kind identifiers used for the header and the footer.
extern NSString * const JNWCollectionViewGridLayoutHeaderKind;
extern NSString * const JNWCollectionViewGridLayoutFooterKind;

// The delegate is responsible for returning size information for the grid layout.
@protocol JNWCollectionViewGridLayoutDelegate <NSObject>

@optional

// Asks the delegate for the size of all the items in the grid layout.
//
// If this method is implemented, `itemSize` will be set to returned values.
- (CGSize)sizeForItemInCollectionView:(JNWCollectionView *)collectionView;

// Asks the delegate for the height of the header or footer in the specified section.
//
// The default height for both the header and footer is 0.
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index;
- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForFooterInSection:(NSInteger)index;

@end

// A layout subclass that displays items in an evenly spaced grid. All items
// have the same size, and are evenly spaced apart from each other.
@interface JNWCollectionViewGridLayout : JNWCollectionViewReorderableLayout

// The delegate for the grid layout. The delegate, if needed, should be set before
// the collection view is reloaded.
@property (nonatomic, unsafe_unretained) id<JNWCollectionViewGridLayoutDelegate> delegate;

// The size of all the items in the grid layout.
//
// Any values returned from the delegate method -sizeForItemInCollectionView: will
// override any value set here.
@property (nonatomic, assign) CGSize itemSize;

@end
