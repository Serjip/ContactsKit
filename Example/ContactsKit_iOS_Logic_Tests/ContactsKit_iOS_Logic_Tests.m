//
//  ContactsKit_iOS_Logic_Tests.m
//  ContactsKit_iOS_Logic_Tests
//
//  Created by Sergey P on 03.02.16.
//  Copyright © 2016 Sergey Popov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ContactsKit/ContactsKit.h>

#import <ContactsKit/CKAutoCoder.h>
#import <objc/runtime.h>

@interface Node : NSObject {
    NSString *_node;
}

- (void)enumerate;

@end

@implementation Node

- (void)enumerate
{
    NSLog(@"%s", class_getName([self class]));
    
    [self enumerateIvarsOfClass:[self class] usingBlock:^(NSString *name, const char *type, void *address) {
        NSLog(@"%@ %@", name, self.class);
    }];
}

- (Class)metaClass:(Class)aClass
{
    NSLog(@"Check %@", NSStringFromClass(aClass));
    
    if (class_isMetaClass(aClass))
    {
        return aClass;
    }
    
    return [self metaClass:class_getSuperclass(aClass)];
}

@end

@interface SubNode : Node {
    NSString *_subnode;
}
@end

@implementation SubNode

- (void)enumerate
{
    [super enumerate];
    
    NSLog(@"%@", NSStringFromClass(object_getClass(self)));
    
    [self enumerateIvarsOfClass:[self class] usingBlock:^(NSString *name, const char *type, void *address) {
        NSLog(@"%@ %@", name, self.class);
    }];
}

@end


@interface ContactsKit_iOS_Logic_Tests : XCTestCase

@property (nonatomic, strong) CKAddress *address;

@end

@implementation ContactsKit_iOS_Logic_Tests

- (void)setUp
{
    [super setUp];

    CKMutableAddress *address = [CKMutableAddress new];
    address.street = @"Stroiteley street 1 - 33";
    address.city = @"Moskow";
    address.ZIP = @"117331";
    
    self.address = address;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEqualityOfAddress
{
    XCTAssertEqualObjects(self.address, [self.address mutableCopy]);
    XCTAssertEqualObjects(self.address, [self.address copy]);
    XCTAssertNotEqualObjects(self.address, nil);
    XCTAssertNotEqualObjects([CKAddress new], nil);
    XCTAssertEqualObjects([CKAddress new], [CKAddress new]);
}

- (void)testEqualityOfPhone
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
}

- (void)testEnumaratoin
{
    [[SubNode new] enumerate];
}

@end
