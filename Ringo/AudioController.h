//
//  AudioController.h
//  Ringo
//
//  Created by Alexander Ivanov on 07.07.15.
//  Copyright (c) 2015 Alexander Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioPlayer.h"

#define AudioItemArtworkSize CGSizeMake(44.0, 44.0)

@interface AudioController : UITableViewController

@property (strong, nonatomic, readonly) AudioPlayer *player;

@property (strong, nonatomic, readonly) NSArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;
- (AudioItem *)itemAtIndex:(NSUInteger)index;

- (NSAttributedString *)attributedTitle:(AudioItem *)item font:(UIFont *)font;
- (NSString *)title:(AudioItem *)item;
- (NSAttributedString *)attributedSubtitle:(AudioItem *)item font:(UIFont *)font;
- (NSString *)subtitle:(AudioItem *)item;
- (NSString *)detail:(AudioItem *)item time:(NSTimeInterval)time;
- (float)progress:(AudioItem *)item time:(NSTimeInterval)time;
- (AudioSegment *)segment:(AudioItem *)item;

- (NSInteger)numberOfLoops;

- (NSArray *)accessoryImages:(AudioItem *)item;
- (void)accessoryImageWithIndex:(NSUInteger)index tappedForRowWithIndexPath:(NSIndexPath *)indexPath;

- (UIImage *)playImage:(AudioItem *)item;
- (UIImage *)stopImage:(AudioItem *)item;

@end
