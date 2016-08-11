//
//  ViewController.m
//  RDSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "ViewController.h"
#import "RDStoreManager.h"
#import "RDKeyValueItem.h"

@interface ViewController ()

@property (nonatomic, strong) RDStoreManager *storeManager;

@end

@implementation ViewController

- (IBAction)insertPeople:(id)sender {
    NSString *key = @"1";
    RDKeyValueItem *userItem = [RDKeyValueItem new];
    RDKeyValueItem *userItem2 = [RDKeyValueItem new];
    userItem.itemId = key;
    userItem.itemObject = userItem2;
    [self.storeManager saveUser:userItem];
    [self.storeManager setString:@"哈哈哈"];
    [self.storeManager setNumber:12356];
    [self.storeManager setBool:YES];
    NSLog(@"query data result: %@", [self.storeManager getUser]);
}

- (IBAction)deDatabase:(id)sender {
    [self.storeManager unEncryptDatabase];
}

- (IBAction)enDatabase:(id)sender {
    [self.storeManager encryptDatabase];
}

- (IBAction)changeKey:(id)sender {
    [self.storeManager changeEncryptKey];
}

- (IBAction)encryptQuery:(id)sender {
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", [self.storeManager encryptQuery]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}

- (IBAction)query:(id)sender {
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", [self.storeManager query]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.storeManager = [RDStoreManager new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
