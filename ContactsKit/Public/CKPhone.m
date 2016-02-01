//
//  CKPhone.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKPhone.h"
#import "CKLabel_Private.h"

NSString * const CKPhoneiPhone = @"iPhone";
NSString * const CKPhoneMobile = @"_$!<Mobile>!$_";
NSString * const CKPhoneMain = @"_$!<Main>!$_";
NSString * const CKPhoneHomeFax = @"_$!<HomeFAX>!$_";
NSString * const CKPhoneWorkFax = @"_$!<WorkFAX>!$_";
NSString * const CKPhoneOtherFax = @"";
NSString * const CKPhonePager = @"_$!<Pager>!$_";

@implementation CKPhone

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKPhone *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_number = [self.number copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutablePhone *mutableCopy = [super mutableCopyWithZone:zone];
    if (mutableCopy)
    {
        mutableCopy.number = [self.number copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _number = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(number))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_number forKey:NSStringFromSelector(@selector(number))];
}

#pragma mark - Equality

- (BOOL)isEqualToPhone:(CKPhone *)phone
{
    return ([phone.number isEqualToString:self.number] && [phone.originalLabel isEqual:self.originalLabel]);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKPhone class]])
    {
        return NO;
    }
    
    return [self isEqualToPhone:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.number, self.originalLabel];
}

#pragma mark - Class methods

+ (NSArray *)labels
{
    NSMutableArray *labels = [[super labels] mutableCopy];
    [labels addObjectsFromArray:@[CKPhoneiPhone, CKPhoneMobile, CKPhoneMain, CKPhoneHomeFax, CKPhoneWorkFax, CKPhoneOtherFax, CKPhonePager]];
    return labels;
}

#pragma mark - Instance

- (BOOL)setLabledValue:(ABMutableMultiValueRef)mutableMultiValue
{
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValue, (__bridge CFStringRef)(self.number), (__bridge CFStringRef)(self.originalLabel), NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValue, (__bridge CFTypeRef)(self.number), (__bridge CFStringRef)(self.originalLabel), NULL);
#endif
}

@end

@implementation CKMutablePhone

@dynamic originalLabel;
@synthesize number;

@end
