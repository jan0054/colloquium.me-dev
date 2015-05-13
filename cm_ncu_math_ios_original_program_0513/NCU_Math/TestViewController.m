//
//  TestViewController.m
//  SQuInt2014
//
//  Created by csjan on 9/2/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)btn1:(UIButton *)sender {
    NSLog(@"BTN1 PRESSED");
    for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
        }
    }
}

- (IBAction)btn2:(UIButton *)sender {
}

- (IBAction)btn3:(UIButton *)sender {
}

- (void) upload_person
{
    PFObject *person = [PFObject objectWithClassName:@"person"];
    person[@"first_name"] = @"cs";
    person[@"last_name"] = @"jan";
    person[@"email"] = @"csjan@tapgo.cc";
    person[@"is_user"] = @NO;
    person[@"link"] = @"http://tapgo.cc";
    [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_poi
{
    PFObject *poi = [PFObject objectWithClassName:@"poi"];
    poi[@"name"] = @"Hilton wherever";
    poi[@"description"] = @"big hotel";
    poi[@"phone"] = @"0975087264";
    poi[@"address"] = @"somewheresomewhere road";
    PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:25.01122 longitude:121.53318];
    poi[@"coord"] = location;
    UIImage *image = [UIImage imageNamed:@"poi_nightview"];
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"poi_nightview.png" data:imageData];
    poi[@"photo"] = imageFile;
    [poi saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_career
{
    PFObject *career = [PFObject objectWithClassName:@"career"];
    career[@"name"] = @"csj";
    career[@"school"] = @"u of csj";
    career[@"position"] = @"warlord";
    career[@"salary"] = @"0";
    career[@"note"] = @"http://tapgo.cc";
    [career saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_location
{
    PFObject *location = [PFObject objectWithClassName:@"location"];
    location[@"name"] = @"csj hall";
    location[@"capacity"] = @10;
    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_abstract
{
    PFObject *abstract = [PFObject objectWithClassName:@"abstract"];
    abstract[@"name"] = @"csj abstract";
    abstract[@"content"] = @"abstract blahblahblah";
    [abstract saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_poster
{
    PFObject *poster = [PFObject objectWithClassName:@"poster"];
    poster[@"name"] = @"csj poster";
    poster[@"description"] = @"poster blahblahblah";
    [poster saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}

- (void) upload_talk
{
    PFObject *talk = [PFObject objectWithClassName:@"talk"];
    talk[@"name"] = @"csj talk";
    talk[@"description"] = @"talk blahblahblah";
    talk[@"start_time"] = [NSDate date];
    talk[@"end_time"] = [NSDate date];
    [talk saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"post success");
        } else {
            NSLog(@"post error: %@", error);
        }
    }];
}














@end
