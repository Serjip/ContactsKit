//
//  CKAutoCoder.h
//  ContactsKit
//
//  Created by Sergey Popov on 03.02.16.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (AutoCoder)

- (void)enumerateIvarsOfClass:(Class)aClass usingBlock:(void (^)(NSString *name, const char *type, void *address))block;

@end

@interface NSCoder (AutoCoder)

- (void)encodeIvarsWithObject:(id)anObject ofClass:(Class)aClass ignoreIvars:(const void *)firstIvar, ... ;
- (void)decodeIvarsWithObject:(id)anObject ofClass:(Class)aClass ignoreIvars:(const void *)firstIvar, ... ;

@end
