//
//  RDStoreManager.h
//  RDSQLCipher
//
//  Created by ozr on 16/8/11.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDKeyValueItem.h"

@interface RDStoreManager : NSObject

- (BOOL)saveUser:(id)user;
- (id)getUser;
- (BOOL)setString:(NSString *)string;
- (NSString *)getString;
- (BOOL)setNumber:(NSInteger)number;
- (NSInteger)getNumber;
- (BOOL)setBool:(BOOL)b;
- (BOOL)getBool;

#pragma mark - test

- (BOOL)encryptDatabase;
- (BOOL)unEncryptDatabase;
- (void)changeEncryptKey;
- (id)encryptQuery;
- (id)query;

@end
