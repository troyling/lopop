//
//  UIMessageTableView.m
//  Lopop
//
//  Created by Ruofan Ding on 2/1/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPMessageTableView.h"

@implementation LPMessageTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end
