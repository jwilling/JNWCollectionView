//
//  JNWTableView_Private.h
//  JNWTableViewDemo
//
//  Created by Jonathan Willing on 3/26/13.
//  Copyright (c) 2013 AppJon. All rights reserved.
//

#import "JNWCollectionView.h"

@class JNWCollectionViewCell;
@interface JNWCollectionView ()

- (void)mouseDownInCollectionViewCell:(JNWCollectionViewCell *)cell withEvent:(NSEvent *)event;

@end
