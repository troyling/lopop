//
//  LPSocialNetworkHelper.m
//  Lopop
//
//  Created by Troy Ling on 2/13/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPSocialHelper.h"

@implementation LPSocialHelper


+ (FBLinkShareParams *)fbParamsWithPop:(LPPop *)pop {
    NSString *linkStr = [pop publicLink];
    NSURL *link = [NSURL URLWithString:linkStr];

    PFFile *thumbnail = pop.images.firstObject;
    NSURL *pictureUrl = [NSURL URLWithString:thumbnail.url];

    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:link
                                                                   name:pop.title
                                                                caption:@"Lopop"
                                                            description:pop.popDescription
                                                                picture:pictureUrl];
    return params;

}


+ (WXMediaMessage *)wechatMessageWithPop:(LPPop *)pop {
    NSString *linkStr = [pop publicLink];

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = pop.title;
    message.description = pop.popDescription;

    // TODO compress the image
    //    PFFile *imgFile = pop.images.firstObject;
    //    UIImage *img = [UIImage imageWithData:[imgFile getData]];
    //    [message setThumbImage:img];

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = linkStr;

    message.mediaObject = ext;
    message.mediaTagName = @"Lopop";

    return message;
}

@end
    