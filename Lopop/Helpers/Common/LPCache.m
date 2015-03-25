//
//  LPCache.m
//  Lopop
//
//  Created by Troy Ling on 3/24/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPUserRelationship.h"
#import "LPCache.h"

@interface LPCache ()

@property (strong, nonatomic) NSCache *cache;

@end

NSString *const kPopsKey = @"pops";
NSString *const kPastPopsKey = @"pastPops";
NSString *const kFollowingKey = @"following";
NSString *const kFollowersKey = @"followers";

NSString *const kNumPopsKey = @"popsCount";
NSString *const kNumPastPopsKey = @"pastPopCount";
NSString *const kNumFollowingKey = @"followingCount";
NSString *const kNumFollowersKey = @"followersCount";

@implementation LPCache

static LPCache * instance;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

//- (void)setAttributesForUser:(PFUser *)user pops:(NSArray *)pops pastPops:(NSArray *)pastPops following:(NSArray *)following followers:(NSArray *)followers {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                pops, kPopsKey,
//                                pastPops, kPastPopsKey,
//                                following, kFollowingKey,
//                                followers, kFollowersKey,
//                                pops.count, kNumPopsKey,
//                                pastPops.count, kNumPastPopsKey,
//                                following.count, kNumFollowingKey,
//                                followers.count, kNumFollowersKey
//                                ,nil];
//    [self setAttributes:attributes ForUser:user];
//}

- (void)setAttributesForUser:(PFUser *)user pops:(NSArray *)pops {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[self attributesForUser:user]];
    [attributes setObject:pops forKey:kPopsKey];
    [attributes setObject:[NSNumber numberWithUnsignedLong:pops.count] forKey:kNumPopsKey];
    [self setAttributes:attributes ForUser:user];
}

- (void)setAttributesForUser:(PFUser *)user pastPops:(NSArray *)pastPops {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[self attributesForUser:user]];
    [attributes setObject:pastPops forKey:kPastPopsKey];
    [attributes setObject:[NSNumber numberWithUnsignedLong:pastPops.count] forKey:kNumPastPopsKey];
    [self setAttributes:attributes ForUser:user];
}

- (void)setAttributesForUser:(PFUser *)user following:(NSArray *)following {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[self attributesForUser:user]];
    [attributes setObject:following forKey:kFollowingKey];
    [attributes setObject:[NSNumber numberWithUnsignedLong:following.count] forKey:kNumFollowingKey];
    [self setAttributes:attributes ForUser:user];
}

- (void)setAttributesForUser:(PFUser *)user followers:(NSArray *)followers {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[self attributesForUser:user]];
    [attributes setObject:followers forKey:kFollowersKey];
    [attributes setObject:[NSNumber numberWithUnsignedLong:followers.count] forKey:kNumFollowersKey];
    [self setAttributes:attributes ForUser:user];
}

- (void)synchronizeFollowingForCurrentUserInBackground {
    PFQuery *query = [LPUserRelationship query];
    [query whereKey:@"follower" equalTo:[PFUser currentUser]];
    [query includeKey:@"followedUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *following = [NSMutableArray array];
            for (LPUserRelationship *relationship in objects) {
                [following addObject:relationship.followedUser];
            }
            [self setAttributesForUser:[PFUser currentUser] following:following];
        }
    }];
}

- (void)synchronizeFollowingForCurrentUserInBackgroundIfNecessary {
    NSArray *currentUserFolloing = [[LPCache getInstance] followingForUser:[PFUser currentUser]];
    if (currentUserFolloing == nil) {
        [self synchronizeFollowingForCurrentUserInBackground];
    }
}

- (BOOL)isCurrentUserFollowingUser:(PFUser *)user {
    NSArray *currentUserFollowing = [self followingForUser:[PFUser currentUser]];
    for (PFUser *u in currentUserFollowing) {
        if ([u.objectId isEqualToString:user.objectId])
            return YES;
    }
    return NO;
}

- (NSArray *)popsForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    return [attributes objectForKey:kPopsKey];
}

- (NSArray *)pastPopsForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    return [attributes objectForKey:kPastPopsKey];
}

- (NSArray *)followingForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    return [attributes objectForKey:kFollowingKey];
}

- (NSArray *)followersForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    return [attributes objectForKey:kFollowersKey];
}

- (NSNumber *)numPopsForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    NSNumber *numPops = [attributes objectForKey:kNumPopsKey];
    return numPops == nil ? [NSNumber numberWithInt:0] : numPops;
}

- (NSNumber *)numPastPopsForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    NSNumber *numPastPops = [attributes objectForKey:kNumPastPopsKey];
    return numPastPops == nil ? [NSNumber numberWithInt:0] : numPastPops;
}

- (NSNumber *)numFollowingForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    NSNumber *numFollowing = [attributes objectForKey:kNumFollowingKey];
    return numFollowing == nil ? [NSNumber numberWithInt:0] : numFollowing;
}

- (NSNumber *)numFollowersForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    NSNumber *numFollowers = [attributes objectForKey:kNumFollowersKey];
    return numFollowers == nil ? [NSNumber numberWithInt:0] : numFollowers;
}

#pragma mark - Helpers

- (void)setAttributes:(NSDictionary *)attributes ForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", user.objectId];
}

@end
