//
//  CKPropertyTableViewController.m
//  ContactsKit
//
//  Created by Sergey Popov on 09.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKPropertyTableViewController.h"
#import "NSObject+Enumerator.h"
#import "CKDetailsTableViewCell.h"

@interface CKPropertyTableViewController ()

@end

@implementation CKPropertyTableViewController {
    NSArray *_properties;
    id _object;
}

#pragma mark - Lifecycle

- (instancetype)initWithObject:(id)anObject ofClass:(Class)aClass
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
        _object = anObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[CKDetailsTableViewCell nib] forCellReuseIdentifier:[CKDetailsTableViewCell cellReuseIdentifier]];
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
    CKDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CKDetailsTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
    
    NSString *key = _properties[indexPath.row];
    cell.name = key;
    
    id value = [_object valueForKey:key];
    
    if ([value isKindOfClass:[NSString class]])
    {
        cell.value = value;
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        cell.value = [value description];
    }
    
    return cell;
}

@end
