//
//  ServerController.m
//  Ringo
//
//  Created by Alexander Ivanov on 08.10.15.
//  Copyright © 2015 Alexander Ivanov. All rights reserved.
//

#import "ServerController.h"
#import "Global.h"
#import "Localized.h"
#import "Tone.h"

#import "UIViewController+Answers.h"
#import "UIViewController+Stereo.h"

#import "Dispatch+Convenience.h"
#import "NSObject+Convenience.h"
#import "UIViewController+Convenience.h"

@implementation ServerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)loggingName {
	return @"Edit";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self startLogging];

	if (!self.selectedItem.tones)
		[self.selectedItem fetchTones:^(NSArray *tones) {
			[GCD main:^{
				self.navigationItem.rightBarButtonItems = tones.count ? [self.navigationItem.rightBarButtonItems arrayByAddingObject:[[UIBarButtonItem alloc] initWithTitle:[Localized tones:tones.count] style:UIBarButtonItemStylePlain target:self action:@selector(tonesBarButtonItemAction:)]] : @[ self.navigationItem.rightBarButtonItem ];
			}];
		}];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self endLogging];
}

- (IBAction)tonesBarButtonItemAction:(id)sender {
	[self performSegueWithIdentifier:GUI_ONLINE sender:self.selectedItem];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];

	if ([segue.identifier isEqualToString:GUI_ONLINE])
		[segue.destinationViewController forwardSelector:@selector(setSelectedItem:) withObject:sender nextTarget:UIViewControllerNextTarget(YES)];
}

- (IBAction)select:(UIStoryboardSegue *)segue {
	AudioItem *item = [segue.sourceViewController forwardSelector:@selector(selectedItem) nextTarget:UIViewControllerNextTarget(YES)];
	if (item.segment)
		self.selectedItem.segment = item.segment;
}

- (IBAction)unwind:(UIStoryboardSegue *)segue {
	
}

- (IBAction)doneBarButtonAction:(UIBarButtonItem *)sender {
	[self presentSheet:self.selectedItem from:sender completion:^(BOOL success) {
		[self performSegueWithIdentifier:GUI_SELECT sender:sender];
	}];
}

@end
