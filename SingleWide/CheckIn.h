//
//  CheckIn.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@class User;
@class Venue;

@interface CheckIn : NSManagedObject

@property (nonatomic, copy) NSString *doubleWideId;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Venue *venue;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

+ (id)checkInWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)entityName;

@end
