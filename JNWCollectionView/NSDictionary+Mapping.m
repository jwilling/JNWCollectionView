//
// Created by chris on 18.11.13.
//

#import "NSDictionary+Mapping.h"


@implementation NSDictionary (Mapping)

- (NSDictionary*)dictionaryByMappingKeys:(id (^)(id))block
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
    {
        result[block(key)] = obj;
    }];
    return result;
}

@end
