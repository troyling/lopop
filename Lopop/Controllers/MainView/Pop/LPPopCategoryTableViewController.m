//
//  LPPopCategoryTableViewController.m
//  Lopop
//
//  Created by Troy Ling on 1/20/15.
//  Copyright (c) 2015 Lopop Inc. All rights reserved.
//

#import "LPPopCategoryTableViewController.h"

@interface LPPopCategoryTableViewController ()

@property NSArray *categories;

@end

@implementation LPPopCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categories = @[@"Motors",
                        @"Electronics",
                        @"Textbooks",
                        @"Clothes & Fashion",
                        @"Home & Garden",
                        @"Art & collection",
                        @"Sports",
                        @"Other"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"LPCategories";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *selectedCategory = cell.textLabel.text;
    self.vc.category = selectedCategory;
    self.vc.categoryLabel.text = selectedCategory;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
