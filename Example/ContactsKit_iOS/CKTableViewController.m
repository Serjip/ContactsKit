//
//  CKTableViewController.m
//  ContactsKit
//
//  Created by Sergey Popov on 18.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKTableViewController.h"
#import "CKTableViewCell.h"

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

    [_book loadContacts];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshContacts:)];
    self.navigationItem.leftBarButtonItem = item;
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
    
    CFErrorRef errorRef = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &errorRef);
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, contact.identifier.intValue);
    
    ABPersonViewController *vc = [[ABPersonViewController alloc] init];
    
    vc.addressBook = addressBookRef;
    vc.displayedPerson = recordRef;
    
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

@end
