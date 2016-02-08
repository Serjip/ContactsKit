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
    self = [super init];
    if (self)
    {
        _contact = [[CKMutableContact alloc] init];
    }
    return self;
}

- (instancetype)initWithContact:(CKContact *)contact
{
    self = [super init];
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
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([CKContact class], &count);
    
    for (unsigned int i = 0; i < count; i++)
    {
        objc_property_t p = properties[i];
        NSString *name =  @(property_getName(p));
        NSString *attributes = @(property_getAttributes(p));
        NSString *type = [attributes componentsSeparatedByString:@","].firstObject;
        
        NSLog(@"%@ %@",name, type);
        
        
    }
    free(properties);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Actions

- (void)actionSaveContact:(UIBarButtonItem *)sender
{
    
}

@end
