//
//  WeiboCache.m
//  Rainbow
//
//  Created by Luke on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboCache.h"
static NSMutableDictionary *relationshipNameEntityName;
@implementation WeiboCache

+(void) initialize{
	relationshipNameEntityName = [[NSMutableDictionary alloc]init];
	[relationshipNameEntityName setObject:@"WeiboUser" forKey:@"user"];
	[relationshipNameEntityName setObject:@"WeiboUser" forKey:@"sender"];
	[relationshipNameEntityName setObject:@"WeiboUser" forKey:@"recipient"];
	[relationshipNameEntityName setObject:@"WeiboStatus" forKey:@"status"];
	[relationshipNameEntityName setObject:@"WeiboStatus" forKey:@"retweeted_status"];
	[relationshipNameEntityName setObject:@"WeiboComment" forKey:@"reply_comment"];
}

-(NSString*)entityNameWithRelationshipName:(NSString*)relationshipName{
	
	return [relationshipNameEntityName valueForKey:relationshipName];
}


- (NSManagedObjectContext *) managedObjectContext {
	if(managedObjectContext) return managedObjectContext;
	id appDelegate = [NSApp delegate];
	managedObjectContext=[appDelegate managedObjectContext];
	return managedObjectContext;
}



-(void)commitEditingAndSave{
	NSError *error = nil;
	if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

-(void)saveStatusTimeline:(NSArray*)statuses withType:(NSString*)type{
	for(NSDictionary *status in statuses){
		NSMutableDictionary * statusTimeline = [[[NSMutableDictionary alloc] init] autorelease];
		[statusTimeline setValue:[status valueForKey:@"id"] forKey:@"id"];
		[statusTimeline setValue:type forKey:@"type"];
		[statusTimeline setValue:status forKey:@"status"];
		[self managedObjectFromDictionary:statusTimeline 
						   withEntityName:@"WeiboStatusTimeline" 
				 withManagedObjectContext:[self managedObjectContext]];
	}
	[self commitEditingAndSave];
}

#pragma mark ManagedObject & Dictionary Transform
-(NSDictionary*)dictionaryFromManagedObject:(NSManagedObject*)managedObject
{
	NSDictionary *attributesByName = [[managedObject entity] attributesByName];
	NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
	NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
	[valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
	for (NSString *relationshipName in [relationshipsByName allKeys]) {
		NSRelationshipDescription *description = [relationshipsByName objectForKey:relationshipName];
		if (![description isToMany]) {
			[valuesDictionary setValue:[self dictionaryFromManagedObject:[managedObject valueForKey:relationshipName]]];
			continue;
		}
		NSSet *relationshipObjects = [managedObject valueForKey:relationshipName];
		NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
		for (NSManagedObject *relationshipObject in relationshipObjects) {
			[relationshipArray addObject:[self dictionaryFromManagedObject:relationshipObject]];
		}
		[valuesDictionary setObject:relationshipArray forKey:relationshipName];
	}
	return [valuesDictionary autorelease];
}

-(NSArray*)dataArrayFromManagedObjects:(NSArray*)managedObjects
{
	NSMutableArray *dataArray = [[NSMutableArray alloc] init];
	for (NSManagedObject *managedObject in managedObjects) {
		[dataArray addObject:[self dictionaryFromManagedObject:managedObject]];
	}
	return [dataArray autorelease];
}


-(NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)valueDictionary
								withEntityName:(NSString*)entityName
					  withManagedObjectContext:(NSManagedObjectContext*)moc
{
	//首先得判断这个managedObject是否已经存在
	NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
	[managedObject setValuesForKeysWithDictionary:valueDictionary];
	NSDictionary *relationshipsByName=[[managedObject entity] relationshipsByName];
	for (NSString *relationshipName in [relationshipsByName allKeys]) {
		NSRelationshipDescription *description = [relationshipsByName objectForKey:relationshipName];
		if (![description isToMany]) {
			NSDictionary *childStructureDictionary = [valueDictionary objectForKey:relationshipName];
			NSManagedObject *childObject = [self managedObjectFromDictionary:childStructureDictionary 
																  withEntityName:[self entityNameWithRelationshipName:relationshipName]
													withManagedObjectContext:moc];
			[managedObject setValue:childObject forKey:relationshipName];
			continue;
		}
		NSMutableSet *relationshipSet = [managedObject valueForKey:relationshipName];
		NSArray *relationshipArray = [valueDictionary objectForKey:relationshipName];
		for (NSDictionary *childStructureDictionary in relationshipArray) {
			NSManagedObject *childObject = [self managedObjectFromDictionary:childStructureDictionary 
																  withEntityName:[self entityNameWithRelationshipName:relationshipName]
													withManagedObjectContext:moc];
			[relationshipSet addObject:childObject];
		}
	}
	return managedObject;
}

@end
