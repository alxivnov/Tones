//
//  User.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 03.08.16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "CKObjectBase.h"

@interface User : CKObjectBase <CKObjectBase>

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger vkUserID;

@end
