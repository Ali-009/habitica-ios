//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGPartyViewController.h"
#import "HRPGAppDelegate.h"
#import "Task.h"
#import "Group.h"
#import "Quest.h"
#import "QuestCollect.h"
#import "ChatMessage.h"
@interface HRPGPartyViewController ()
@property HRPGManager *sharedManager;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HRPGPartyViewController
@synthesize managedObjectContext;
Group *party;
Quest *quest;
NSUserDefaults *defaults;
NSString *partyID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate*)[[UIApplication sharedApplication] delegate];
    _sharedManager = appdelegate.sharedManager;
    
    self.managedObjectContext = _sharedManager.getManagedObjectContext;
    defaults = [NSUserDefaults standardUserDefaults];
    partyID = [defaults objectForKey:@"partyID"];
    if (!partyID) {
        [_sharedManager fetchGroups:@"party" onSuccess:^(){
            partyID = [defaults objectForKey:@"partyID"];
            party = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            [self refresh];
        }onError:^() {
            
        }];
    } else {
        if ([[self.fetchedResultsController sections] count] > 0 && [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] > 0) {
            party = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
        [self fetchQuest];

    }

    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh {
    [_sharedManager fetchGroup:partyID onSuccess:^ () {
        [self.refreshControl endRefreshing];
        [self fetchQuest];
    } onError:^ () {
        [self.refreshControl endRefreshing];
        [_sharedManager displayNetworkError];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (party.questKey && [party.questHP integerValue] == 0) {
                return [quest.collect count] + 1;
            } else {
                return 1;
            }
        case 1: {
            if (party != nil && [party.chatmessages count] > 0) {
                return [party.chatmessages count];
            }
        }
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Party", nil);
            break;
        case 1:
            return NSLocalizedString(@"Chat", nil);
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (party.questKey || [party.questHP integerValue] == 0) {
            return 44;
        } else {
            return 100;
        }
    } else if (indexPath.section == 0) {
        return 44;
    } else {
        return 80;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellname;
    if (indexPath.section == 0 && indexPath.item == 0) {
        if (party.questKey == nil) {
            cellname = @"NoQuestCell";
        } else {
            if ([party.questHP integerValue] > 0) {
                cellname = @"BossQuestCell";
            } else {
                cellname = @"CollectQuestCell";
            }
        }
    } else if (indexPath.section == 0) {
        cellname = @"CollectItemQuestCell";
    } else {
        if (indexPath.section) {
            cellname = @"ChatCell";
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", partyID]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"party"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (party != nil) {
        if (indexPath.section == 0 && indexPath.item == 0) {
            if (party.questKey != nil) {
                UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
                titleLabel.text = quest.text;
                if ([party.questHP integerValue] > 0) {
                    
                    UILabel *lifeLabel = (UILabel*)[cell viewWithTag:2];
                    lifeLabel.text = [NSString stringWithFormat:@"%@ / %@", party.questHP, quest.bossHp];
                    UIProgressView *lifeBar = (UIProgressView*)[cell viewWithTag:3];
                    lifeBar.progress = ([party.questHP floatValue] / [quest.bossHp floatValue]);
                } else {
                    for (QuestCollect *collects in quest.collect) {
                        NSLog(@"%@", collects);
                    }
                }
            }
        } else if (indexPath.section == 0) {
            QuestCollect *collect = quest.collect[indexPath.item-1];
            UILabel *authorLabel = (UILabel*)[cell viewWithTag:1];
            authorLabel.text = collect.text;
            if ([collect.count integerValue] == [collect.collectCount integerValue]) {
                authorLabel.textColor = [UIColor grayColor];
            } else {
                authorLabel.textColor = [UIColor blackColor];
            }
            
            UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
            textLabel.text = [NSString stringWithFormat:@"%@/%@", collect.collectCount, collect.count];
        } else if (indexPath.section == 1) {
            ChatMessage *message = (ChatMessage*)party.chatmessages[indexPath.item];
            UILabel *authorLabel = (UILabel*)[cell viewWithTag:1];
            authorLabel.text = message.user;
            
            UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
            textLabel.text = message.text;
        }
    }
}


-(void) fetchQuest {
    if (party.questKey) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quest" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", party.questKey]];
        NSError *error;
        quest = [managedObjectContext executeFetchRequest:fetchRequest error:&error][0];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end