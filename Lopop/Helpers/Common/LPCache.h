//
//  LPCache.h
//  Lopop
//
//  Created by Troy Ling on 3/24/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

/**
 *  This is a singleton used to cache information locally for pop, follower, counting, and etc.
 */
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LPCache : NSObject

+ (instancetype)getInstance;

//- (void)setAttributesForUser:(PFUser *)user pops:(NSArray *)pops pastPops:(NSArray *)pastPops following:(NSArray *)following followers:(NSArray *)followers;
- (void)setAttributesForUser:(PFUser *)user pops:(NSArray *)pops;
- (void)setAttributesForUser:(PFUser *)user pastPops:(NSArray *)pastPops;
- (void)setAttributesForUser:(PFUser *)user following:(NSArray *)following;
- (void)setAttributesForUser:(PFUser *)user followers:(NSArray *)followers;

- (BOOL)isCurrentUserFollowingUser:(PFUser *)user;

- (NSArray *)popsForUser:(PFUser *)user;
- (NSArray *)pastPopsForUser:(PFUser *)user;
- (NSArray *)followersForUser:(PFUser *)user;
- (NSArray *)followingForUser:(PFUser *)user;

- (NSNumber *)numPopsForUser:(PFUser *)user;
- (NSNumber *)numPastPopsForUser:(PFUser *)user;
- (NSNumber *)numFollowersForUser:(PFUser *)user;
- (NSNumber *)numFollowingForUser:(PFUser *)user;

//- (void)incrementPopsForUser:(PFUser *)user;
//- (void)decrementPopsForUser:(PFUser *)user;
//
//- (void)incrementPastPopsForUser:(PFUser *)user;
//- (void)decrementPastPopsForUser:(PFUser *)user;
//
//- (void)incrementFollowersForUser:(PFUser *)user;
//- (void)decrementFollowersForUser:(PFUser *)user;
//
//- (void)incrementFollowingForUser:(PFUser *)user;
//- (void)decrementFollowingForUser:(PFUser *)user;




@end
