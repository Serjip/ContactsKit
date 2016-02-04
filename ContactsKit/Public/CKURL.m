//
//  CKURL.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKURL.h"
#import "CKLabel_Private.h"
#import "CKMacros.h"

NSString * const CKURLHomePage = @"_$!<HomePage>!$_";

@implementation CKURL

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _URLString = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKURL *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_URLString = [self.URLString copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutableURL *mutableCopy = [[CKMutableURL allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.originalLabel = [self.originalLabel copyWithZone:zone];
        mutableCopy.URLString = [self.URLString copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _URLString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(URLString))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_URLString forKey:NSStringFromSelector(@selector(URLString))];
}

#pragma mark - Equality

- (BOOL)isEqualToURL:(CKURL *)URL
{
    if (! [super isEqual:URL])
    {
        return NO;
    }
    
    return CK_IS_EQUAL(self.URLString, URL.URLString);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKURL class]])
    {
        return NO;
    }
    
    return [self isEqualToURL:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.URLString, self.originalLabel];
}

#pragma mark - Class methods

+ (NSArray *)labels
{
    NSMutableArray *labels = [[super labels] mutableCopy];
    [labels addObject:CKURLHomePage];
    return labels;
}

#pragma mark - Instance

- (BOOL)setLabledValue:(ABMutableMultiValueRef)mutableMultiValue
{
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValue, (__bridge CFStringRef)(self.URLString), (__bridge CFStringRef)(self.originalLabel), NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValue, (__bridge CFTypeRef)(self.URLString), (__bridge CFStringRef)(self.originalLabel), NULL);
#endif
}

@end

@implementation CKMutableURL

@dynamic originalLabel;
@synthesize URLString;

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [super mutableCopyWithZone:zone];
}

@end
