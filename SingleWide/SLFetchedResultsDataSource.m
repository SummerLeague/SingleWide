//
//  SLFetchedResultsDataSource.m
//  SingleWide
//
//  Created by Mark Stultz on 1/4/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLFetchedResultsDataSource.h"

@interface SLFetchedResultsDataSource () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UITableViewDataSource, UIDataSourceModelAssociation>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;

@end

@implementation SLFetchedResultsDataSource

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController collectionView:(UICollectionView *)collectionView
{
	self = [super init];
	if (self) {
		self.fetchedResultsController = fetchedResultsController;
		self.collectionView = collectionView;
		self.collectionView.dataSource = self;
	}
	
	return self;
}

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView
{
	self = [super init];
	if (self) {
		self.fetchedResultsController = fetchedResultsController;
		self.tableView = tableView;
		self.tableView.dataSource = self;
	}
	
	return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != fetchedResultsController) {
		_fetchedResultsController.delegate = nil;
		
		_fetchedResultsController = fetchedResultsController;
		
		_fetchedResultsController = fetchedResultsController;
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
	}
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath ? [self.fetchedResultsController objectAtIndexPath:indexPath] : nil;
}

- (id)selectedItem
{
	if (self.collectionView) {
		return [self itemAtIndexPath:self.collectionView.indexPathsForSelectedItems.firstObject];
	}
	else if (self.tableView) {
		return [self itemAtIndexPath:self.tableView.indexPathForSelectedRow];
	}
	
	return nil;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	self.blockOperation = [NSBlockOperation new];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.collectionView performBatchUpdates:^{
		[self.blockOperation start];
	} completion:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	__weak UICollectionView *weakCollectionView = self.collectionView;
	switch (type) {
		case NSFetchedResultsChangeInsert: {
			[self.blockOperation addExecutionBlock:^{
				[weakCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
				[weakCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, weakCollectionView.numberOfSections)]];
			}];
		}
			break;
		case NSFetchedResultsChangeDelete: {
			[self.blockOperation addExecutionBlock:^{
				[weakCollectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
				[weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
			}];
		}
			break;
		case NSFetchedResultsChangeUpdate: {
			[self.blockOperation addExecutionBlock:^{
				[weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
				[weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
			}];
		}
			break;
		case NSFetchedResultsChangeMove: {
			[self.blockOperation addExecutionBlock:^{
				[weakCollectionView moveSection:indexPath.section toSection:newIndexPath.section];
				[weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
			}];
		}
			break;
	}
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[ section ];
	return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	id cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.reusableCellIdentifier forIndexPath:indexPath];
	[self.delegate configureCell:cell withObject:object];
	return cell;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[ section ];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	id cell = [self.tableView dequeueReusableCellWithIdentifier:self.reusableCellIdentifier forIndexPath:indexPath];
	[self.delegate configureCell:cell withObject:object];
	return cell;
}

#pragma mark UIDataSourceModelAssociation

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
	NSString *modelIdentifier = nil;
	
	NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:idx];
	if (object) {
		modelIdentifier = object.objectID.URIRepresentation.absoluteString;
	}
	
	return modelIdentifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
	NSIndexPath *indexPath = nil;
	
	NSManagedObjectContext *managedObjectContext = self.fetchedResultsController.managedObjectContext;
	NSManagedObjectID *objectID = [managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:identifier]];
	if (objectID) {
		NSError *error = nil;
		NSManagedObject *object = [managedObjectContext existingObjectWithID:objectID error:&error];
		if (error) {
			NSLog(@"Error: %@", error.localizedDescription);
		}
		
		if (object) {
			indexPath = [self.fetchedResultsController indexPathForObject:object];
		}
	}
	
	return indexPath;
}

@end