//
//  CKContactsViewController.m
//  ContactsKit_OSX
//
//  Created by Sergey Popov on 22.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKContactsViewController.h"
#import <ContactsKit/ContactsKit.h>

@interface CKContactsViewController () <NSTableViewDataSource, NSTableViewDelegate, CKAddressBookDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

@implementation CKContactsViewController {
    CKAddressBook *_addressBook;
    NSArray *_contacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addressBook = [[CKAddressBook alloc] init];
    _addressBook.fieldsMask = CKContactFieldAll;
    _addressBook.mergeMask = CKContactFieldAll;
    _addressBook.delegate = self;
    [_addressBook loadContacts];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _contacts.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    CKContact *contact = [_contacts objectAtIndex:row];
    
    
    if ([tableColumn.identifier isEqualToString:@"firstname"])
    {
        return contact.firstName;
    }
    else if ([tableColumn.identifier isEqualToString:@"lastname"])
    {
        return contact.lastName;
    }
    else if ([tableColumn.identifier isEqualToString:@"phone"])
    {
        NSArray *phones = [contact.phones valueForKeyPath:@"number"];
        return [phones componentsJoinedByString:@", "];
    }
    else if ([tableColumn.identifier isEqualToString:@"email"])
    {
        NSArray *emails = [contact.emails valueForKeyPath:@"address"];
        return [emails componentsJoinedByString:@", "];
    }
    
    return nil;
}

#pragma mark - NSTableViewDelegate

#pragma mark - CKAddressBookDelegate

- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts
{
    _contacts = contacts;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)actionRefresh:(NSButton *)sender
{
    [_addressBook loadContacts];
}

@end
