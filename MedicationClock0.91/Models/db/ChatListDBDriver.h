//
//  ChatListDBDriver.h
//  Test
//
//  Created by jam on 16/3/29.
//  Copyright © 2016年 jam. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 表名以及表子段常量
 */
#define  DB_chat_list @"chat_list"

#define DB_CL_user_id @"user_id"                    //
#define DB_CL_username @"username"                  //
#define DB_CL_nickname @"nickname"                  //
#define DB_CL_head_img_mark @"head_img_mark"        //
#define DB_CL_chatContent @"chatContent"            //
#define DB_CL_chatTime @"chatTime"                  //
#define DB_CL_state @"state"                        //
#define DB_CL_unread_count @"unread_count"          //

#define SQL_CREATE_chat_list [NSString stringWithFormat:@"create table CREATE TABLE IF NOT EXISTS %@(ID INTEGER PRIMARY KEY autoincrement , %@, %@, %@, %@, %@ , %@, %@, %@ );",DB_chat_list,DB_CL_user_id,DB_CL_username,DB_CL_nickname,DB_CL_head_img_mark,DB_CL_chatContent,DB_CL_chatTime,DB_CL_state,DB_CL_unread_count]



@interface ChatListDBDriver : NSObject

/*
public static final String TABLENAME = "chat_list";
public static final String TABLE_CREATE = "create table "+TABLENAME+" (_id integer primary key autoincrement,user_id,username,nickname,head_img_mark,chatContent,chatTime,state,unread_count)";
*/

//增
-(void)insertUserinfo:(NSMutableDictionary *) param;
-(void) insertByList:(NSMutableArray * )list;
//删
-(void) deleteAll;
//改
-(void) setState:(NSString *) user_id flag: (BOOL) flag;
-(void) setCleanCache;
-(void) setUnreadCount:(NSString*) unread_count user_id:(NSString *)user_id;
-(void) setRecentChat:(NSString *)chatContent  chatTime:(NSString* )chatTime user_id:(NSString *)user_id;
-(void) setRecentChat:(NSString *) chatContent  chatTime:(NSString *) chatTime  unread_count:(NSString*) unread_count user_id:(NSString*) user_id;
//查
-(NSMutableArray * ) queryByNichname:(NSString *)nickname;
-(NSMutableArray * )  queryRecently;
-(NSMutableArray * ) queryAll;
-(NSMutableArray * ) queryAll:(int )codeIndex;

-(BOOL)exists:(NSString*) username;


@end
