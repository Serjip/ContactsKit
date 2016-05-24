//
//  CKContact_Private.h
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

#import "CKContact.h"
#import <AddressBook/AddressBook.h>

@interface CKContact ()

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask;
- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef mergeMask:(CKContactField)mergeMask;

@end

@interface CKMutableContact ()

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSData *thumbnailData;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *modificationDate;

- (BOOL)setRecordRef:(ABRecordRef)recordRef error:(NSError **)error;

@end
