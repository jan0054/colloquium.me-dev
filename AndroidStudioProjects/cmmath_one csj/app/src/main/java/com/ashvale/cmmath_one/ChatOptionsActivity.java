package com.ashvale.cmmath_one;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.CareerAdapter;
import com.ashvale.cmmath_one.adapter.InviteeAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ChatOptionsActivity extends AppCompatActivity {
    public String conversationId;
    private int[] selectedPositions;
    public List<ParseUser> totalInvitees;
    public List<ParseUser> selectedInvitees;
    private InviteeAdapter adapter;
    private ParseObject conversationObject;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_options);
        conversationId = this.getIntent().getExtras().getString("convid");
        ParseQuery<ParseObject> convquery = ParseQuery.getQuery("Conversation");
        convquery.include("participants");
        convquery.getInBackground(conversationId, new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {

                final List<ParseUser> participants = parseObject.getList("participants");
                conversationObject = parseObject;
                ParseQuery<ParseUser> query = ParseUser.getQuery();
                query.whereEqualTo("chat_status", 1);
                query.whereNotEqualTo("debug_status", 1);

                query.include("person");
                query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
                query.findInBackground(new FindCallback<ParseUser>() {
                    public void done(List<ParseUser> objects, com.parse.ParseException e) {
                        if (e == null) {
                            List<ParseUser> inviteeList = new ArrayList<ParseUser>();
                            for (ParseUser allUser : objects) {
                                int match = 0;
                                for (ParseUser alreadyUser : participants) {
                                    if (allUser.getObjectId().equalsIgnoreCase(alreadyUser.getObjectId())) {
                                        match = 1;
                                    }
                                }
                                if (match == 0) {
                                    inviteeList.add(allUser);
                                }
                            }
                            //do stuff with inviteeList
                            setAdapter(inviteeList);

                        } else {
                            //error handling
                        }
                    }
                });
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
        adapter = new InviteeAdapter(this, results, selectedPositions);
        ListView inviteeListView = (ListView)findViewById(R.id.inviteeListView);
        inviteeListView.setAdapter(adapter);
        inviteeListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //to-do: add selected parse user to participants then refresh the liveview
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

    public void inviteSelected()
    {
        conversationObject.addAllUnique("participants", selectedInvitees);
        conversationObject.saveInBackground(new SaveCallback() {
            @Override
            public void done(ParseException e) {
                ParseUser selfUser = ParseUser.getCurrentUser();
                String selfName = selfUser.getString("first_name") + " " + selfUser.getString("last_name");
                String nameList = "";
                for (ParseUser user : selectedInvitees) {
                    String userName = user.getString("first_name") + " " + user.getString("last_name");
                    if (nameList.length() > 1) {
                        nameList = nameList + ", " + userName;
                    } else {
                        nameList = userName;
                    }
                }

                final String content = selfName + " has invited " + nameList + " to the conversation.";
                sendBroadcast(selfUser, content, conversationObject);

            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_chat_options, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_invite) {
            //do invitation then go back
            inviteSelected();
            return true;
        }

        return super.onOptionsItemSelected(item);
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

                    //finally we close the chat options view and go back
                    onBackPressed();

                } else {
                    Log.d("cm_app", "broadcast error: " + e);
                }
            }
        });
    }

}
