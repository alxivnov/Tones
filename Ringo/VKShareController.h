//
//  VKShareController.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 03/05/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioItem.h"

#import "Dispatch+Convenience.h"

@interface VKShareController : UITableViewController <UITextViewDelegate>

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) VKAudioItem *audio;
@property (strong, nonatomic) NSURL *link;

@property (strong, nonatomic) AudioItem *selectedItem;

@end
