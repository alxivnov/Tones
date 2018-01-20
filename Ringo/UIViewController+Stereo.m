//
//  UIViewController+Stereo.m
//  Ringtonic
//
//  Created by Alexander Ivanov on 02/08/16.
//  Copyright © 2016 Alexander Ivanov. All rights reserved.
//

#import "UIViewController+Stereo.h"
#import "Global.h"
#import "Localized.h"

#import "UIRateController.h"

#import "Answers+Convenience.h"
#import "SKInAppPurchase.h"
#import "UIAlertController+Convenience.h"
#import "UIViewController+Convenience.h"
#import "VKHelper.h"

@implementation UIViewController (Stereo)

- (void)presentPurchase:(void(^)(BOOL success))completion {
	SKInAppPurchase *purchase = [SKInAppPurchase purchaseWithProductIdentifier:GLOBAL.purchaseID];

	if (completion)
		[purchase requestProduct:^(SKProduct *product, NSError *error) {
			SKPayment *payment = [purchase requestPayment:product handler:^(NSArray<SKPaymentTransaction *> *transactions) {
				BOOL success = transactions.lastObject.transactionState == SKPaymentTransactionStatePurchased;

				if (completion)
					completion(success);

//				[GLOBAL setPurchaseSuccess:success];

				[Answers logPurchaseWithPrice:product.price currency:product.priceLocale.currencyCode success:@(success) itemName:product.localizedTitle itemType:Nil itemId:product.productIdentifier customAttributes:dic__(@"error", transactions.lastObject.error.shortDescription, @"VK", [[VKHelper instance] wakeUpSession].userId)];

				for (SKPaymentTransaction *transaction in transactions)
					[Answers logError:transaction.error];
			}];

			[Answers logStartCheckoutWithPrice:product.price currency:product.priceLocale.currencyCode itemCount:@(payment.quantity) customAttributes:dic__(@"error", error.shortDescription, @"VK", [[VKHelper instance] wakeUpSession].userId)];

			[Answers logError:error];
		}];

	[Answers logAddToCartWithPrice:purchase.price currency:purchase.currencyCode itemName:purchase.localizedTitle itemType:Nil itemId:purchase.productIdentifier customAttributes:dic_(@"VK", [[VKHelper instance] wakeUpSession].userId)];
}

- (void)presentSheetWithTitle:(NSString *)title from:(id)sender completion:(void(^)(BOOL success))completion {
	if (!completion)
		return;

	SKInAppPurchase *purchase = [SKInAppPurchase purchaseWithProductIdentifier:GLOBAL.purchaseID];

	if (purchase.purchased || !purchase.localizedPrice || [NSRateController instance].action < GLOBAL.tonesLimit || __screenshot)
		completion(YES);
	else
		[self presentSheetWithTitle:purchase.localizedTitle message:purchase.localizedDescription cancelActionTitle:self.iPhone ? [Localized mono] : Nil destructiveActionTitle:Nil otherActionTitles:[NSArray arrayWithObject:purchase.localizedPrice withObject:self.iPhone ? Nil : [Localized mono]] from:sender configuration:^(UIAlertController *instance) {
			[instance.actions.firstObject setActionColor:GLOBAL.globalTintColor];
			[instance.actions.firstObject setActionImage:[UIImage templateImage:@"volume-line-30"]];

			[instance.actions.lastObject setActionImage:[UIImage templateImage:@"volume-30"]];
		} completion:^(UIAlertController *instance, NSInteger index) {
			if (index == 0)
				[self presentPurchase:^(BOOL success) {
					if (completion)
						completion(success);

					[GLOBAL setPurchaseSuccess:success];
				}];
			else {/* if (index == ALERT_CANCEL)*/
				[self presentPurchase:Nil];

				if (completion)
					completion(NO);

				[GLOBAL setPurchaseSuccess:NO];
			}
		}];
}

- (void)presentSheet:(AudioItem *)item from:(id)sender completion:(void (^)(BOOL))completion {
	if (!completion)
		return;

	if (item.segment)
		[self presentSheetWithTitle:[item description] from:sender completion:completion];
	else
		completion(YES);
}

@end
