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
    // Insert code here
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
