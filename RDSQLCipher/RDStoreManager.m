//
//  RDStoreManager.m
//  RDSQLCipher
//
//  Created by ozr on 16/8/11.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "RDStoreManager.h"
#import "RDKeyValueStore.h"
#import "RDKeyValueStore/RDEncryptDBHelper.h"
#import <UIKit/UIKit.h>

#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

static NSString *const DEFAULT_DB_NAME = @"database.sqlite";
static NSString *const ENCRYPT_KEY = @"123456";

static NSString *const kTalbeNameUser = @"user";
static NSString *const kTableNameString = @"stringTest";
static NSString *const kTableNameNumber = @"numberTest";
static NSString *const kTableNameBool = @"boolTest";

@interface RDStoreManager ()

@property (nonatomic, strong) RDKeyValueStore *keyValueStore;
@property (nonatomic, copy) NSString *encryptKey;

@end

@implementation RDStoreManager

- (NSString *)dbPath
{
    return [PATH_OF_DOCUMENT stringByAppendingPathComponent:DEFAULT_DB_NAME];
}

- (instancetype)init
{
    if (self = [super init]) {
        _keyValueStore = [RDKeyValueStore storeWithDBPath:[self dbPath] encryptKey:ENCRYPT_KEY];
        _encryptKey = ENCRYPT_KEY;
    }
    
    return self;
}

- (BOOL)saveUser:(id)user
{
    return [self putObject:user
                    withId:@"1"
                 intoTable:kTalbeNameUser];
}

- (id)getUser
{
    return [self getObjectById:@"1"
                     fromTable:kTalbeNameUser
                    modelClass:[RDKeyValueItem class]];
}

- (BOOL)setString:(NSString *)string
{
    return [self.keyValueStore putString:string
                                  withId:@"1"
                               intoTable:kTableNameString];
}

- (NSString *)getString
{
    return [self.keyValueStore getStringById:@"1" fromTable:kTableNameString];
}

- (BOOL)setNumber:(NSInteger)number
{
    return [self.keyValueStore putNumber:@(number) withId:@"1" intoTable:kTableNameNumber];
}

- (NSInteger)getNumber
{
    return [[self.keyValueStore getNumberById:@"1" fromTable:kTableNameNumber] integerValue];
}

- (BOOL)setBool:(BOOL)b
{
    return [self.keyValueStore putNumber:@(b) withId:@"1" intoTable:kTableNameBool];
}

- (BOOL)getBool
{
    return [[self.keyValueStore getNumberById:@"1" fromTable:kTableNameNumber] boolValue];
}

#pragma mark - private

- (BOOL)putObject:(MTLModel<MTLJSONSerializing> *)object
           withId:(NSString *)objectId
        intoTable:(NSString *)tableName
{
    if (!object || ![object conformsToProtocol:NSProtocolFromString(@"MTLJSONSerializing")] || ![object isKindOfClass:[MTLModel class]]) {
        return NO;
    }
    
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:object];
    return [self.keyValueStore putObjectWithDictionary:dictionary
                                                withId:objectId
                                             intoTable:tableName];
}

- (MTLModel<MTLJSONSerializing> *)getObjectById:(NSString *)objectId
                                      fromTable:(NSString *)tableName
                                     modelClass:(Class)modelClass
{
    NSDictionary *dictionary = [self.keyValueStore getRDKeyValueItemDictionaryById:objectId
                                                                         fromTable:tableName];
    NSError *error;
    MTLModel<MTLJSONSerializing> *object = [MTLJSONAdapter modelOfClass:modelClass
                                                     fromJSONDictionary:dictionary
                                                                  error:&error];
    if (error) {
        NSLog(@"转换model失败");
        return nil;
    }
    return object;
}

#pragma mark - test

- (BOOL)encryptDatabase
{
    return [RDEncryptDBHelper encryptDatabase:[self dbPath] encryptKey:self.encryptKey];
}


- (BOOL)unEncryptDatabase
{
    return [RDEncryptDBHelper unEncryptDatabase:[self dbPath] encryptKey:self.encryptKey];
}

- (void)changeEncryptKey
{
    [RDEncryptDBHelper changeKey:[self dbPath]
                       originKey:self.encryptKey
                          newKey:@"hahaha"];
    self.encryptKey = @"hahaha";
}

- (id)encryptQuery
{
    self.keyValueStore = [RDKeyValueStore storeWithDBPath:[self dbPath] encryptKey:self.encryptKey];
    return [self getUser];
}

- (id)query
{
    self.keyValueStore = [RDKeyValueStore storeWithDBPath:[self dbPath] encryptKey:nil];
    return [self getUser];
}

@end
