//
//  RDKeyValueStore.h
//  RDSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDKeyValueStore : NSObject

+ (BOOL)checkTableName:(NSString *)tableName;

+ (instancetype)storeWithDBPath:(NSString *)dbPath
                     encryptKey:(NSString *)encryptKey;

- (void)createTableWithName:(NSString *)tableName;

- (BOOL)isTableExists:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;

#pragma mark -

- (BOOL)putObjectWithDictionary:(NSDictionary *)dictionary
                         withId:(NSString *)objectId
                      intoTable:(NSString *)tableName;

- (NSDictionary *)getRDKeyValueItemDictionaryById:(NSString *)objectId
                                        fromTable:(NSString *)tableName;

- (BOOL)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;

- (BOOL)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName;

- (NSUInteger)getCountFromTable:(NSString *)tableName;

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;


@end
