//
// Created by chris on 18.11.13.
//

#import "NSArray+Mapping.h"


@implementation NSArray (Mapping)


- (id)firstObject
{
    return self.count ? self[0] : nil;
}

- (NSArray*)map:(id (^)(id))block
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:self.count];
    for(id item in self) {
        id result = block(item);
        if (result) {
            [array addObject:result];
        }
    }
    return array;
}
@end
