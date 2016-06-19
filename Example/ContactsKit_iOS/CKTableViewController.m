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
    NSString *_addressBookPath;
    NSArray *_contacts;
    CKAddressBook *_book;
}

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
            _addressBookPath = [URL.path stringByAppendingPathComponent:@"addressBook"];
        }];
        
        _book = [NSKeyedUnarchiver unarchiveObjectWithFile:_addressBookPath];
        if (! _book)
        {
            _book = [[CKAddressBook alloc] init];
            _book.observeContactsDiff = YES;
            _book.fieldsMask = CKContactFieldAll;
            _book.unifyResults = YES;
        }
        
        _book.delegate = self;
        [_book startObserveChanges];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationApplicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification object:nil];
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
            [_book fetchContacts];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return NO;
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

- (void)addressBook:(CKAddressBook *)addressBook didFetchContacts:(NSArray<CKContact *> *)contacts
{
    _contacts = contacts;
    [self.tableView reloadData];
}

- (BOOL)addressBook:(CKAddressBook *)addressBook shouldFetchContact:(CKContact *)contact
{
    return contact.phones.count > 0;
}

- (void)addressBookDidChnage:(CKAddressBook *)addressBook
{
    [addressBook fetchContacts];
}

- (void)addressBook:(CKAddressBook *)addressBook didChangeForType:(CKAddressBookChangeType)type contactsIds:(NSArray<NSString *> *)ids
{
    switch (type)
    {
        case CKAddressBookChangeTypeAdd:
            NSLog(@"Added ids %@", ids);
            break;
            
        case CKAddressBookChangeTypeDelete:
            NSLog(@"Deleted ids %@", ids);
            break;
            
        case CKAddressBookChangeTypeUpdate:
            NSLog(@"Updated ids %@", ids);
            break;
    }
    
    [addressBook fetchContacts];
}

#pragma mark - Notificaions

- (void)notificationApplicationWillTerminate:(NSNotification *)aNotificaion
{
    [NSKeyedArchiver archiveRootObject:_book toFile:_addressBookPath];
}

#pragma mark - Actions

- (void)actionRefreshContacts:(UIBarButtonItem *)sender
{
    [_book fetchContacts];
}

- (void)actionAddContact:(UIBarButtonItem *)sender
{
    CKDetailsTableViewController *vc = [[CKDetailsTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
