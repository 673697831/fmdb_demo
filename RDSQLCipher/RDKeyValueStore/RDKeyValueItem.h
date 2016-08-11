//
//  RDKeyValueItem.h
//  RDSQLCipher
//
//  Created by ozr on 16/8/11.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Mantle.h>

@interface RDKeyValueItem : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) RDKeyValueItem *itemObject;
@property (strong, nonatomic) NSDate *createdTime;

@end
