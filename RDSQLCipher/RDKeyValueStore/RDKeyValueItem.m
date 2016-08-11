//
//  RDKeyValueItem.m
//  RDSQLCipher
//
//  Created by ozr on 16/8/11.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "RDKeyValueItem.h"

@implementation RDKeyValueItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
//             @"itemId":@"itemId",
//             @"itemObject":@"itemObject",
             };
}

+ (NSValueTransformer *)itemObjectJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[RDKeyValueItem class]];
}

@end
