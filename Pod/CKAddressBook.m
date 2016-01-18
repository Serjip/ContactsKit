//
//  CKAddressBook.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKAddressBook.h"
#import <Contacts/Contacts.h>
#import "CKContact_Private.h"

@implementation CKAddressBook {
@private
    ABAddressBookRef _addressBookRef;
    dispatch_queue_t _addressBookQueue;
}

#pragma mark - Properties

- (CKAddressBookAccess)access
{
    return [CKAddressBook access];
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        CFErrorRef errorRef = NULL;
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &errorRef);
        if (errorRef)
        {
            NSLog(@"%@", (__bridge_transfer NSString *)CFErrorCopyFailureReason(errorRef));
            return nil;
        }
        NSString *name = [NSString stringWithFormat:@"com.alterplay.addressbook.%ld", (long)self.hash];
        _addressBookQueue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], NULL);
        self.fieldsMask = CKContactFieldDefault;
    }
    return self;
}

- (void)dealloc
{
    [self stopObserveChanges];
    if (_addressBookRef)
    {
        CFRelease(_addressBookRef);
    }
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_addressBookQueue);
#endif
}

#pragma mark - Public

+ (CKAddressBookAccess)access
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            return CKAddressBookAccessDenied;

        case kABAuthorizationStatusAuthorized:
            return CKAddressBookAccessGranted;

        default:
            return CKAddressBookAccessUnknown;
    }
}

- (void)loadContacts
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeFieldMask = self.mergeFieldsMask;
    NSArray *descriptors = [self.sortDescriptors copy];
    
    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef errorRef) {
        dispatch_async(_addressBookQueue, ^{
            NSArray *array = nil;
            NSError *error = nil;
            
            if (granted)
            {
                CFArrayRef peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
                NSUInteger contactCount = (NSUInteger)CFArrayGetCount(peopleArrayRef);
                NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:contactCount];
                NSMutableSet *linkedContactsIDs = [NSMutableSet set];
                
                for (NSUInteger i = 0; i < contactCount; i++)
                {
                    ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, i);
                    
                    // Checking already added contacts
                    if ([linkedContactsIDs containsObject:@(ABRecordGetRecordID(recordRef))])
                    {
                        continue;
                    }
                    
                    CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fieldMask];
                    if (! [self.delegate respondsToSelector:@selector(addressBook:shouldAddContact:)] || [self.delegate addressBook:self shouldAddContact:contact])
                    {
                        [contacts addObject:contact];
                    }
                    
                    CFArrayRef linkedPeopleArrayRef = ABPersonCopyArrayOfAllLinkedPeople(recordRef);
                    NSUInteger linkedCount = (NSUInteger)CFArrayGetCount(linkedPeopleArrayRef);
                    
                    if (linkedCount > 1)
                    {
                        // Merge linked contact info
                        for (NSUInteger j = 0; j < linkedCount; j++)
                        {
                            ABRecordRef linkedRecordRef = CFArrayGetValueAtIndex(linkedPeopleArrayRef, j);
                            
                            // Don't merge the same contact
                            if (linkedRecordRef == recordRef)
                            {
                                continue;
                            }
                            
                            if (mergeFieldMask)
                            {
                                [contact mergeLinkedRecordRef:linkedRecordRef fieldMask:mergeFieldMask];
                                [linkedContactsIDs addObject:@(ABRecordGetRecordID(linkedRecordRef))];
                            }
                        }
                    }
                    
                    CFRelease(linkedPeopleArrayRef);
                }
                [contacts sortUsingDescriptors:descriptors];
                array = [NSArray arrayWithArray:contacts];
                CFRelease(peopleArrayRef);
            }
            else if (errorRef)
            {
                error = (__bridge NSError *)errorRef;
            }
            
            if (error)
            {
                if ([self.delegate respondsToSelector:@selector(addressBook:didFailLoadContacts:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate addressBook:self didFailLoadContacts:error];
                    });
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(addressBook:didLoadContacts:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate addressBook:self didLoadContacts:array];
                    });
                }
            }
        });
    });
    
    
#warning Added contact request
    CNContactStore *store = [[CNContactStore alloc] init];
    NSArray *keys = @[CNContactIdentifierKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactBirthdayKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    NSError *error = nil;
    
    NSMutableArray *array = [NSMutableArray array];
    [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        CKContact *c2 = [[CKContact alloc] initWithContact:contact fieldMask:CKContactFieldPhones];
        [array addObject:c2];
    }];
    
    NSLog(@"%@",array);
}

- (void)startObserveChanges
{
    [self stopObserveChanges];
    
    ABAddressBookRegisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
}

- (void)stopObserveChanges
{
    ABAddressBookUnregisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
}

#pragma mark - external change callback

static void CKAddressBookExternalChangeCallback(ABAddressBookRef addressBookRef, CFDictionaryRef __unused info, void *context)
{
    ABAddressBookRevert(addressBookRef);
    CKAddressBook *addressBook = (__bridge CKAddressBook *)(context);
    
    if ([addressBook.delegate respondsToSelector:@selector(addressBookDidChnage:)])
    {
        [addressBook.delegate addressBookDidChnage:addressBook];
    }
}

@end
