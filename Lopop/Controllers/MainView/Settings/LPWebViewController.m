//
//  LPWebViewController.m
//  Lopop
//
//  Created by Troy Ling on 5/19/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPWebViewController.h"
#import "LPAlertViewHelper.h"

@interface LPWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.urlStr != nil && ![self.urlStr isEqualToString:@""]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    } else {
        [LPAlertViewHelper fatalErrorAlert:@"Unable to load the websitre"];
    }
}

@end
