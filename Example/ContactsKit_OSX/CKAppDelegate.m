//
//  CKAppDelegate.m
//  ContactsKit_OSX
//
//  Created by Sergey Popov on 22.01.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import "CKAppDelegate.h"
#import <ContactsKit/ContactsKit.h>

@interface CKAppDelegate () <CKAddressBookDelegate>

@end

@implementation CKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CKAddressBook *addressbook = [[CKAddressBook alloc] init];
    addressbook.fieldsMask = CKContactFieldAll;
    addressbook.mergeFieldsMask = CKContactFieldAll;
    addressbook.delegate = self;
    
    [addressbook loadContacts];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

#pragma mark - CKAddressBookDelegate

- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts
{
    NSLog(@"%@", contacts);
}

@end
