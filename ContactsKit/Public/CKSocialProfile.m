//
//  CKSocialContact.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
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

#import "CKSocialProfile_Private.h"

#import "CKMacros.h"
#import "CKAutoCoder.h"

@implementation CKSocialProfile

#pragma mark - Lifecycle

- (instancetype)initWithSocialDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {        
        _URL = [NSURL URLWithString:[dictionary objectForKey:kABSocialProfileURLKey]];
        _username = [dictionary objectForKey:kABSocialProfileUsernameKey];
        _userIdentifier = [dictionary objectForKey:kABSocialProfileUserIdentifierKey];
        _service = [dictionary objectForKey:kABSocialProfileServiceKey];
        _serviceType = [self ck_socialNetworkTypeFromString:_service];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKSocialProfile *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy->_URL = [self.URL copyWithZone:zone];
        copy->_username = [self.username copyWithZone:zone];
        copy->_userIdentifier = [self.userIdentifier copyWithZone:zone];
        copy->_service = [self.service copyWithZone:zone];
        copy->_serviceType = self.serviceType;
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    CKMutableSocialProfile *mutableCopy = [[CKMutableSocialProfile allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.URL = [self.URL copyWithZone:zone];
        mutableCopy.username = [self.username copyWithZone:zone];
        mutableCopy.userIdentifier = [self.userIdentifier copyWithZone:zone];
        mutableCopy.service = [self.service copyWithZone:zone];
// Don't need to copy service type, it sould set automaticatly form the sertter
// mutableCopy.serviceType = self.serviceType;
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [aDecoder decodeIvarsWithObject:self ofClass:[CKSocialProfile class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeIvarsWithObject:self ofClass:[CKSocialProfile class] ignoreIvars:nil];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToSocialProfile:(CKSocialProfile *)socialProfile
{
    if (! socialProfile)
    {
        return NO;
    }
    
    if (self.serviceType != socialProfile.serviceType)
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.service, socialProfile.service))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.username, socialProfile.username))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.userIdentifier, socialProfile.userIdentifier))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.URL, socialProfile.URL))
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKSocialProfile class]])
    {
        return NO;
    }
    
    return [self isEqualToSocialProfile:object];
}

- (NSUInteger)hash
{
    return self.service.hash ^ self.username.hash ^ self.userIdentifier.hash ^ self.URL.hash;
}

#pragma mark - Private

- (CKSocialProfileService)ck_socialNetworkTypeFromString:(NSString *)string
{
    if ([string isEqualToString:kABSocialProfileServiceFacebook])
    {
        return CKSocialProfileServiceFacebook;
    }
    else if ([string isEqualToString:kABSocialProfileServiceTwitter])
    {
        return CKSocialProfileServiceTwitter;
    }
    else if ([string isEqualToString:kABSocialProfileServiceLinkedIn])
    {
        return CKSocialProfileServiceLinkedIn;
    }
    else if ([string isEqualToString:kABSocialProfileServiceFlickr])
    {
        return CKSocialProfileServiceFlickr;
    }
    else if ([string isEqualToString:kABSocialProfileServiceMySpace])
    {
        return CKSocialProfileServiceMyspace;
    }
    else if ([string isEqualToString:kABSocialProfileServiceSinaWeibo])
    {
        return CKSocialProfileServiceSinaWeibo;
    }
    else
    {
        return CKSocialProfileServiceUnknown;
    }
}

- (NSString *)ck_stringForomSocialNetwork:(CKSocialProfileService)socialNetwork
{
    switch (socialNetwork)
    {
        case CKSocialProfileServiceFacebook:
            return kABSocialProfileServiceFacebook;
            
        case CKSocialProfileServiceTwitter:
            return kABSocialProfileServiceTwitter;
            
        case CKSocialProfileServiceLinkedIn:
            return kABSocialProfileServiceLinkedIn;
            
        case CKSocialProfileServiceFlickr:
            return kABSocialProfileServiceFlickr;
            
        case CKSocialProfileServiceMyspace:
            return kABSocialProfileServiceMySpace;
            
        case CKSocialProfileServiceSinaWeibo:
            return kABSocialProfileServiceSinaWeibo;
            
        case CKSocialProfileServiceUnknown:
        default:
            return nil;
    }
}

#pragma mark - Instance

- (BOOL)addPropertiesToMultiValue:(ABMutableMultiValueRef)mutableMultiValueRef
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.URL.absoluteString forKey:kABSocialProfileURLKey];
    [dictionary setValue:self.username forKey:kABSocialProfileUsernameKey];
    [dictionary setValue:self.userIdentifier forKey:kABSocialProfileUserIdentifierKey];
    [dictionary setValue:self.service forKey:kABSocialProfileServiceKey];
    
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#endif
}

@end

@implementation CKMutableSocialProfile

#pragma mark - Properties

@synthesize URL, username, userIdentifier, service, serviceType;

- (void)setService:(NSString *)aService
{
    service = aService;
    serviceType = [self ck_socialNetworkTypeFromString:aService];
}

- (void)setServiceType:(CKSocialProfileService)aServiceType
{
    serviceType = aServiceType;
    service = [self ck_stringForomSocialNetwork:aServiceType];
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
        [aDecoder decodeIvarsWithObject:self ofClass:[CKMutableSocialProfile class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeIvarsWithObject:self ofClass:[CKMutableSocialProfile class] ignoreIvars:nil];
}

@end
