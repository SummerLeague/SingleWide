//
//  SLPersistenceStack.h
//  SingleWide
//
//  Created by Mark Stultz on 12/30/13.
//  Copyright (c) 2013 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface SLPersistenceStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

+ (NSURL*)defaultStoreURL;
+ (NSURL*)defaultModelURL;

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;

- (void)save;

@end
