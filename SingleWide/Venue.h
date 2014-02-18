//
//  Venue.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface Venue : NSManagedObject

@property (nonatomic, copy) NSString *doubleWideId;
@property (nonatomic, copy) NSString *foursquareId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSSet *checkIns;

+ (id)venueWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)venueWithFoursquareId:(NSString *)foursquareId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)entityName;

@end
