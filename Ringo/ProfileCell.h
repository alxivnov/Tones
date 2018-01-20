//
//  ProfileCell.h
//  Ringtonic
//
//  Created by Alexander Ivanov on 03/08/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell <UITextFieldDelegate>

@property (assign, nonatomic) NSUInteger countOfTones;
@property (assign, nonatomic) NSUInteger countOfTimes;

@end
