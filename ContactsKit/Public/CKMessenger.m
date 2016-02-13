//
//  CKMessenger.m
//  ContactsKit
//
//  Created by Sergey Popov on 02/05/16.
//  Copyright (c) 2016 Sergey Popov <serj@ttitt.ru>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "CKMessenger_Private.h"
#import "CKAutoCoder.h"
#import "CKMacros.h"

@implementation CKMessenger

#pragma mark - Lifecycle

- (instancetype)initWithMessengerDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _username = [dictionary objectForKey:kABInstantMessageUsernameKey];
        _service = [dictionary objectForKey:kABInstantMessageServiceKey];
        _serviceType = [self ck_serviceWithString:_service];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKMessenger *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy->_username = [self.username copyWithZone:zone];
        copy->_service = [self.service copyWithZone:zone];
        copy->_serviceType = self.serviceType;
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutableMessenger *mutableCopy = [[CKMutableMessenger allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.username = [self.username copyWithZone:zone];
        mutableCopy.service = [self.service copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [aDecoder decodeIvarsWithObject:self ofClass:[CKMessenger class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeIvarsWithObject:self ofClass:[CKMessenger class] ignoreIvars:nil];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToMessenger:(CKMessenger *)messenger
{
    if (! messenger)
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.username, messenger.username))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.service, messenger.service))
    {
        return NO;
    }
    
    return (self.serviceType == messenger.serviceType);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKMessenger class]])
    {
        return NO;
    }
    
    return [self isEqualToMessenger:object];
}

- (NSUInteger)hash
{
    return self.username.hash ^ self.service.hash;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", [super description], self.service, self.username];
}

#pragma mark - Private

- (CKMessengerService)ck_serviceWithString:(NSString *)string
{
    if ([string isEqualToString:kABInstantMessageServiceAIM])
    {
        return CKMessengerServiceAIM;
    }
    else if ([string isEqualToString:kABInstantMessageServiceFacebook])
    {
        return CKMessengerServiceFacebook;
    }
    else if ([string isEqualToString:kABInstantMessageServiceGaduGadu])
    {
        return CKMessengerServiceGaduGadu;
    }
    else if ([string isEqualToString:kABInstantMessageServiceGoogleTalk])
    {
        return CKMessengerServiceGoogleTalk;
    }
    else if ([string isEqualToString:kABInstantMessageServiceICQ])
    {
        return CKMessengerServiceICQ;
    }
    else if ([string isEqualToString:kABInstantMessageServiceJabber])
    {
        return CKMessengerServiceJabber;
    }
    else if ([string isEqualToString:kABInstantMessageServiceMSN])
    {
        return CKMessengerServiceMSN;
    }
    else if ([string isEqualToString:kABInstantMessageServiceQQ])
    {
        return CKMessengerServiceQQ;
    }
    else if ([string isEqualToString:kABInstantMessageServiceSkype])
    {
        return CKMessengerServiceSkype;
    }
    else if ([string isEqualToString:kABInstantMessageServiceYahoo])
    {
        return CKMessengerServiceYahoo;
    }
    else
    {
        return CKMessengerServiceUnknown;
    }
}

- (NSString *)ck_serviceStringWithType:(CKMessengerService)type
{
    switch (type)
    {
        case CKMessengerServiceAIM:
            return kABInstantMessageServiceAIM;
            
        case CKMessengerServiceFacebook:
            return kABInstantMessageServiceFacebook;
        
        case CKMessengerServiceGaduGadu:
            return kABInstantMessageServiceGaduGadu;
        
        case CKMessengerServiceGoogleTalk:
            return kABInstantMessageServiceGoogleTalk;
            
        case CKMessengerServiceICQ:
            return kABInstantMessageServiceICQ;
            
        case CKMessengerServiceJabber:
            return kABInstantMessageServiceJabber;
            
        case CKMessengerServiceMSN:
            return kABInstantMessageServiceMSN;
        
        case CKMessengerServiceQQ:
            return kABInstantMessageServiceQQ;
        
        case CKMessengerServiceSkype:
            return kABInstantMessageServiceSkype;
            
        case CKMessengerServiceYahoo:
            return kABInstantMessageServiceYahoo;
            
        case CKMessengerServiceUnknown:
        default:
            return nil;
    }
}

#pragma mark - Public Instace

- (BOOL)addPropertiesToMultiValue:(ABMutableMultiValueRef)mutableMultiValueRef
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.username forKey:kABInstantMessageUsernameKey];
    [dictionary setValue:self.service forKey:kABInstantMessageServiceKey];
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#endif
}

@end

@implementation CKMutableMessenger

#pragma mark - Properties

@synthesize username, service, serviceType;

- (void)setService:(NSString *)aService
{
    service = aService;
    serviceType = [self ck_serviceWithString:aService];
}

- (void)setServiceType:(CKMessengerService)aServiceType
{
    serviceType = aServiceType;
    service = [self ck_serviceStringWithType:aServiceType];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [super mutableCopyWithZone:zone];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [aDecoder decodeIvarsWithObject:self ofClass:[CKMutableMessenger class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeIvarsWithObject:self ofClass:[CKMutableMessenger class] ignoreIvars:nil];
}


@end
