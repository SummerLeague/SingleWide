//
//  SLPersistenceStack.m
//  SingleWide
//
//  Created by Mark Stultz on 12/30/13.
//  Copyright (c) 2013 Summer League. All rights reserved.
//

#import "SLPersistenceStack.h"

@interface SLPersistenceStack ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, copy) NSURL *modelURL;
@property (nonatomic, copy) NSURL *storeURL;

- (void)setupManagedObjectContext;

@end

@implementation SLPersistenceStack

+ (NSURL*)defaultStoreURL
{
	NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
	return [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

+ (NSURL*)defaultModelURL
{
	return [[NSBundle mainBundle] URLForResource:@"SingleWide" withExtension:@"momd"];
}

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;
{
	self = [super init];
	if (self) {
		self.storeURL = storeURL;
		self.modelURL = modelURL;
		[self setupManagedObjectContext];
	}
	
	return self;
}

- (void)setupManagedObjectContext;
{
	self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	
	NSError *error;
	[self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error];
	if (error) {
		NSLog(@"Could not add NSSQLiteStoreType persistent store type: %@", error);
	}
}

- (NSManagedObjectModel*)managedObjectModel;
{
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

- (void)save
{
	NSError *error = nil;
	[self.managedObjectContext save:&error];
	if (error) {
		NSLog(@"%@", error.description);
	}
}

@end
