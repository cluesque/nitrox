//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiLocation.h"


@implementation NitroxApiLocation

@synthesize locationManager, started, currentLocation;

- (NitroxApiLocation *)initWithLocationManager:(CLLocationManager *)mgr
{
    self.locationManager = mgr;
    [self.locationManager setDelegate:self];
    self.currentLocation = Nil;
    return self;
}


- (NitroxApiLocation *)init
{
    [self initWithLocationManager:[[CLLocationManager alloc] init]];
    return self;
}

- (void) dealloc {
    if (started) {
        [locationManager stopUpdatingLocation];
    }
    [currentLocation release];
    [locationManager release];
    [super dealloc];
}

#pragma mark Photo specific methods

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    SEL sel = NSSelectorFromString(method);
    
    NSString *res = @"no result";
    
    if ([self respondsToSelector:sel]) {
        res = [self performSelector:sel];
    }

    return res;
}

- (id) invoke:(NSString *)method args:(NSDictionary *)args {
    return Nil;
}

- (id) start {
    if (! started) {
        [locationManager startUpdatingLocation];
        self.currentLocation = Nil;
        started = YES;
    }
    return Nil;
}

- (id) stop {
    if (started) {
        [locationManager stopUpdatingLocation];
        started = NO;
    }
    return Nil;
}

- (id) getLocation {
    if (!started || currentLocation == Nil) {
        return Nil;
    }

    NSLog(@"current location info is %@", self.currentLocation);
    
    CLLocation *loc = self.currentLocation;
    NSDictionary *linfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude], @"latitude",
                         [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude], @"longitude",
                         [NSString stringWithFormat:@"%f", currentLocation.altitude], @"altitude",
                         [NSString stringWithFormat:@"%f", currentLocation.verticalAccuracy], @"verticalAccuracy",
                         [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy], @"horizontalAccuracy",
                         [NSString stringWithFormat:@"%@", currentLocation.timestamp], @"timestamp",
                         Nil];
    return [linfo autorelease];
}

#pragma mark Location Delegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"received location update from %@ to %@", oldLocation, newLocation);
    
    self.currentLocation = newLocation;
    
    // TODO: call JS callback / fire event
}

/*
 *  locationManager:failedWithError:
 *  
 *  Discussion:
 *    Invoked when an error has occurred.
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed: %@", error);
}


#pragma mark Stub methods; should refactor out


- (NSString *) className {
    return @"Device";
}

- (NSString *) instanceMethods {
    return Nil;
}

- (NSString *) classMethods {
    return Nil;
}

- (id) newInstance {
    return Nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return Nil;
}




@end
