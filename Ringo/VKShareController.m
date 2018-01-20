//
//  VKShareController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 03/05/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "VKShareController.h"

#import "AudioItem+Export.h"
#import "AudioItem+Import.h"
#import "AudioPlayer.h"
#import "Global.h"
#import "Localized.h"

#import "NSObject+Convenience.h"
#import "UIActivityIndicatorView+Convenience.h"
#import "UINavigationController+Convenience.h"

#import "VKHelper.h"

#import <Crashlytics/Answers.h>

#define KEY_VK @"VK"
#define KEY_TONE @"Tone"
#define KEY_SUCCESS @"success"
#define KEY_METHOD @"method"

@interface VKShareController ()
@property (weak, nonatomic) IBOutlet UILabel *toSubtitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *linkTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkSubtitleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *audioCell;

@property (strong, nonatomic) VKGroup *vkGroup;
@property (strong, nonatomic) VKPhoto *vkPhoto;
@property (strong, nonatomic) VKAudioItem *vkAudio;

@property (strong, nonatomic) AudioPlayer *player;
@end

@implementation VKShareController

- (NSString *)message {
	return [_messageTextView.text containsString:URL_HASHTAG] ? _messageTextView.text : [[NSArray arrayWithObject:_messageTextView.text withObject:URL_HASHTAG] componentsJoinedByString:STR_SPACE];
}

- (void)setMessage:(NSString *)message {
	self.messageTextView.text = message;
}

- (void)setPhoto:(UIImage *)photo {
	_photo = photo;

	self.photoImageView.image = photo;
}

- (void)setAudio:(VKAudioItem *)audio {
	_audio = audio;

	self.audioCell.textLabel.text = audio.artist;
	self.audioCell.detailTextLabel.text = audio.title;
}

- (void)setLink:(NSURL *)link {
	_link = link;

	AudioItem *item = [AudioItem createWithDictionary:[link queryDictionary]];
	self.linkTitleLabel.text = [item description];
	self.linkSubtitleLabel.text = [item.segment description];
}

- (AudioPlayer *)player {
	if (!_player)
		_player = [AudioPlayer new];

	return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.messageTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

	self.player = Nil;
}

- (void)textViewDidChange:(UITextView *)textView {
	[self.tableView beginUpdates];

	CGSize size = [textView.attributedText size];
	if (textView.frame.size.height < size.height * ceil(size.width / textView.bounds.size.width))
		[textView sizeToFit];

	[self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 1 && indexPath.row == 0 ? self.messageTextView.frame.size.height
		: indexPath.section == 1 && indexPath.row == 1 ? fmin(tableView.bounds.size.height, tableView.bounds.size.width)
		: [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!self.selectedItem)
		return;

	if (/*self.message || */self.photo || self.audio || self.link)
		return;

	self.message = [self.selectedItem description];
	self.photo = self.selectedItem.image;
	self.link = self.selectedItem.vkShareURL;

	[self.messageTextView sizeToFit];
	[self.messageTextView becomeFirstResponder];

	[self.selectedItem lookupInVK:^(VKAudioItem *audio) {
		self.vkAudio = audio;

		if (!audio)
			return;
		
		[GCD main:^{
			self.audioCell.textLabel.text = audio.artist;
			self.audioCell.detailTextLabel.text = audio.title;

			self.audioCell.hidden = NO;
		}];
	}];

	[VKHelper uploadWallPhoto:self.photo handler:^(VKPhoto *photo) {
		self.vkPhoto = photo;

		[GCD main:^{
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}];
	}];

	[self.navigationController.navigationBar progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.messageTextView resignFirstResponder];

	[self.player stopItem:Nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0.0)
		[self.messageTextView resignFirstResponder];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
	[Answers logShareWithMethod:KEY_VK contentName:[self.selectedItem description] contentType:KEY_TONE contentId:[self.selectedItem identifier] customAttributes:@{ KEY_SUCCESS : @"NO", KEY_METHOD : @"cancelAction:" }];

	[self performSegueWithIdentifier:GUI_UNWIND sender:Nil];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
	[self startActivityIndication:UIActivityIndicatorViewStyleWhiteLarge message:[Localized waiting]];

	[VKHelper postMessage:self.message attachments:[NSArray arrayWithObject:self.vkPhoto.attachmentString withObject:self.vkAudio.attachmentString withObject:self.link] ownerID:self.vkGroup ? 0 - self.vkGroup.id.integerValue : 0 handler:^(NSUInteger postID) {
		[self stopActivityIndication];

		[Answers logShareWithMethod:KEY_VK contentName:[self.selectedItem description] contentType:KEY_TONE contentId:[self.selectedItem identifier] customAttributes:@{ KEY_SUCCESS : postID > 0 ? @"YES" : @"NO", KEY_METHOD : @"doneAction:" }];

		[self performSegueWithIdentifier:GUI_UNWIND sender:Nil];
	}];
}

- (IBAction)select:(UIStoryboardSegue *)segue {
	self.vkGroup = [segue.sourceViewController forwardSelector:@selector(selectedItem) nextTarget:UIViewControllerNextTarget(YES)];

	self.toSubtitleLabel.text = self.vkGroup ? self.vkGroup.name : [Localized myProfile];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)) {
		AudioItem *item = self.vkAudio ? [AudioItem createWithAudioItem:self.vkAudio] : self.selectedItem;
		AudioSegment *segment = self.vkAudio && indexPath.row == 2 ? self.selectedItem.segment : Nil;

		if (item && ![self.player stopItem:item segment:segment])
			[self.player playItem:item segment:segment numberOfLoops:1 handler:^(NSTimeInterval currentTime) {
				[GCD main:^{
					UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

					cell.imageView.image = currentTime == NSTimeIntervalSince1970 ? cell.imageView.highlightedImage : [UIImage originalImage:IMG_STOP_VK];

					[self.navigationController.navigationBar setProgress:segment ? (currentTime - segment.startTime) / [segment segmentDuration] : currentTime / item.duration animated:YES];
				}];
			}];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

@end
