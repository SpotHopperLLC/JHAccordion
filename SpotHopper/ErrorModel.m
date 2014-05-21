//
//  ErrorModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ErrorModel.h"

@implementation ErrorModel

- (NSString *)human {
    NSString *human = [self objectForKey:@"human"];
    return (human.length > 0 ? human : @"An unknown error occured");
}

- (NSString*)humanValidations {

    NSMutableArray *messages = [NSMutableArray array];
    
    NSDictionary *validations = [self validations];
    
    // Loops through all validation keys
    for (NSString *errorKey in validations) {
        
        NSArray *validatonErrors = [validations objectForKey:errorKey];
        
        NSString *errorName = [errorKey capitalizedString];
        
        // Loops through all issues on a validation key
        for (NSString *validation in validatonErrors) {
            [messages addObject:[NSString stringWithFormat:@"%@ %@", errorName, validation]];
        }
    }
    
    return ( messages.count > 0 ? [messages componentsJoinedByString:@"\n"] : [self human] );
}

- (NSString *)error {
    return [self objectForKey:@"error"];
}

- (NSDictionary *)validations {
    return [self objectForKey:@"validations"];
}

@end
