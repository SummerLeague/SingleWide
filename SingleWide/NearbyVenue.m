//
//  NearbyVenue.m
//  SingleWide
//
//  Created by Mark Stultz on 2/18/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "NearbyVenue.h"
#import "Venue.h"

@interface NearbyVenue ()

+ (instancetype)findNearbyVenueWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation NearbyVenue

@dynamic latitude;
@dynamic longitude;
@dynamic index;
@dynamic venue;

+ (id)nearbyVenueWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
	NearbyVenue *nearbyVenue = [self findNearbyVenueWithPredicate:[NSPredicate predicateWithFormat:@"latitude = %@ && longitude = %@", latitude, longitude] inManagedObjectContext:managedObjectContext];
	if (!nearbyVenue) {
		nearbyVenue = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		nearbyVenue.latitude = latitude;
		nearbyVenue.longitude = longitude;
	}
	
	return nearbyVenue;
}

+ (id)nearbyVenueWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude venue:(Venue *)venue inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NearbyVenue *nearbyVenue = [self findNearbyVenueWithPredicate:[NSPredicate predicateWithFormat:@"latitude = %@ && longitude = %@ && venue = %@", latitude, longitude, venue] inManagedObjectContext:managedObjectContext];
	if (!nearbyVenue) {
		nearbyVenue = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		nearbyVenue.latitude = latitude;
		nearbyVenue.longitude = longitude;
		nearbyVenue.venue = venue;
	}
	
	return nearbyVenue;
}

+ (NSString *)entityName
{
	return @"NearbyVenue";
}

+ (instancetype)findNearbyVenueWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	request.predicate = predicate;
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
	return objects.lastObject;
}

+ (NSFetchedResultsController *)nearbyVenueFetchedResultsControllerWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	request.predicate = [NSPredicate predicateWithFormat:@"latitude = %@ && longitude = %@", latitude, longitude];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
	return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

@end
