//
//  CKContactTests.m
//  ContactsKit
//
//  Created by Sergey Popov on 02.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ContactsKit/ContactsKit.h>

@interface CKContact_iOS_Tests : XCTestCase
@property (nonatomic, strong) CKAddressBook *addressBook;
@property (nonatomic, strong) CKContact *randContact;
@end

@implementation CKContact_iOS_Tests

- (void)setUp
{
    [super setUp];
    self.addressBook = [CKAddressBook new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRequestAccess
{
    XCTestExpectation *ex = [self expectationWithDescription:@"access"];
    [self.addressBook requestAccessWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Invalid access");
        [ex fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testGetRandomContact
{
    [self testRequestAccess];
    
    __block CKContact *contact = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:@"ex"];
    [self.addressBook contactsWithMask:CKContactFieldAll uinify:YES sortDescriptors:nil filter:nil completion:^(NSArray *contacts, NSError *error) {
        XCTAssertNil(error, @"Error not nil");
        
        contact = [contacts objectAtIndex:arc4random() % contacts.count];
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.f handler:nil];
    
    XCTAssertNotNil(contact, @"No contact found");
    self.randContact = contact;
}

- (void)testCoder
{
    [self testGetRandomContact];
    
    CKContact *c1 = self.randContact;
    XCTAssertNotNil(c1, @"Tested contact is nil");
    
    NSData *contactData = [NSKeyedArchiver archivedDataWithRootObject:c1];
    CKContact *c2 = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
    
    [self isEqualToContact:c1 contact:c2];
}

- (void)testMutableContact
{
    [self testGetRandomContact];
    
    CKContact *c1 = self.randContact;
    XCTAssertNotNil(c1, @"Tested contact is nil");
    
    CKMutableContact *c2 = [c1 mutableCopy];
    
    [self isEqualToContact:c1 contact:c2];
}

- (void)testContactCopy
{
    [self testGetRandomContact];
    
    CKContact *c1 = self.randContact;
    XCTAssertNotNil(c1, @"Tested contact is nil");
    
    CKContact *c2 = [c1 copy];
    
    [self isEqualToContact:c1 contact:c2];
}

- (void)testMutableContactCopy
{
    [self testGetRandomContact];
    
    CKContact *c1 = self.randContact;
    XCTAssertNotNil(c1, @"Tested contact is nil");
    
    CKMutableContact *c2 = [c1 mutableCopy];
    CKMutableContact *c3 = [c2 copy];
    
    [self isEqualToContact:c2 contact:c3];
}

- (void)testMutablyCoding
{
    [self testGetRandomContact];
    
    CKContact *c1 = self.randContact;
    XCTAssertNotNil(c1, @"Tested contact is nil");
    CKMutableContact *c2 = [c1 mutableCopy];
    
    
    NSData *contactData = [NSKeyedArchiver archivedDataWithRootObject:c2];
    CKMutableContact *c3 = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
    
    [self isEqualToContact:c2 contact:c3];
}

#pragma mark - Common methods

- (void)isEqualToContact:(CKContact *)c1 contact:(CKContact *)c2
{
    XCTAssertEqualObjects(c1.identifier, c2.identifier);
    
    XCTAssertEqualObjects(c1.firstName, c2.firstName);
    XCTAssertEqualObjects(c1.lastName, c2.lastName);
    XCTAssertEqualObjects(c1.middleName, c2.middleName);
    XCTAssertEqualObjects(c1.nickname, c2.nickname);
    
    XCTAssertEqualObjects(c1.company, c2.company);
    XCTAssertEqualObjects(c1.jobTitle, c2.jobTitle);
    XCTAssertEqualObjects(c1.department, c2.department);
    
    XCTAssertEqualObjects(c1.note, c2.note);
    
    XCTAssertEqualObjects(c1.imageData, c2.imageData);
    XCTAssertEqualObjects(c1.thumbnailData, c2.thumbnailData);
    
    XCTAssertEqualObjects(c1.phones, c2.phones);
    XCTAssertEqualObjects(c1.emails, c2.emails);
    XCTAssertEqualObjects(c1.URLs, c2.URLs);
    XCTAssertEqualObjects(c1.socialProfiles, c2.socialProfiles);
    XCTAssertEqualObjects(c1.addresses, c2.addresses);
    
    XCTAssertEqualObjects(c1.birthday, c2.birthday);
    XCTAssertEqualObjects(c1.creationDate, c2.creationDate);
    XCTAssertEqualObjects(c1.modificationDate, c2.modificationDate);
    
    XCTAssertEqualObjects(c1, c2, @"The contacts is not equal");
}


@end
