//
//  CKTableViewController.m
//  ContactsKit
//
//  Created by Sergey Popov on 18.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKTableViewController.h"
#import "CKTableViewCell.h"
#import "CKDetailsTableViewController.h"

#import <AddressBook/AddressBook.h>
#import <ContactsKit/ContactsKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CKTableViewController () <CKAddressBookDelegate>

@end

@implementation CKTableViewController {
    NSArray *_contacts;
    CKAddressBook *_book;
}

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        _book = [[CKAddressBook alloc] init];
        _book.delegate = self;
        [_book startObserveChanges];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[CKTableViewCell nib] forCellReuseIdentifier:[CKTableViewCell cellReuseIdentifier]];

    [_book requestAccessWithCompletion:^(NSError *error) {
        
        if (! error)
        {
            [_book loadContacts];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] init];
            alert.title = @"Access denied";
            alert.message = @"Settings > Security and Privacy > Application Permissions > Allow contacts";
            [alert addButtonWithTitle:@"OK"];
            [alert show];
        }
        
    }];
    
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddContact:)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshContacts:)];
    self.navigationItem.leftBarButtonItems = @[refreshItem, self.editButtonItem];
    self.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CKTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
    CKContact *contact = [_contacts objectAtIndex:indexPath.row];
    [cell setContact:contact];
    return cell;
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CKContact *contact = [_contacts objectAtIndex:indexPath.row];
        [_book deleteContact:contact.mutableCopy completion:^(NSError *error) {
            
            if (! error)
            {
                NSMutableArray *contacts = _contacts.mutableCopy;
                [contacts removeObjectAtIndex:indexPath.row];
                _contacts = contacts;
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.title = @"Cannot delete contact";
                alert.message = error.localizedDescription;
                [alert addButtonWithTitle:@"OK"];
                [alert show];
            }
            
        }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKContact *contact = [_contacts objectAtIndex:indexPath.row];

    CKDetailsTableViewController *vc = [[CKDetailsTableViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CKAddressBookDelegate

- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts
{
    _contacts = contacts;
    [self.tableView reloadData];
}

- (BOOL)addressBook:(CKAddressBook *)addressBook shouldLoadContact:(CKContact *)contact
{
    return contact.phones.count > 0;
}

- (void)addressBookDidChnage:(CKAddressBook *)addressBook
{
    [addressBook loadContacts];
}

#pragma mark - Actions

- (void)actionRefreshContacts:(UIBarButtonItem *)sender
{
    [_book loadContacts];
}

- (void)actionAddContact:(UIBarButtonItem *)sender
{
    CKDetailsTableViewController *vc = [[CKDetailsTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
