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
    CKAddressBook *_book;
    NSArray *_contacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _book = [[CKAddressBook alloc] init];
    _book.fieldsMask = CKContactFieldAll;
    _book.unifyLinkedContacts = YES;
    _book.delegate = self;
    [_book startObserveChanges];
    
    [_book requestAccessWithCompletion:^(NSError *error) {
        
        if (! error)
        {
            [_book loadContacts];
        }
        
    }];
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

- (void)addressBookDidChnage:(CKAddressBook *)addressBook
{
    [_book loadContacts];
}

#pragma mark - CKAddressBookDelegate

- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts
{
    _contacts = contacts;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)actionRefresh:(NSButton *)sender
{
    [_book loadContacts];
}

@end
