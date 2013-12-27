//
//  NSArray+SaveLoad.m
//  GoodNightCar
//
//  Created by Josh Holtz on 6/18/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "NSArray+SaveLoad.h"

@implementation NSArray (SaveLoad)

- (void)saveWithKey:(NSString*)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, key];
    
    if (self != nil) {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [self encodeWithCoder:archiver];
        [archiver finishEncoding];
        
        [data writeToFile:path atomically:YES];
    } else {
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        [fileMgr removeItemAtPath:path error:nil];
    }
    
}

+ (id)loadWithKey:(NSString*)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
        id obj = [[[self class] alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];
        
        return obj;
    }
    return nil;
}

@end
