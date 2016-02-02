//
//  ContactsKit_iOS_Tests.m
//  ContactsKit_iOS_Tests
//
//  Created by Sergey P on 01.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ContactsKit/ContactsKit.h>

@interface ContactsKit_iOS_Tests : XCTestCase

@property (nonatomic, strong) CKAddressBook *addressBook;

@end

@implementation ContactsKit_iOS_Tests

- (void)setUp
{
    [super setUp];
    self.addressBook = [CKAddressBook new];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAddContact
{
    CKMutableContact *contact = [CKMutableContact new];
    contact.firstName = @(arc4random()).stringValue;
    contact.lastName = @(arc4random()).stringValue;
    contact.middleName = @(arc4random()).stringValue;
    contact.nickname = @(arc4random()).stringValue;

    contact.company = @(arc4random()).stringValue;
    contact.jobTitle = @(arc4random()).stringValue;
    contact.department = @(arc4random()).stringValue;
    contact.note = @(arc4random()).stringValue;

    {
        CKMutablePhone *phone1 = [CKMutablePhone new];
        phone1.originalLabel = CKPhoneHomeFax;
        phone1.number = @(arc4random()).stringValue;
        contact.phones = @[ phone1 ];
    }
    
    {
        CKMutableEmail *email = [CKMutableEmail new];
        email.originalLabel = CKPhoneHomeFax;
        email.address = @(arc4random()).stringValue;
        contact.emails = @[ email ];
    }
    
    {
        CKMutableURL *url = [CKMutableURL new];
        url.originalLabel = CKPhoneHomeFax;
        url.URLString = @(arc4random()).stringValue;
        contact.URLs = @[ url ];
    }
    
    {
        CKMutableSocialProfile *socialProfile = [CKMutableSocialProfile new];
        socialProfile.URL = [NSURL URLWithString:@(arc4random()).stringValue];
        socialProfile.userIdentifier = @(arc4random()).stringValue;
        socialProfile.username = @(arc4random()).stringValue;
        socialProfile.service = @"facebook";
        contact.socialProfiles = @[ socialProfile ];
    }
    
    
    __block NSError *error = nil;
    XCTestExpectation *e1 = [self expectationWithDescription:@"expectation"];
    [self.addressBook addContact:contact completion:^(NSError *er) {
        error = er;
        [e1 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    XCTAssertNil(error);
    
    __block NSArray *contacts = nil;
    XCTestExpectation *e2 = [self expectationWithDescription:@"expectation"];
    [self.addressBook contactsWithMask:CKContactFieldAll uinify:NO sortDescriptors:nil filter:^BOOL(CKContact *ctn) {
        
        return [ctn isEqual:contact];
        
    } completion:^(NSArray *cnts, NSError *er) {
        
        contacts = cnts;
        error = er;
        
        [e2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    XCTAssertNil(error);
    XCTAssertEqual(contacts.count, 1);
    
    
}

@end
