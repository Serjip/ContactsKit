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
    CKMutableContact *contact = [[CKMutableContact alloc] init];
    self = [super initWithObject:contact ofClass:[CKContact class]];
    if (self)
    {
        _contact = contact;
    }
    return self;
}

- (instancetype)initWithContact:(CKContact *)aContact
{
    CKMutableContact *contact = aContact.mutableCopy;
    self = [super initWithObject:contact ofClass:[CKContact class]];
    if (self)
    {
        _contact = contact;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSaveContact:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.editing = YES;
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
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (! cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"Add new";
    
    NSInteger count = [tableView numberOfRowsInSection:indexPath.section];
    
    switch ((TableSection)indexPath.section)
    {
        case TableSectionPhones:
            if (indexPath.row < count - 1)
            {
                CKPhone *phone = _contact.phones[indexPath.row];
                cell.textLabel.text = phone.number;
                return cell;
            }
            else
            {
                return cell;
            }
            
        case TableSectionEmails:
        {
            if (indexPath.row < count - 1)
            {
                CKEmail *phone = _contact.emails[indexPath.row];
                cell.textLabel.text = phone.address;
                return cell;
            }
            else
            {
                return cell;
            }
        }
            
        case TableSectionAddresses:
        {
            if (indexPath.row < count - 1)
            {
                CKAddress *phone = _contact.addresses[indexPath.row];
                cell.textLabel.text = phone.street;
                return cell;
            }
            else
            {
                return cell;
            }
        }
            
        case TableSectionMessengers:
        {
            if (indexPath.row < count - 1)
            {
                CKMessenger *phone = _contact.instantMessengers[indexPath.row];
                cell.textLabel.text = phone.service;
                return cell;
            }
            else
            {
                return cell;
            }
        }
            
        case TableSectionProfiles:
        {
            if (indexPath.row < count - 1)
            {
                CKSocialProfile *phone = _contact.socialProfiles[indexPath.row];
                cell.textLabel.text = phone.service;
                return cell;
            }
            else
            {
                return cell;
            }
        }
            
        case TableSectionURLs:
        {
            if (indexPath.row < count - 1)
            {
                CKURL *phone = _contact.URLs[indexPath.row];
                cell.textLabel.text = phone.URLString;
                return cell;
            }
            else
            {
                return cell;
            }
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableSection)indexPath.section)
    {
        case TableSectionAddresses:
        case TableSectionEmails:
        case TableSectionMessengers:
        case TableSectionPhones:
        case TableSectionProfiles:
        case TableSectionURLs:
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableSection)indexPath.section)
    {
        case TableSectionAddresses:
        case TableSectionEmails:
        case TableSectionMessengers:
        case TableSectionPhones:
        case TableSectionProfiles:
        case TableSectionURLs:
        {
            NSInteger count = [tableView numberOfRowsInSection:indexPath.section];;
            if (indexPath.row == count - 1)
            {
                return UITableViewCellEditingStyleInsert;
            }
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Actions

- (void)actionSaveContact:(UIBarButtonItem *)sender
{
    
}

#pragma mark - Private

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
