//
//  User.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "User.h"

@interface User ()

+ (instancetype)findUserWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation User

@dynamic doubleWideId;
@dynamic nickname;
@dynamic checkIns;

+ (id)userWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	User *user = [self findUserWithPredicate:[NSPredicate predicateWithFormat:@"doubleWideId = %@", doubleWideId] inManagedObjectContext:managedObjectContext];
	if (!user) {
		user = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
		user.doubleWideId = doubleWideId;
	}
	
	return user;
}

+ (NSString *)entityName
{
	return @"User";
}

+ (instancetype)findUserWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	request.predicate = predicate;
	NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
	return objects.lastObject;
}

@end
