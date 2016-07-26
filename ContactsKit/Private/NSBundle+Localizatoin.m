//
//  NSBundle+Localizatoin.m
//  Pods
//
//  Created by Sergey P on 26.07.16.
//
//

#import "NSBundle+Localizatoin.h"

@implementation NSBundle (Localizatoin)

+ (instancetype)ck_mainBundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Set ContactsKit.bundle
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"ContactsKit" withExtension:@"bundle"];
        NSAssert(bundleURL, @"ContactsKit.bundle not found, add bundle to the project.");
        bundle = [NSBundle bundleWithURL:bundleURL];
    });
    return bundle;
}

@end
