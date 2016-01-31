//
//  CKLabel.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKLabel_Private.h"

NSString * const CKLabelHome = @"_$!<Home>!$_";
NSString * const CKLabelWork = @"_$!<Work>!$_";
NSString * const CKLabelOther = @"_$!<Other>!$_";

@implementation CKLabel

#pragma mark - Properties

- (NSString *)localizedLabel
{
#if TARGET_OS_IOS
    return (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)(self.originalLabel));
#elif TARGET_OS_MAC
    return (__bridge_transfer NSString *)ABCopyLocalizedPropertyOrLabel((__bridge CFStringRef)(self.originalLabel));
#endif
}

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super init];
    if(self)
    {        
        _originalLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKLabel *copy = [[[self class] alloc] init];
    if (copy)
    {
        copy->_originalLabel = [self.originalLabel copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutableLabel *mutableCopy = [[CKMutableLabel alloc] init];
    if (mutableCopy)
    {
        mutableCopy.originalLabel = [self.originalLabel copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _originalLabel = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(originalLabel))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_originalLabel forKey:NSStringFromSelector(@selector(originalLabel))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equal

- (BOOL)isEqualToLabel:(CKLabel *)label
{
    return [label.originalLabel isEqualToString:self.originalLabel];
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKLabel class]])
    {
        return NO;
    }
    
    return [self isEqualToLabel:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@", self, self.originalLabel];
}

@end

@implementation CKMutableLabel

@synthesize originalLabel;

@end
