//
//  LPSocialNetworkHelper.h
//  Lopop
//
//  Created by Troy Ling on 2/13/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FBLinkShareParams.h>
#import "LPPop.h"
#import "WXApi.h"

@interface LPSocialNetworkHelper : NSObject

+ (FBLinkShareParams *)fbParamsWithPop:(LPPop *)pop;
+ (WXMediaMessage *)wechatMessageWithPop:(LPPop *)pop;

@end
