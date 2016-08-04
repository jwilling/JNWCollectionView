//
//  PersonCell.h
//  JNWCollectionViewDemo
//
//  Created by Deadpikle on 8/4/16.
//  Copyright © 2016 AppJon. All rights reserved.
//

#import <JNWCollectionView/JNWCollectionView.h>

IB_DESIGNABLE
@interface PersonCell : JNWCollectionViewCell

@property (weak) IBInspectable IBOutlet NSTextField *dataLabel;

@end
