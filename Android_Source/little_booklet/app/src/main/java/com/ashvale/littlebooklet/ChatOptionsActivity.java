package com.ashvale.littlebooklet;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.Toast;

import com.ashvale.littlebooklet.adapter.InviteeAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParsePush;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class ChatOptionsActivity extends DetailActivity {
    public String conversationId;
    private int[] selectedPositions;
    public List<ParseUser> totalInvitees;
    public List<ParseUser> selectedInvitees;
    private InviteeAdapter adapter;
    private ParseObject conversationObject;
    public EditText searchinput;
    public ImageButton dosearch;
    public ArrayList<String> searcharray;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_options);
        super.onCreateView();
        selectedInvitees = new ArrayList<ParseUser>();
        totalInvitees = new ArrayList<ParseUser>();

        searchinput = (EditText)findViewById(R.id.searchinput);
        dosearch = (ImageButton)findViewById(R.id.dosearch);
        dosearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setSearchString();
                getUserSearch(searcharray);
            }
        });
        searchinput.addTextChangedListener(new TextWatcher() {
            @Override
            public void afterTextChanged(Editable s) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start,
                                      int before, int count) {
                if (s.length() == 0) {
                    if (searcharray != null)
                    {
                        searcharray.clear();
                    }
                    getUser();
                }
            }
        });

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
        totalInvitees = results;
        selectedPositions = new int[results.size()];
        for (int i = 0; i< results.size(); i++)
        {
            for (ParseUser userobject : selectedInvitees) {
                if (userobject.getObjectId().equals(totalInvitees.get(i).getObjectId())) {
                    selectedPositions[i] = 1;
                    break;
                }
                else {
                    selectedPositions[i] = 0;
                }
            }
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

                if (nameList.length() != 0) {
                    final String content = selfName + " has invited " + nameList + " to the conversation.";
                    sendBroadcast(selfUser, content, conversationObject);
                } else {
                    onBackPressed();
                }
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
        switch (item.getItemId())
        {
            case android.R.id.home:
                finish();  //this is a workaround: normal back arrow press will destroy() the chatactivity, which when recreated will have no intent and will crash
                break;
            case R.id.action_invite:
                inviteSelected();
                break;
            default:
                break;
        }
        return true;
    }

    public void sendBroadcast(final ParseUser author, final String content, final ParseObject conversation)
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

                    //sent! now send the push notification: first prepare the message payload
                    JSONObject pn = new JSONObject();
                    try {
                        pn.put("alert", content);
                        pn.put("sound", "default");
                        pn.put("badge", "Increment");
                    } catch (JSONException e1) {
                        e1.printStackTrace();
                    }
                    // Create our Installation query
                    List<ParseUser> allParticipants = conversationObject.getList("participants");
                    int selfIncluded = 0;
                    for (ParseUser user : allParticipants) {
                        if (user.getObjectId().equals(author.getObjectId())) {
                            selfIncluded = 1;
                        }
                    }
                    if (selfIncluded ==1)
                    {
                        allParticipants.remove(author);
                    }

                    ParseQuery pushQuery = ParseInstallation.getQuery();
                    pushQuery.whereContainedIn("user", allParticipants);
                    // Send push notification to query
                    ParsePush push = new ParsePush();
                    push.setQuery(pushQuery); // Set our Installation query
                    //push.setMessage(message);
                    push.setData(pn);
                    push.sendInBackground();

                    //finally we close the chat options view and go back
                    onBackPressed();

                } else {
                    Log.d("cm_app", "broadcast error: " + e);
                }
            }
        });
    }

    public void getUser()
    {
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
                            Log.d("cm_app", "user query error: " + e);
                        }
                    }
                });
            }
        });
    }

    public void setSearchString()
    {
        String raw_input = searchinput.getText().toString();
        String lower_raw = raw_input.toLowerCase();
        String [] split_string = lower_raw.split("\\s+");
        searcharray = new ArrayList<String>(Arrays.asList(split_string));
    }

    public void getUserSearch(List<String> searchArray)
    {
        ParseQuery<ParseUser> query = ParseUser.getQuery();
        query.whereEqualTo("chat_status", 1);
        query.whereNotEqualTo("debug_status", 1);
        query.include("person");
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseUser>() {
            public void done(List<ParseUser> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "user query result: " + objects.size());
                    if(objects.size() == 0) {
                        toast(getString(R.string.no_result));
                    }
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
                    Log.d("cm_app", "user query error: " + e);
                }
            }
        });
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
