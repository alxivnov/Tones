//
//  VKLoginController.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 19.05.17.
//  Copyright © 2017 Alexander Ivanov. All rights reserved.
//

#import "VKLoginController.h"

#import "NSURLSession+Convenience.h"
#import "VKAPI.h"

#import "VKHelper.h"

#import "Global.h"

@interface VKLoginController ()
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSString *> *accessTokens;

@property (strong, nonatomic) NSIndexPath *selected;
@end

@implementation VKLoginController

__synthesize(NSDictionary *, accessTokens, (@{
//											@"vk mp3 mod"			:	@"4996844"	,
//*											@"Android"				:	@"2274003"	,
//*											@"iPhone"				:	@"3140623"	,
//											@"iPad"					:	@"3682744"	,
//*											@"WP"					:	@"3502561"	,
//*											@"Windows"				:	@"3697615"	,
//											@"Vika for Blackberry"	:	@"3032107"	,
											@"Kate Mobile"			:	@"2685278"	,	// KateMobileAndroid/39.3-384 (Android 4.2.2; SDK 17; x86; Genymotion Custom Phone - 4.2.2 - API 17 - 768x1280_2; en)
//											@"Lynt"					:	@"3469984"	,
//											@"Instagram"			:	@"3698024"	,
//											@"stellio"				:	@"4856776"	,
//											@"snapster для android"	:	@"4580399"	,
//											@"snapster для iPhone"	:	@"4986954"	,
//											@"Telegram"				:	@"5422643"	,
//											@"vkmd"					:	@"4967124"	,
//											@"Candy"				:	@"5044491"	,
//											@"VFeed"				:	@"4083558"	,
//											@"Xbox 720"				:	@"3900090"	,
//											@"бутерброд"			:	@"3900094"	,
//											@"домофон"				:	@"3900098"	,
//											@"калькулятор"			:	@"5023680"	,
//											@"psp"					:	@"3900102"	,
//											@"Вутюг"				:	@"3998121"	,
//											@"ВОкно"				:	@"4147789"	,
//											@"Ад ¯_(ツ)_¯"			:	@"5014514"	,
//											@"Google Glass™"		:	@"5036399"	,
//											@"Mail.ru Агент"		:	@"2023699"	,
//											@"SweetVK"				:	@"4856309"	,
//											@"полиглот"				:	@"4630925"	,
//											@"amberfrog"			:	@"4445970"	,
//											@"mira"					:	@"3757640"	,
//											@"zeus"					:	@"4831060"	,
//											@"messenger"			:	@"4894723"	,
//											@"Phoenix"				:	@"4994316"	,
//											@"rocket"				:	@"4757672"	,
//											@"ВКонтакте ГЕО"		:	@"4973839"	,
//**											@"Fast VK"				:	@"5021699"	,
//											@"FLiPSi"				:	@"3933207"	,
//											@"VBots"				:	@"4645689"	,
//											@"Вечный онлайн"		:	@"4187848"	,
//											@"4ert"					:	@"5116270"	,
//											@"Голубиная почта"		:	@"5116357"	,
//											@"Голубиная почта"		:	@"5116373"	,
//*											@"vk master" : @"3226016",
//											@"Vinci" : @"5554806",
//											@"VK API" : @"3116505",
											}))

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.search?v=5.52&access_token=%@&q=beatles", [[VKHelper instance] wakeUpSession].accessToken]] sendRequestWithMethod:@"GET" header:@{ @"User-Agent" : @"KateMobileAndroid/39.3-384 (Android 4.2.2; SDK 17; x86; Genymotion Custom Phone - 4.2.2 - API 17 - 768x1280_2; en)" } body:Nil completion:^(NSData *data) {
		NSStringEncoding encoding = 0;
		NSString *string = [NSString stringWithData:data encoding:&encoding];
		[string log:@"string:"];

		id json = [NSJSONSerialization JSONObjectWithData:data];
		[json log:@"json:"];
	}];
}
*/
- (IBAction)rightBarButtonItemAction:(UIBarButtonItem *)sender {
	[VKSdk forceLogout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accessTokens.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
	cell.textLabel.text = self.accessTokens.allKeys[indexPath.row];
	cell.detailTextLabel.text = self.accessTokens.allValues[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selected = indexPath;

//	[VKSdk forceLogout];

	[VKHelper initializeWithAppId:self.accessTokens.allValues[indexPath.row] apiVersion:GLOBAL.vkVersion permissions:VK_PERMISSIONS];

	[[VKHelper instance] authorize];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

//	[UIPasteboard generalPasteboard].string = @"4915168168759";
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	[[VKAPI api] searchAudio:@"рингтон" handler:^(NSArray<VKAudioItem *> *items) {
		[self presentAlertWithTitle:self.accessTokens.allKeys[self.selected.row] message:[items debugDescription] cancelActionTitle:@"OK" destructiveActionTitle:Nil otherActionTitles:Nil completion:^(UIAlertController *instance, NSInteger index) {
			[GCD main:^{
				[self.tableView cellForRowAtIndexPath:self.selected].accessoryType = UITableViewCellAccessoryCheckmark;
			}];
		}];
	}];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	[self presentAlertWithTitle:self.accessTokens.allKeys[self.selected.row] message:[authorizationError debugDescription] cancelActionTitle:@"Cancel" destructiveActionTitle:Nil otherActionTitles:Nil completion:^(UIAlertController *instance, NSInteger index) {
		[GCD main:^{
			[self.tableView cellForRowAtIndexPath:self.selected].accessoryType = UITableViewCellAccessoryNone;
		}];
	}];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
