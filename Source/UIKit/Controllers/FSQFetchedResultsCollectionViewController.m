//
//  FSQFetchedResultsCollectionViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 7/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsCollectionViewController.h"

#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"
#import "NSIndexPath+FSQFoundation.h"

#import "FSQMacros.h"
#import "FSQLogging.h"



@interface FSQCollectionViewChange : NSObject
@property (nonatomic) NSFetchedResultsChangeType type;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSIndexPath *newIndexPath NS_RETURNS_NOT_RETAINED;
+ (id) withType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath;
@end
@implementation FSQCollectionViewChange
- (NSString *) toString {
    return [NSString stringWithFormat:@"%@ %@ %@",@(_type),[_indexPath toString],[_newIndexPath toString]];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@",[super description],[self toString]];
}
- (NSUInteger) hash {
	return [[self toString] hash];
}
- (BOOL) isEqual:(id)object {
	if (NO == [object isKindOfClass:[FSQCollectionViewChange class]]) {
		return NO;
	}
	return [[self toString] isEqualToString:[object toString]];
}
+ (id) withType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath {
	FSQCollectionViewChange *change = [[self alloc] init];
	change.type = type;
	change.indexPath = indexPath;
	change.newIndexPath = newIndexPath;
	return change;
}
@end


@interface FSQFetchedResultsCollectionViewController ()
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) NSMutableSet *pendingChanges;

@end

@implementation FSQFetchedResultsCollectionViewController


- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return _managedObjectContext;
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if (_managedObjectContext != managedObjectContext) {
		_managedObjectContext = managedObjectContext;
		self.fetchedResultsController = nil;
	}
}

- (NSFetchedResultsController *) fetchedResultsController {
	if (_fetchedResultsController == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return _fetchedResultsController;
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != fetchedResultsController) {
		_fetchedResultsController = fetchedResultsController;
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController fetch];
	}
}



// ========================================================================== //

#pragma mark - Object


- (void) dealloc {
	_fetchedResultsController.delegate = nil;
}

- (void) initialize {
	// Initialization code
	self.initialized = YES;
	if (nil == _pendingChanges) {
		_pendingChanges = [NSMutableSet new];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}



// ========================================================================== //

#pragma mark - View Controller

- (void) viewDidLoad {
	FSQAssert(self.initialized, @"Controller not initialized. Did you forget to call [super initialize] from %@?",self);
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.collectionView reloadData];
}


// ========================================================================== //

#pragma mark - Collection View Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.fetchedResultsController numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	NSInteger numberOfItems =  [self.fetchedResultsController numberOfObjectsInSection:section];
	return numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self warn:_cmd];
}

//
//// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;


//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
//// These methods provide support for copy/paste actions on cells.
//// All three should be implemented if any are.
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;



// ========================================================================== //

#pragma mark -  NSFetchedResultsController Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

}


//NSFetchedResultsChangeInsert = 1,
//NSFetchedResultsChangeDelete = 2,
//NSFetchedResultsChangeMove = 3,
//NSFetchedResultsChangeUpdate = 4

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//	FLog(@"controller.fetchRequest:%@",controller.fetchRequest);
//	FLog(@"object:%@",anObject);
//	FLog(@"indexPath:%@",indexPath);
//	FLog(@"type:%@",@(type));
//	FLog(@"newIndexPath:%@",newIndexPath);
    
//    FLog(@"changedValues: %@",[anObject changedValues]);
//    FLog(@"changedValuesForCurrentEvent: %@",[anObject changedValuesForCurrentEvent]);
	
	[_pendingChanges addObject:[FSQCollectionViewChange withType:type indexPath:indexPath newIndexPath:newIndexPath]];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {	
	[self.collectionView performBatchUpdates:^{
		[_pendingChanges enumerateObjectsUsingBlock:^(FSQCollectionViewChange *change, BOOL *stop) {
			switch(change.type) {
					
				case NSFetchedResultsChangeInsert:
					[self.collectionView insertItemsAtIndexPaths:@[change.newIndexPath]];
					break;
					
				case NSFetchedResultsChangeDelete:
					[self.collectionView deleteItemsAtIndexPaths:@[change.indexPath]];
					break;
					
				case NSFetchedResultsChangeUpdate:
//					[self configureCell:[self.collectionView cellForItemAtIndexPath:change.indexPath] atIndexPath:change.indexPath];
					[self.collectionView reloadItemsAtIndexPaths:@[change.indexPath]];
					break;
					
				case NSFetchedResultsChangeMove:
					[self.collectionView deleteItemsAtIndexPaths:@[change.indexPath]];
					[self.collectionView insertItemsAtIndexPaths:@[change.newIndexPath]];
					break;
			}

		}];
        [_pendingChanges removeAllObjects];
	} completion:^(BOOL finished) {
//		[_pendingChanges removeAllObjects];
	}];
}


@end

