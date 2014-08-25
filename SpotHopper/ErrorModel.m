//
//  ErrorModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ErrorModel.h"

@implementation ErrorModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ [%@]", self.human, self.error];
}

#pragma mark - Mapping

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"human" : @"human",
             @"error" : @"error",
             @"validations" : @"validations"
             };
}

#pragma mark - Calculated Getters

- (NSString*)humanValidations {
    
    NSMutableArray *messages = [NSMutableArray array];
    
    NSDictionary *validations = self.validations;
    
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

#pragma mark - Getters

//- (NSString *)human {
//    if (!_human) {
//        NSString *human = [self objectForKey:@"human"];
//        _human = (human.length > 0 ? human : @"An unknown error occured");
//    }
//    
//    return _human;
//}
//
//- (NSString *)error {
//    if (_error) {
//        _error = [self objectForKey:@"error"];
//    }
//    
//    return _error;
//}
//
//- (NSDictionary *)validations {
//    if (!_validations) {
//        _validations = [self objectForKey:@"validations"];
//    }
//    
//    return _validations;
//}

@end
