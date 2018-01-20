//
//  ExportHelpController.h
//  Ringo
//
//  Created by Alexander Ivanov on 23.09.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "HelpController.h"
#import "AudioItem.h"

#import "UIAlertController+Convenience.h"

@interface ProgressController : HelpController

@property (strong, nonatomic) AudioItem *selectedItem;

@end
