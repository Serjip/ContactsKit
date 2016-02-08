//
//  CKDetailsTableViewController.m
//  ContactsKit
//
//  Created by Sergey Popov on 08.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKDetailsTableViewController.h"
#import <ContactsKit/ContactsKit.h>
#import <objc/runtime.h>

@implementation CKDetailsTableViewController {
    CKMutableContact *_contact;
    NSDictionary *_map;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _contact = [[CKMutableContact alloc] init];
    }
    return self;
}

- (instancetype)initWithContact:(CKContact *)contact
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _contact = contact.mutableCopy;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSaveContact:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    [self ck_fillMap:map class:[CKContact class]];
    _map = map;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _map.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id key = _map.allKeys[section];
    NSArray *array = _map[key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (! cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    id key = _map.allKeys[indexPath.section];
    NSArray *array = _map[key];
    cell.textLabel.text = array[indexPath.row];
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _map.allKeys[section];
}

#pragma mark - Actions

- (void)actionSaveContact:(UIBarButtonItem *)sender
{
    
}

#pragma mark - Private

- (void)ck_enumeratePropertiesOfClass:(Class)aClass usingBlock:(void (^) (NSString *name, Class aClass))block
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);
    
    for (unsigned int i = 0; i < count; i++)
    {
        objc_property_t p = properties[i];
        NSString *name =  @(property_getName(p));
        NSString *attributes = @(property_getAttributes(p));
        NSString *type = [attributes componentsSeparatedByString:@","].firstObject;
        type = [type substringFromIndex:1];
        
        if ([type hasPrefix:@"@"])
        {
            type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
            block(name, NSClassFromString(type));
        }
    }
    free(properties);
}

- (void)ck_fillMap:(NSMutableDictionary *)map class:(Class)aClass
{
    [self ck_enumeratePropertiesOfClass:aClass usingBlock:^(NSString *name, __unsafe_unretained Class aClass) {
        
        if (aClass == [NSString class])
        {
            NSMutableArray *array = [map objectForKey:NSStringFromClass(aClass)];
            if (! array)
            {
                array = [[NSMutableArray alloc] init];
                [map setObject:array forKey:NSStringFromClass(aClass)];
            }
            [array addObject:name];
        }
        else if (aClass == [NSArray class])
        {
            Class subClass;
            
            if ([name isEqualToString:@"phones"])
            {
                subClass = [CKMutablePhone class];
            }
            else if ([name isEqualToString:@"emails"])
            {
                subClass = [CKMutableEmail class];
            }
            else if ([name isEqualToString:@"addresses"])
            {
                subClass = [CKAddress class];
            }
            else if ([name isEqualToString:@"instantMessengers"])
            {
                subClass = [CKMessenger class];
            }
            else if ([name isEqualToString:@"socialProfiles"])
            {
                subClass = [CKSocialProfile class];
            }
            else if ([name isEqualToString:@"URLs"])
            {
                subClass = [CKMutableURL class];
            }
            
            NSMutableArray *array = [map objectForKey:name];
            if (! array)
            {
                array = [[NSMutableArray alloc] init];
                [map setObject:array forKey:name];
            }
            
            [self ck_enumeratePropertiesOfClass:subClass usingBlock:^(NSString *name, __unsafe_unretained Class aClass) {
                
                [array addObject:name];
                
             }];
        }
        
    }];
}

@end
