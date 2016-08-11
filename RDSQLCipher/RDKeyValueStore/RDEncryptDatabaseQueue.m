//
//  RDEncryptDatabaseQueue.m
//  RDSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "RDEncryptDatabaseQueue.h"
#import <FMDB.h>

@interface RDDatabaseQueue : FMDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

@end

@implementation RDDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    RDDatabaseQueue *queue = [self databaseQueueWithPath:aPath];
    if (queue && encryptKey) {
        [queue->_db setKey:encryptKey];
    }
    
    FMDBAutorelease(queue);
    
    return queue;
}

@end

@interface RDEncryptDatabaseQueue ()

@property (nonatomic, strong) RDDatabaseQueue *dbQueue;

@end

@implementation RDEncryptDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    return [[self alloc] initWithPath:aPath encryptKey:encryptKey];
}

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    if (self = [self init]) {
        _dbQueue = [RDDatabaseQueue databaseQueueWithPath:aPath encryptKey:encryptKey];
    }
    
    return self;
}

- (void)inDatabase:(void (^)(FMDatabase *db))block
{
    return [self.dbQueue inDatabase:block];
}

- (void)close
{
    [self.dbQueue close];
}

@end
