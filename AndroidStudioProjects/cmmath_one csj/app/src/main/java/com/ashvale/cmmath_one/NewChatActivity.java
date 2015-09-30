package com.ashvale.cmmath_one;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.cmmath_one.adapter.InviteeAdapter;
import com.ashvale.cmmath_one.adapter.NewchatAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class NewChatActivity extends AppCompatActivity {
    private NewchatAdapter adapter;
    private int[] selectedPositions;
    public List<ParseUser> totalInvitees;
    public List<ParseUser> selectedInvitees;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_chat);

        ParseQuery<ParseUser> query = ParseUser.getQuery();
        query.whereEqualTo("chat_status", 1);
        query.whereNotEqualTo("debug_status", 1);
        query.include("person");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseUser>() {
            public void done(List<ParseUser> objects, com.parse.ParseException e) {
                if (e == null) {
                    ParseUser selfUser = ParseUser.getCurrentUser();
                    List<ParseUser> fullList = new ArrayList<>();
                    for (ParseUser allUser : objects) {
                        if (!(allUser.getObjectId().equals(selfUser.getObjectId())))
                        {
                            fullList.add(allUser);
                        }
                    }
                    setAdapter(fullList);
                } else {
                    //error handling
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        selectedInvitees = new ArrayList<ParseUser>();
        totalInvitees = new ArrayList<ParseUser>();
        totalInvitees = results;
        selectedPositions = new int[results.size()];
        for (int i = 0; i< results.size(); i++)
        {
            selectedPositions[i] = 0;
        }
        adapter = new NewchatAdapter(this, results, selectedPositions);
        ListView newchatListView = (ListView)findViewById(R.id.newchatListView);
        newchatListView.setAdapter(adapter);
        newchatListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                ParseUser invitee = totalInvitees.get(position);
                if (selectedPositions[position] == 0) {
                    selectedInvitees.add(invitee);
                    selectedPositions[position] = 1;
                } else {
                    selectedInvitees.remove(invitee);
                    selectedPositions[position] = 0;
                }

                adapter.notifyDataSetChanged();
            }
        });
    }

    public void createConversation(List<ParseUser> participants)
    {
        final ParseUser selfUser = ParseUser.getCurrentUser();
        participants.add(selfUser);
        final ParseObject conversation = new ParseObject("Conversation");
        conversation.put("participants", participants);
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

                    //go to the chat view, but somehow unload this view...(to-do)
                    String convid = conversation.getObjectId();
                    Intent intent = new Intent(NewChatActivity.this, ChatActivity.class);
                    intent.putExtra("convid", convid);
                    startActivity(intent);
                    finish();
                } else {
                }
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_new_chat, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.createchat) {
            createConversation(selectedInvitees);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
