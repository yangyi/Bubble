//
//  WeiboCache.h
//  Rainbow
//
//  Created by Luke on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface WeiboCache : NSObject {
    NSManagedObjectContext *managedObjectContext;

}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


-(void)saveStatusTimeline:(NSArray*)statuses withType:(NSString*)type;

+(void) initialize;

-(void)commitEditingAndSave;
-(NSString*)entityNameWithRelationshipName:(NSString*)relationshipName;
-(NSDictionary*)dictionaryFromManagedObject:(NSManagedObject*)managedObject;
-(NSArray*)dataArrayFromManagedObjects:(NSArray*)managedObjects;
-(NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)valueDictionary 
								withEntityName:(NSString*)entityName
					  withManagedObjectContext:(NSManagedObjectContext*)moc;

@end
