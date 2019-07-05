//
//  ViewController.m
//  AppstoreVersionChecker
//
//  Created by New on 02/07/19.
//  Copyright © 2019 Personal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self checkForUpdateWithHandler:^(BOOL isUpdateAvailable) {
        if (isUpdateAvailable) {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Stream TV"
                                         message:@"Stream TV Application Update Available"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        }];
            
    
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];

        }
    }];
}


- (void)checkForUpdateWithHandler:(void(^)(BOOL isUpdateAvailable))updateHandler {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appID = infoDictionary[@"CFBundleIdentifier"];
    
    NSLog(@"App ID: %@",appID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSLog(@"iTunes Lookup URL for the app: %@", url.absoluteString);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *theTask = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url]
                                               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                   
                                                   NSDictionary *lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                   NSLog(@"iTunes Lookup Data: %@", lookup);
                                                   if (lookup && [lookup[@"resultCount"] integerValue] == 1){
                                                       NSString *appStoreVersion = lookup[@"results"][0][@"version"];
                                                       NSString *currentVersion = infoDictionary[@"CFBundleShortVersionString"];
                                                       
                                                       BOOL isUpdateAvailable = [appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending;
                                                       if (isUpdateAvailable) {
                                                           NSLog(@"\n\nNeed to update. Appstore version %@ is greater than %@",appStoreVersion, currentVersion);
                                                       }
                                                       if (updateHandler) {
                                                           updateHandler(isUpdateAvailable);
                                                       }
                                                   }
                                               }];
    [theTask resume];
}

@end
