//
//  LPAssociatedButton.m
//  Lopop
//
//  Created by Troy Ling on 2/19/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPAssociatedButton.h"

@implementation LPAssociatedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithAssociatedOjbect:(id)assocObj {
    if (!self) {
        self = [[LPAssociatedButton alloc] init];
    }
    self.associatedOjbect = assocObj;
    return self;
}

@end
