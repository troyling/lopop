//
//  LPLocationHelper.h
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/PFGeoPoint.h>

@interface LPLocationHelper : NSObject

+ (void)getAddressForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude withBlock:(void (^)(NSString *address, NSError *error))completionBlock;
+ (void)getAddressForLocation:(CLLocation *)location withBlock:(void (^)(NSString *address, NSError *error))completionBlock;
+ (void)getAddressForGeoPoint:(PFGeoPoint *)geoPoint withBlock:(void (^)(NSString *address, NSError *error))completionBlock;

+ (NSString *)stringOfDistanceInMilesBetweenLocations:(CLLocation *)fromLocaiton and:(CLLocation *)toLocation withFormat:(NSString *)format;
+ (NSString *)stringOfDistanceInMilesBetweenGeoPoints:(PFGeoPoint *)fromPoint and:(PFGeoPoint *)toPoint withFormat:(NSString *)format;

@end

