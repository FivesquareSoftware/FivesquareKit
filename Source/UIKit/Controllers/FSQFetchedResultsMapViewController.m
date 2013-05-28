//
//  FSQFetchedResultsMapViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 2/26/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsMapViewController.h"

#import "FSQMacros.h"
#import "FSQLogging.h"
#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"


@interface FSQFetchedResultsMapViewController ()
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) id persistentStoresObserver;
@property (nonatomic, strong) id ubiquitousChangesObserver;
@end

@implementation FSQFetchedResultsMapViewController

// ========================================================================== //

#pragma mark - Properties


- (void) setZoomSpan:(NSUInteger)zoomSpan {
	[self setZoomSpan:zoomSpan animated:NO];
}

- (void) setZoomSpan:(NSUInteger)zoomSpan animated:(BOOL)animated {
	if (_zoomSpan != zoomSpan) {
		_zoomSpan = zoomSpan;		
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, _zoomSpan, _zoomSpan);
		[self.mapView setRegion:region animated:animated];
	}
}


// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	self.initialized = YES;
	_zoomSpan = 1000;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
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
	if (self.mapView == nil) {
		FSQAssert([self.view isKindOfClass:[MKMapView class]],@"View is not a map view");
		self.mapView = (MKMapView *)self.view;
	}
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = self.fetchedResultsController.managedObjectContext.persistentStoreCoordinator;
    
    FSQWeakSelf(self_);
    self.persistentStoresObserver = [notificationCenter addObserverForName:NSPersistentStoreCoordinatorStoresDidChangeNotification object:persistentStoreCoordinator queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self_.fetchedResultsController fetch];
    }];
    self.ubiquitousChangesObserver = [notificationCenter addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:persistentStoreCoordinator queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self_.fetchedResultsController fetch];
    }];

}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self addAnnotationsForEntities:self.fetchedResultsController.fetchedObjects];
}



// ========================================================================== //

#pragma mark - NSFetchedResultsControllerDelegate



//NSFetchedResultsChangeInsert = 1,
//NSFetchedResultsChangeDelete = 2,
//NSFetchedResultsChangeMove = 3,
//NSFetchedResultsChangeUpdate = 4


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	FLog(@"Implement %@ in your subclass", NSStringFromSelector(_cmd));
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	FLog(@"Implement %@ in your subclass", NSStringFromSelector(_cmd));
	
	//	switch(type) {
	//		case NSFetchedResultsChangeInsert:
	//			break;
	//			
	//		case NSFetchedResultsChangeDelete:
	//			break;
	//	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	//	FLog(@"Implement %@ in your subclass", NSStringFromSelector(_cmd));
	
	MKPointAnnotation *annotation = [MKPointAnnotation new];
	annotation.coordinate = [(id<FSQLocationEntity>)anObject coordinate];
	[self configureAnnotation:annotation withCoordinateLike:(id<FSQLocationEntity>)anObject];
	
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.mapView addAnnotation:annotation];
			break;			
		case NSFetchedResultsChangeDelete:
			[self.mapView removeAnnotation:annotation];
			break;
			
		case NSFetchedResultsChangeUpdate:
			break;
			
		case NSFetchedResultsChangeMove:
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.mapView setRegion:[self regionFromCoordinates:controller.fetchedObjects] animated:YES];
}

- (void) configureAnnotation:(MKPointAnnotation *)annotation withCoordinateLike:(id<FSQLocationEntity>)coordinateLike {
	FLog(@"Implement %@ in your subclass", NSStringFromSelector(_cmd));
}



// ========================================================================== //

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	FLog(@"Implement %@ in your subclass", NSStringFromSelector(_cmd));
	return nil;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	FLog(@"mapViewWillStartLoadingMap:");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	FLog(@"mapViewDidFinishLoadingMap:");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	FLog(@"mapViewDidFailLoadingMap:withError:%@",error);
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
	FLog(@"mapViewWillStartLocatingUser:");
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
	FLog(@"mapViewDidStopLocatingUser:");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	FLog(@"mapView:didUpdateUserLocation:%@",userLocation);
	self.mapView.centerCoordinate = userLocation.coordinate;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
	FLog(@"mapView:didFailToLocateUserWithError:%@",error);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	FLog(@"mapView:annotationView:calloutAccessoryControlTapped:");
}



// ========================================================================== //

#pragma mark - Map Helpers

- (void) addAnnotationsForEntities:(NSArray *)coordinates {
	[self.mapView removeAnnotations:self.mapView.annotations];
	for (id<FSQLocationEntity> coordinateLike in coordinates) {
		MKPointAnnotation *annotation = [MKPointAnnotation new];
		annotation.coordinate = coordinateLike.coordinate;
		[self configureAnnotation:annotation withCoordinateLike:coordinateLike];
		[self.mapView addAnnotation:annotation];
	}
	[self.mapView setRegion:[self regionFromCoordinates:coordinates] animated:YES];
}

- (MKCoordinateRegion)regionFromCoordinates:(NSArray *)coordinates {	
	id<FSQLocationEntity> lastCoordinate = [coordinates lastObject];
	CLLocationCoordinate2D upper = lastCoordinate.coordinate;
    CLLocationCoordinate2D lower = lastCoordinate.coordinate;
	
	for (id<FSQLocationEntity> coordinateLike in coordinates) {
		CLLocationCoordinate2D coordinate = coordinateLike.coordinate;
        if(coordinate.latitude > upper.latitude) upper.latitude = coordinate.latitude;
        if(coordinate.latitude < lower.latitude) lower.latitude = coordinate.latitude;
        if(coordinate.longitude > upper.longitude) upper.longitude = coordinate.longitude;
        if(coordinate.longitude < lower.longitude) lower.longitude = coordinate.longitude;
	}
	
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
}



@end
