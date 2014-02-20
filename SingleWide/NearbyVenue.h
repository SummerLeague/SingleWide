//
//  NearbyVenue.h
//  SingleWide
//
//  Created by Mark Stultz on 2/18/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Venue;

@interface NearbyVenue : NSManagedObject

@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSNumber *index;
@property (nonatomic, copy) Venue *venue;

+ (id)nearbyVenueWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)nearbyVenueWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude venue:(Venue *)venue inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)entityName;

+ (NSFetchedResultsController *)nearbyVenueFetchedResultsControllerWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
