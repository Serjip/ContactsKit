//
//  ContactsKit_iOS_Logic_Tests.m
//  ContactsKit_iOS_Logic_Tests
//
//  Created by Sergey P on 03.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ContactsKit/ContactsKit.h>

@interface ContactsKit_iOS_Logic_Tests : XCTestCase

@end

@implementation ContactsKit_iOS_Logic_Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAddress
{
    CKMutableAddress *address = [[CKMutableAddress alloc] init];
    address.street = @"Stroiteley street 1 - 33";
    address.city = @"Moskow";
    address.ZIP = @"117331";
    
    XCTAssertEqualObjects(address, [address mutableCopy]);
    XCTAssertEqualObjects(address, [address copy]);
    XCTAssertNotEqualObjects(address, nil);
    XCTAssertNotEqualObjects([CKAddress new], nil);
    XCTAssertEqualObjects([CKAddress new], [CKMutableAddress new]);

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:address];
    XCTAssertEqualObjects([NSKeyedUnarchiver unarchiveObjectWithData:data], address);
}

- (void)testContact
{
    CKMutableContact *contact = [[CKMutableContact alloc] init];
    contact.firstName = @"Sergey";
}

- (void)testPhone
{
    CKMutablePhone *phone = [CKMutablePhone new];
    phone.number = @"+79111364580";
    phone.originalLabel = CKLabelHome;
    
    XCTAssertEqualObjects(phone, [phone mutableCopy]);
    XCTAssertEqualObjects(phone, [phone copy]);
    XCTAssertNotEqualObjects([CKPhone new], phone);
    XCTAssertNotEqualObjects(phone, [CKPhone new]);
    XCTAssertNotEqualObjects(phone, [[CKPhone new] copy]);
    XCTAssertNotEqualObjects([[CKPhone new] copy], phone);

    XCTAssertNotEqualObjects([[CKPhone new] mutableCopy], phone);
    XCTAssertNotEqualObjects(phone, [[CKPhone new] mutableCopy]);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:phone];
    XCTAssertEqualObjects([NSKeyedUnarchiver unarchiveObjectWithData:data], phone);
}

@end
