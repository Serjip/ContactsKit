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

typedef enum : NSUInteger {
    TableSectionPhones      = 1,
    TableSectionEmails      = 2,
    TableSectionAddresses   = 3,
    TableSectionMessengers  = 4,
    TableSectionProfiles    = 5,
    TableSectionURLs        = 6,
} TableSection;

@implementation CKDetailsTableViewController {
    CKMutableContact *_contact;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super initWithClass:[CKContact class]];
    if (self)
    {
        _contact = [[CKMutableContact alloc] init];
    }
    return self;
}

- (instancetype)initWithContact:(CKContact *)contact
{
    self = [super initWithClass:[CKContact class]];
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView] + 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((TableSection)section)
    {
        case TableSectionPhones:
            return _contact.phones.count + 1;
            
        case TableSectionEmails:
            return _contact.emails.count + 1;
            
        case TableSectionAddresses:
            return _contact.addresses.count + 1;
            
        case TableSectionMessengers:
            return _contact.instantMessengers.count + 1;
            
        case TableSectionProfiles:
            return _contact.socialProfiles.count + 1;
            
        case TableSectionURLs:
            return _contact.URLs.count + 1;
    }
 
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch ((TableSection)indexPath.section)
    {
        case TableSectionPhones:
        {
            CKPhone *phone = _contact.phones[indexPath.row];
            cell.textLabel.text = phone.number;
            return cell;
        }
            
        case TableSectionEmails:
        {
            CKEmail *phone = _contact.emails[indexPath.row];
            cell.textLabel.text = phone.address;
            return cell;
        }
            
        case TableSectionAddresses:
        {
            CKAddress *phone = _contact.addresses[indexPath.row];
            cell.textLabel.text = phone.street;
            return cell;
        }
            
        case TableSectionMessengers:
        {
            CKMessenger *phone = _contact.instantMessengers[indexPath.row];
            cell.textLabel.text = phone.service;
            return cell;
        }
            
        case TableSectionProfiles:
        {
            CKSocialProfile *phone = _contact.socialProfiles[indexPath.row];
            cell.textLabel.text = phone.service;
            return cell;
        }
            
        case TableSectionURLs:
        {
            CKURL *phone = _contact.URLs[indexPath.row];
            cell.textLabel.text = phone.URLString;
            return cell;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self tableView:tableView numberOfRowsInSection:indexPath.section];

    if (indexPath.row == count - 1)
    {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Actions

- (void)actionSaveContact:(UIBarButtonItem *)sender
{
    
}

#pragma mark - Private


//
//- (void)ck_fillMap:(NSMutableDictionary *)map class:(Class)aClass
//{
//    [self ck_enumeratePropertiesOfClass:aClass usingBlock:^(NSString *name, __unsafe_unretained Class aClass) {
//        
//        if (aClass == [NSString class] || aClass == [NSDate class])
//        {
//            NSMutableArray *array = [map objectForKey:@"Contact"];
//            if (! array)
//            {
//                array = [[NSMutableArray alloc] init];
//                [map setObject:array forKey:@"Contact"];
//            }
//            [array addObject:name];
//        }
//        else if (aClass == [NSArray class])
//        {
//            Class subClass;
//            
//            if ([name isEqualToString:@"phones"])
//            {
//                subClass = [CKMutablePhone class];
//            }
//            else if ([name isEqualToString:@"emails"])
//            {
//                subClass = [CKMutableEmail class];
//            }
//            else if ([name isEqualToString:@"addresses"])
//            {
//                subClass = [CKAddress class];
//            }
//            else if ([name isEqualToString:@"instantMessengers"])
//            {
//                subClass = [CKMessenger class];
//            }
//            else if ([name isEqualToString:@"socialProfiles"])
//            {
//                subClass = [CKSocialProfile class];
//            }
//            else if ([name isEqualToString:@"URLs"])
//            {
//                subClass = [CKMutableURL class];
//            }
//            
//            NSMutableArray *array = [map objectForKey:name];
//            if (! array)
//            {
//                array = [[NSMutableArray alloc] init];
//                [map setObject:array forKey:name];
//            }
//            
//            [self ck_enumeratePropertiesOfClass:subClass usingBlock:^(NSString *name, __unsafe_unretained Class aClass) {
//                
//                [array addObject:name];
//                
//             }];
//        }
//        
//    }];
//}

@end
