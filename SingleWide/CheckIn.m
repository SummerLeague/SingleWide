//
//  CheckIn.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "CheckIn.h"

@interface CheckIn ()

+ (instancetype)findCheckInWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation CheckIn

@dynamic doubleWideId;
@dynamic creationDate;
@dynamic user;
@dynamic venue;
@dynamic latitude;
@dynamic longitude;

+ (id)checkInWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	CheckIn *checkIn = [self findCheckInWithPredicate:[NSPredicate predicateWithFormat:@"doubleWideId = %@", doubleWideId] inManagedObjectContext:managedObjectContext];
	if (!checkIn) {
		checkIn = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		checkIn.doubleWideId = doubleWideId;
	}
	
	return checkIn;
}

+ (NSString *)entityName
{
	return @"CheckIn";
}

+ (instancetype)findCheckInWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	request.predicate = predicate;
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
	return objects.lastObject;
}

@end
