package com.ashvale.cmmath_one.data;

import android.util.Log;

import com.parse.FindCallback;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import bolts.Task;

/**
 * Created by csjan on 8/31/15.
 */
public class ParseData {

    //Program

    public void getProgram(ParseObject event, int type, int order)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereEqualTo("event", event);
        query.include("author");
        query.include("session");
        query.include("location");
        //type = 0 for talk, =1 for poster, can add others in future if needed
        query.whereEqualTo("type", type);
        //order = 0 start_time, order = 1 name, can add others in future if needed
        if (order == 0)
        {
            query.orderByDescending("start_time");
        }
        else if (order==1)
        {
            query.orderByDescending("name");
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getProgramSearch(ParseObject event, int type, List<String> searchArray, int order)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereEqualTo("event", event);
        query.include("author");
        query.include("session");
        query.include("location");
        //type = 0 for talk, =1 for poster, can add others in future if needed
        query.whereEqualTo("type", type);
        //order = 0 start_time, order = 1 name, can add others in future if needed
        if (order == 0)
        {
            query.orderByDescending("start_time");
        }
        else if (order==1)
        {
            query.orderByDescending("name");
        }
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getProgramAuthor(ParseObject author, ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereEqualTo("event", event);
        query.whereEqualTo("author", author);
        query.orderByDescending("name");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Venue

    public void getVenue(ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Venue");
        query.whereEqualTo("event", event);
        query.orderByDescending("order");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Attendee

    public void getPeople(ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.whereEqualTo("event", event);
        query.include("User");
        query.orderByAscending("last_name");
        query.setLimit(500);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getPeople(ParseObject event, List<String> searchArray)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.whereEqualTo("event", event);
        query.include("User");
        query.orderByAscending("last_name");
        query.setLimit(500);
        query.whereEqualTo("events", event);
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Event

    public void getAllEvents()
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.include("admin");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.orderByDescending("start_time");
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getEventsLocal(List eventIds) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.whereContainedIn("objectId", eventIds);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void updateEvent(ParseObject person, List events)
    {
        person.put("events", events);
        person.saveInBackground();
    }

    public void getAnnouncements(ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Announcement");
        query.include("author");
        query.orderByAscending("createdAt");
        query.whereEqualTo("event", event);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Forum

    public void getForum(ParseObject program)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Forum");
        query.include("author");
        query.include("source");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.orderByDescending("createdAt");
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void postForum(ParseObject program, String content, ParseUser author)
    {
        ParseObject forum = new ParseObject("Forum");
        forum.put("author", author);
        forum.put("content", content);
        forum.put("source", program);
        forum.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Career

    public void getCareers()
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Career");
        query.orderByDescending("createdAt");
        query.include("author");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Timeline

    public void getPosts(ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Post");
        query.orderByDescending("createdAt");
        query.whereEqualTo("event", event);
        query.include("author");
        query.setLimit(500);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getComments(ParseObject post)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Comment");
        query.orderByAscending("ccreatedAt");
        query.whereEqualTo("post", post);
        query.include("author");
        query.setLimit(500);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void sendPost(ParseUser author, String content, ParseObject event, ParseFile image)
    {
        ParseObject post = new ParseObject("Post");
        post.put("author", author);
        post.put("image", image);
        post.put("content", content);
        post.put("event", event);
        post.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void sendComment(ParseObject post, String content, ParseUser author)
    {
        ParseObject comment = new ParseObject("Comment");
        comment.put("author", author);
        comment.put("content", content);
        comment.put("post", post);
        comment.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    //Chat

    public void getConversations(ParseUser user)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
        query.whereEqualTo("participants", user);
        query.include("participants");
        query.orderByDescending("updatedAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void getChat(ParseObject conversation)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Chat");
        query.whereEqualTo("conversation", conversation);
        query.orderByAscending("createdAt");
        query.include("author");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });
    }

    public void sendChat(ParseUser author, final String content, final ParseObject conversation)
    {
        ParseObject chat = new ParseObject("Chat");
        chat.put("author", author);
        chat.put("content", content);
        chat.put("conversation", conversation);
        chat.put("broadcast", 0);
        chat.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    conversation.put("last_msg", content);
                    Date date = new Date();
                    conversation.put("last_time", date);
                    conversation.saveInBackground();
                    //send push and stuff

                } else {

                }
            }
        });
    }

    public void sendBroadcast(ParseUser author, final String content, final ParseObject conversation)
    {
        ParseObject chat = new ParseObject("Chat");
        chat.put("author", author);
        chat.put("content", content);
        chat.put("conversation", conversation);
        chat.put("broadcast", 1);
        chat.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    conversation.put("last_msg", content);
                    Date date = new Date();
                    conversation.put("last_time", date);
                    conversation.saveInBackground();
                    //send push and stuff

                } else {

                }
            }
        });
    }

    public void getInviteeList(final List<ParseUser> alreadyIn)
    {
        ParseQuery<ParseUser> query = ParseUser.getQuery();
        query.whereEqualTo("chat_status", 1);
        query.whereNotEqualTo("debug_status", 1);
        query.include("person");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseUser>() {
            public void done(List<ParseUser> objects, com.parse.ParseException e) {
                if (e == null) {
                    List<ParseUser> inviteeList = new ArrayList<ParseUser>();
                    for (ParseUser allUser : objects)
                    {
                        int match = 0;
                        for (ParseUser alreadyUser : alreadyIn)
                        {
                            if (allUser.getObjectId().equalsIgnoreCase(alreadyUser.getObjectId())) {
                                match = 1;
                            }
                        }
                        if (match == 0)
                        {
                            inviteeList.add(allUser);
                        }
                    }
                    //do stuff with inviteeList


                } else {

                }
            }
        });
    }

    public void inviteUser(final ParseObject conversation, ParseUser user)
    {
        final ParseUser selfUser = ParseUser.getCurrentUser();
        String selfName = selfUser.getString("first_name")+" "+selfUser.getString("last_name");
        String userName = user.getString("first_name")+" "+user.getString("last_name");
        final String content = selfName+" has invited "+userName+" to the conversation.";
        conversation.add("participants", user);
        conversation.put("is_group", 1);         //deprecated?
        conversation.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    //send broadcast
                    sendBroadcast(selfUser, content, conversation);
                } else {

                }
            }
        });
    }

    public void leaveConversation(final ParseObject conversation)
    {
        final ParseUser selfUser = ParseUser.getCurrentUser();
        String selfName = selfUser.getString("first_name")+" "+selfUser.getString("last_name");
        final String content = selfName+" has left the conversation.";
        conversation.removeAll("participants", Arrays.asList(selfUser));
        conversation.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    //send broadcast
                    sendBroadcast(selfUser, content, conversation);
                } else {

                }
            }
        });
    }

    public void createConversation(List<ParseUser> participants)
    {
        final ParseObject conversation = new ParseObject("Conversation");
        conversation.put("participants", participants);
        final ParseUser selfUser = ParseUser.getCurrentUser();
        String selfName = selfUser.getString("first_name")+" "+selfUser.getString("last_name");
        String nameList = "";
        for (ParseUser user : participants)
        {
            String fullName = user.getString("first_name")+" "+user.getString("last_name");
            if (!user.getObjectId().equals(selfUser.getObjectId()))
            {
                if (nameList.length()>1)
                {
                    nameList = nameList+", "+fullName;
                }
                else
                {
                    nameList = fullName;
                }
            }
        }
        final String last_msg = selfName+" created conversation with: "+nameList;
        conversation.put("last_msg", last_msg);  //remove when broadcast is done, since broadcast also does this already
        Date date = new Date();
        conversation.put("last_time", date);     //same as above
        conversation.put("is_group", 1);
        conversation.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    //send broadcast
                    sendBroadcast(selfUser, last_msg, conversation);
                } else {

                }
            }
        });
    }

}
