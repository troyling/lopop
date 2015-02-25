//
//  LPLocationHelper.m
//  Lopop
//
//  Created by Troy Ling on 2/25/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPLocationHelper.h"

@implementation LPLocationHelper

+ (void)getAddressForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude withBlock:(void (^)(NSString *address, NSError *error))completionBlock {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self getAddressForLocation:location withBlock:completionBlock];
}

+ (void)getAddressForGeoPoint:(PFGeoPoint *)geoPoint withBlock:(void (^)(NSString *, NSError *))completionBlock {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    [self getAddressForLocation:location withBlock:completionBlock];
}

+ (void)getAddressForLocation:(CLLocation *)location withBlock:(void (^)(NSString *address, NSError *error))completionBlock {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            if(placemarks && placemarks.count > 0) {
                CLPlacemark *placemark= [placemarks objectAtIndex:0];

                NSString *address = @"";
                if ([placemark subThoroughfare]) {
                    address = [address stringByAppendingString:[placemark subThoroughfare]];
                }

                if ([placemark thoroughfare]) {
                    address = [address stringByAppendingString:[NSString stringWithFormat:@" %@", [placemark thoroughfare]]];
                }

                if ([placemark locality]) {
                    address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark locality]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark locality]]];;
                }

                if ([placemark administrativeArea]) {
                    address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark administrativeArea]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark administrativeArea]]];;
                }

                if ([placemark postalCode]) {
                    address = address.length > 0 ? [address stringByAppendingString:[NSString stringWithFormat:@", %@", [placemark postalCode]]] : [address stringByAppendingString:[NSString stringWithFormat:@"%@", [placemark postalCode]]];
                }

                if (completionBlock) {
                    completionBlock(address, error);
                }
            }

        } else {
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }
    }];
}

+ (NSString *)stringOfDistanceInMilesBetweenLocations:(CLLocation *)fromLocaiton and:(CLLocation *)toLocation withFormat:(NSString *)format {
    PFGeoPoint *fromPoint = [PFGeoPoint geoPointWithLocation:fromLocaiton];
    PFGeoPoint *toPoint = [PFGeoPoint geoPointWithLocation:toLocation];
    return [self stringOfDistanceInMilesBetweenGeoPoints:fromPoint and:toPoint withFormat:format];
}

+ (NSString *)stringOfDistanceInMilesBetweenGeoPoints:(PFGeoPoint *)fromPoint and:(PFGeoPoint *)toPoint withFormat:(NSString *)format {
    CLLocationDistance distance = [fromPoint distanceInMilesTo:toPoint];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:format];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:distance]];
}

@end
