//
//  CKSocialContact.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKSocialProfile_Private.h"

#if TARGET_OS_IOS

#define kABSocialProfileURLKey              (__bridge_transfer NSString *)kABPersonSocialProfileURLKey
#define kABSocialProfileUsernameKey         (__bridge_transfer NSString *)kABPersonSocialProfileUsernameKey
#define kABSocialProfileUserIdentifierKey   (__bridge_transfer NSString *)kABPersonSocialProfileUserIdentifierKey
#define kABSocialProfileServiceKey          (__bridge_transfer NSString *)kABPersonSocialProfileServiceKey

#endif

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
        _serviceType = [self socialNetworkTypeFromString:_service];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKSocialProfile *copy = [[[self class] alloc] init];
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
    CKMutableSocialProfile *mutableCopy = [[CKMutableSocialProfile alloc] init];
    if (mutableCopy)
    {
        mutableCopy.URL = [self.URL copyWithZone:zone];
        mutableCopy.username = [self.username copyWithZone:zone];
        mutableCopy.userIdentifier = [self.userIdentifier copyWithZone:zone];
        mutableCopy.service = [self.service copyWithZone:zone];
        mutableCopy.serviceType = self.serviceType;
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _URL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:NSStringFromSelector(@selector(URL))];
        _username = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(username))];
        _userIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(userIdentifier))];
        _service = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(service))];
        _serviceType = (NSUInteger)[aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(serviceType))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_URL forKey:NSStringFromSelector(@selector(URL))];
    [aCoder encodeObject:_username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeObject:_userIdentifier forKey:NSStringFromSelector(@selector(userIdentifier))];
    [aCoder encodeObject:_service forKey:NSStringFromSelector(@selector(service))];
    [aCoder encodeInteger:(NSInteger)_serviceType forKey:NSStringFromSelector(@selector(serviceType))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToSocialProfile:(CKSocialProfile *)socialProfile
{
    if (self.serviceType != socialProfile.serviceType)
    {
        return NO;
    }
    
    if (! [self.service isEqualToString:socialProfile.service])
    {
        return NO;
    }
    
    if (! [self.username isEqualToString:socialProfile.username])
    {
        return NO;
    }
    
    if (! [self.userIdentifier isEqualToString:socialProfile.userIdentifier])
    {
        return NO;
    }
    
    if (! [self.URL.absoluteString isEqualToString:socialProfile.URL.absoluteString])
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

#pragma mark - Private

- (CKSocialProfileService)socialNetworkTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"facebook"])
    {
        return CKSocialProfileServiceFacebook;
    }
    else if ([string isEqualToString:@"twitter"])
    {
        return CKSocialProfileServiceTwitter;
    }
    else if ([string isEqualToString:@"linkedin"])
    {
        return CKSocialProfileServiceLinkedIn;
    }
    else if ([string isEqualToString:@"flickr"])
    {
        return CKSocialProfileServiceFlickr;
    }
    else if ([string isEqualToString:@"myspace"])
    {
        return CKSocialProfileServiceMyspace;
    }
    else
    {
        return CKSocialProfileServiceUnknown;
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

@synthesize URL, username, userIdentifier, service, serviceType;

@end
