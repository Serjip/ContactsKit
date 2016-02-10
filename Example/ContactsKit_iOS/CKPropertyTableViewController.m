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

@interface CKPropertyTableViewController () <CKDetailsTableViewCellDelegate>

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
            
            if (aClass == [NSString class])
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionSetPropertiesToObject:)];
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
    cell.value = [value isKindOfClass:[NSString class]] ? value : nil;
    cell.delegate = self;

    return cell;
}

#pragma mark - CKDetailsTableViewCellDelegate

- (void)cell:(CKDetailsTableViewCell *)cell didChangeValue:(NSString *)value forKey:(NSString *)key
{
    [_object setValue:value forKey:key];
}

#pragma mark - Actions

- (void)actionSetPropertiesToObject:(UIBarButtonItem *)sender
{
    [self.delegate propertyTableController:self didSaveObject:_object];
}

@end
