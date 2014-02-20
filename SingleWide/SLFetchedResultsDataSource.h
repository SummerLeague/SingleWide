//
//  SLFetchedResultsDataSource.h
//  SingleWide
//
//  Created by Mark Stultz on 1/4/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@protocol SLFetchedResultsDataSourceDelegate;

@interface SLFetchedResultsDataSource : NSObject

@property (nonatomic, copy) NSString *reusableCellIdentifier;
@property (nonatomic, weak) id<SLFetchedResultsDataSourceDelegate> delegate;

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController collectionView:(UICollectionView *)collectionView;
- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView;

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (id)selectedItem;

@end

@protocol SLFetchedResultsDataSourceDelegate <NSObject>
@required
- (void)configureCell:(id)cell withObject:(id)object;
@end
