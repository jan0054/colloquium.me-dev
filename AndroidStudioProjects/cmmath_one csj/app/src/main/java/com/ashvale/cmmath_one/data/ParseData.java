package com.ashvale.cmmath_one.data;

import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.util.List;

/**
 * Created by csjan on 8/31/15.
 */
public class ParseData {

    //Program

    public void getProgram(ParseObject event, int type, int order)
    {

    }

    public void getProgramSearch(ParseObject event, int type, String searchStr, int order)
    {

    }

    public void getProgramAuthor(ParseObject author, ParseObject event)
    {

    }

    //Venue

    public void getVenue(ParseObject event)
    {

    }

    //Attendee

    public void getPeople(ParseObject event)
    {

    }

    public void getPeople(ParseObject event, String searchStr)
    {

    }

    //Event

    public void getAllEvents()
    {

    }

    public void getEventsLocal(List eventIds)
    {

    }

    public void updateEvent(ParseObject person, List events)
    {

    }

    public void getAnnouncements(ParseObject event)
    {

    }

    //Forum

    public void getForum(ParseObject program)
    {

    }

    public void postForum(ParseObject program, String content, ParseUser author)
    {

    }

    //Career

    public void getCareers()
    {

    }

    //Timeline

    public void getPosts(ParseObject event)
    {

    }

    public void getComments(ParseObject post)
    {

    }

    public void sendPost(ParseUser author, String content, ParseObject event, ParseFile image)
    {

    }

    public void sendComment(ParseObject post, String content, ParseUser author)
    {

    }

    //Chat

    public void getConversations(ParseUser user)
    {

    }

    public void getChat(ParseObject conversation)
    {

    }

    public void sendChat(ParseUser author, String content, ParseObject conversation)
    {

    }

    public void sendBroadcast(ParseUser author, String content, ParseObject conversation)
    {

    }

    public void getInviteeList(List alreadyIn)
    {

    }

    public void inviteUser(ParseObject conversation, ParseUser user)
    {

    }

    public void leaveConversation(ParseObject conversation, ParseUser user)
    {

    }

    public void createConversation(List participants)
    {

    }

}
