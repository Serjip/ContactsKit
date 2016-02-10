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
    self = [super initWithObject:contact ofClass:[CKMutableContact class]];
    if (self)
    {
        _contact = contact;
    }
    return self;
}

- (instancetype)initWithContact:(CKContact *)aContact
{
    CKMutableContact *contact = aContact.mutableCopy;
    self = [super initWithObject:contact ofClass:[CKMutableContact class]];
    if (self)
    {
        _contact = contact;
        self.editing = YES;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *array = nil;
        
        switch ((TableSection)indexPath.section)
        {
            case TableSectionAddresses:
                array = [_contact mutableArrayValueForKey:@"addresses"];
                break;
            case TableSectionEmails:
                array = [_contact mutableArrayValueForKey:@"emails"];
                break;
            case TableSectionMessengers:
                array = [_contact mutableArrayValueForKey:@"instantMessengers"];
                break;
            case TableSectionPhones:
                array = [_contact mutableArrayValueForKey:@"phones"];
                break;
            case TableSectionProfiles:
                array = [_contact mutableArrayValueForKey:@"socialProfiles"];
                break;
            case TableSectionURLs:
                array = [_contact mutableArrayValueForKey:@"URLs"];
                break;
        }
        
        [array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        Class class;
        switch ((TableSection)indexPath.section)
        {
            case TableSectionAddresses:
                class = [CKMutableAddress class];
                break;
                
            case TableSectionEmails:
                class = [CKMutableEmail class];
                break;
                
            case TableSectionMessengers:
                class = [CKMutableMessenger class];
                
                break;
            case TableSectionPhones:
                class = [CKMutablePhone class];
                break;
                
            case TableSectionProfiles:
                class = [CKMutableSocialProfile class];
                break;
            
            case TableSectionURLs:
                class = [CKMutableURL class];
                break;
        }
        
        id object = [[class alloc] init];
        CKPropertyTableViewController *vc = [[CKPropertyTableViewController alloc] initWithObject:object ofClass:class];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
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

#pragma mark - CKPropertyTableViewControllerDelegate

- (void)propertyTableController:(CKPropertyTableViewController *)vc didSaveObject:(id)object
{
    if (vc == self)
    {
        [[CKAddressBook new] updateContact:_contact completion:^(NSError *error) {
            
            if (! error)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.title = @"Cannot save contact";
                alert.message = error.localizedDescription;
                [alert addButtonWithTitle:@"OK"];
                [alert show];
            }
            
        }];
    }
    else
    {
        NSIndexPath *indexPath = nil;
        
        if ([object isKindOfClass:[CKPhone class]])
        {
            [[_contact mutableArrayValueForKey:@"phones"] addObject:object];
            NSInteger index = [_contact.phones indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionPhones];
        }
        else if ([object isKindOfClass:[CKEmail class]])
        {
            [[_contact mutableArrayValueForKey:@"emails"] addObject:object];
            NSInteger index = [_contact.emails indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionEmails];
        }
        else if ([object isKindOfClass:[CKAddress class]])
        {
            [[_contact mutableArrayValueForKey:@"addresses"] addObject:object];
            NSInteger index = [_contact.addresses indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionAddresses];
        }
        else if ([object isKindOfClass:[CKMessenger class]])
        {
            [[_contact mutableArrayValueForKey:@"instantMessengers"] addObject:object];
            NSInteger index = [_contact.instantMessengers indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionMessengers];
        }
        else if ([object isKindOfClass:[CKSocialProfile class]])
        {
            [[_contact mutableArrayValueForKey:@"socialProfiles"] addObject:object];
            NSInteger index = [_contact.socialProfiles indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionProfiles];
        }
        else if ([object isKindOfClass:[CKURL class]])
        {
            [[_contact mutableArrayValueForKey:@"URLs"] addObject:object];
            NSInteger index = [_contact.URLs indexOfObject:object];
            indexPath = [NSIndexPath indexPathForRow:index inSection:TableSectionURLs];
        }
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
