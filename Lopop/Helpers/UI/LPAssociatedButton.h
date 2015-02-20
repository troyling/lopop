//
//  LPAssociatedButton.h
//  Lopop
//
//  Created by Troy Ling on 2/19/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPAssociatedButton : UIButton

@property (strong, nonatomic) id associatedOjbect;

- (instancetype)initWithAssociatedOjbect:(id)assocObj;

@end
