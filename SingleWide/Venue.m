//
//  Venue.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "Venue.h"

@interface Venue ()

+ (instancetype)findVenueWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation Venue

@dynamic doubleWideId;
@dynamic foursquareId;
@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic checkIns;

+ (id)venueWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	Venue *venue = [self findVenueWithPredicate:[NSPredicate predicateWithFormat:@"doubleWideId = %@", doubleWideId] inManagedObjectContext:managedObjectContext];
	if (!venue) {
		venue = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		venue.doubleWideId = doubleWideId;
	}
	
	return venue;
}

+ (id)venueWithFoursquareId:(NSString *)foursquareId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	Venue *venue = [self findVenueWithPredicate:[NSPredicate predicateWithFormat:@"foursquareId = %@", foursquareId] inManagedObjectContext:managedObjectContext];
	if (!venue) {
		venue = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		venue.foursquareId = foursquareId;
	}
	
	return venue;
}

+ (NSString *)entityName
{
	return @"Venue";
}

+ (instancetype)findVenueWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	request.predicate = predicate;
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
	return objects.lastObject;
}

@end
