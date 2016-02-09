//
//  CKPropertyTableViewController.m
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKPropertyTableViewController.h"
#import "NSObject+Enumerator.h"

@interface CKPropertyTableViewController ()

@end

@implementation CKPropertyTableViewController {
    NSArray *_properties;
}

#pragma mark - Lifecycle

- (instancetype)initWithClass:(Class)aClass
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [aClass enumeratePropertiesUsingBlock:^(NSString *name, __unsafe_unretained Class aClass) {
            
            if (aClass == [NSString class] || aClass == [NSDate class])
            {
                [array addObject:name];
            }
            
        }];
        
        _properties = array;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _properties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (! cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = _properties[indexPath.row];
    return cell;
}


@end
