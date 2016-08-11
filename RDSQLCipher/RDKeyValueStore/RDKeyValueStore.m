//
//  RDKeyValueStore.m
//  RDSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "RDKeyValueStore.h"
#import "RDEncryptDatabaseQueue.h"
#import "RDKeyValueStoreDef.h"
#import "RDKeyValueItem.h"

#import <FMDB.h>

static RDKeyValueStore* shareStore;

@interface RDKeyValueStore ()

@property (nonatomic, copy) NSString *encryptKey;
@property (nonatomic, strong) RDEncryptDatabaseQueue *dbQueue;

@end

@implementation RDKeyValueStore

+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        NSLog(@"ERROR, table name: %@ format error.", tableName);
        return NO;
    }
    return YES;
}

+ (instancetype)storeWithDBPath:(NSString *)dbPath
                     encryptKey:(NSString *)encryptKey
{ 
    return [[self alloc] initWithDBWithPath:dbPath encryptKey:encryptKey];
}

- (instancetype)initWithDBWithPath:(NSString *)dbPath
                        encryptKey:(NSString *)encryptKey
{
    if (self = [self init]) {
        _encryptKey = [encryptKey copy];
        _dbQueue = [RDEncryptDatabaseQueue databaseQueueWithPath:dbPath encryptKey:encryptKey];
    }
    
    return self;
}

- (void)createTableWithName:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to create table: %@", tableName);
    }
}

- (BOOL)isTableExists:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    if (!result) {
        NSLog(@"ERROR, table: %@ not exists in current DB", tableName);
    }
    return result;
}

- (void)clearTable:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to clear table: %@", tableName);
    }
}

- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

#pragma mark -

- (BOOL)putObjectWithDictionary:(NSDictionary *)dictionary
                         withId:(NSString *)objectId
                      intoTable:(NSString *)tableName
{
    return [self putObject:dictionary withId:objectId intoTable:tableName];
}

- (NSDictionary *)getRDKeyValueItemDictionaryById:(NSString *)objectId
                                        fromTable:(NSString *)tableName
{
    return [self getObjectById:objectId fromTable:tableName];
}

- (BOOL)putString:(NSString *)string
           withId:(NSString *)stringId
        intoTable:(NSString *)tableName
{
    if (string == nil) {
        NSLog(@"string should not be nil");
        return NO;
    }
    
    return [self putObject:@[string] withId:stringId intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName
{
    NSArray * array = [self getObjectById:stringId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (BOOL)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName
{
    if (number == nil) {
        NSLog(@"number should not be nil");
        return NO;
    }
    
    return [self putObject:@[number] withId:numberId intoTable:tableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName
{
    NSArray * array = [self getObjectById:numberId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
//            RDKeyValueItem * item = [[RDKeyValueItem alloc] init];
//            item.itemId = [rs stringForColumn:@"id"];
//            item.itemObject = [rs stringForColumn:@"json"];
//            item.createdTime = [rs dateForColumn:@"createdTime"];
            // parse json string to object
            NSError * error;
            id object = [NSJSONSerialization JSONObjectWithData:[[rs stringForColumn:@"json"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:(NSJSONReadingAllowFragments) error:&error];
            if (error) {
                NSLog(@"ERROR, faild to prase to json.");
            } else {
                [result addObject:object];
            }
        }
        [rs close];
    }];
    return result;
}

- (NSUInteger)getCountFromTable:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return 0;
    }
    NSString * sql = [NSString stringWithFormat:COUNT_ALL_SQL, tableName];
    __block NSInteger num = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            num = [rs unsignedLongLongIntForColumn:@"num"];
        }
        [rs close];
    }];
    return num;
}

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete item from table: %@", tableName);
    }
}

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName {
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete items by ids from table: %@", tableName);
    }
}

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName {
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_WITH_PREFIX_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", objectIdPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete items by id prefix from table: %@", tableName);
    }
}

#pragma mark - private

- (BOOL)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName {
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (!data) {
        NSLog(@"ERROR, faild to get json data");
        return NO;
    }
    
    [self createTableWithName:tableName];
    
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId, jsonString, createdTime];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to insert/replace into table: %@", tableName);
        return NO;
    }
    
    return YES;
}

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName
{
    if ([RDKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:QUERY_ITEM_SQL, tableName];
    __block NSString * json = nil;
    __block NSDate * createdTime = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql, objectId];
        if ([rs next]) {
            json = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    if (json) {
        NSError * error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            NSLog(@"ERROR, faild to prase to json");
            return nil;
        }
        //        RDKeyValueItem * item = [[RDKeyValueItem alloc] init];
        //        item.itemId = objectId;
        //        item.itemObject = result;
        //        item.createdTime = createdTime;
        return result;
    } else {
        return nil;
    }
}

@end
