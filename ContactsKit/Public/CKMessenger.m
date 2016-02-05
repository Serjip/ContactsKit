//
//  CKMessenger.m
//  ContactsKit
//
//  Created by Sergey P on 05.02.16.
//
//

#import "CKMessenger_Private.h"
#import "CKMacros.h"

//extern NSString * const kABInstantMessageProperty					AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER; // Instant Messaging - kABMultiDictionaryProperty
//extern NSString * const kABInstantMessageServiceAIM			AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// AIM
//extern NSString * const kABInstantMessageServiceFacebook	AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Facebook
//extern NSString * const kABInstantMessageServiceGaduGadu	AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Gadu-Gadu
//extern NSString * const kABInstantMessageServiceGoogleTalk	AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Google Talk
//extern NSString * const kABInstantMessageServiceICQ			AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// ICQ
//extern NSString * const kABInstantMessageServiceJabber		AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Jabber
//extern NSString * const kABInstantMessageServiceMSN			AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// MSN
//extern NSString * const kABInstantMessageServiceQQ			AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// QQ
//extern NSString * const kABInstantMessageServiceSkype		AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Skype
//extern NSString * const kABInstantMessageServiceYahoo		AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER;		// Yahoo!

@implementation CKMessenger

#pragma mark - Lifecycle

- (instancetype)initWithMessengerDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _username = [dictionary objectForKey:kABInstantMessageUsernameKey];
        _service = [dictionary objectForKey:kABInstantMessageServiceKey];
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
        copy->_service = [self.city copyWithZone:zone];
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

#pragma mark - Private

- (CKMessengerService)ck_serviceWithString:(NSString *)string
{
    
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

@synthesize username, service;

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
