package com.ashvale.littlebooklet;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.littlebooklet.adapter.ConversationAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.List;


public class ConversationActivity extends BaseActivity {
    SwipeRefreshLayout swipeRefreshLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_conversation);
        super.onCreateDrawer();


        FloatingActionButton newchat_fab = (FloatingActionButton) findViewById(R.id.newchat_fab);
        newchat_fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(ConversationActivity.this, NewChatActivity.class);
                startActivity(intent);
            }
        });


        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.conversation_refresh);
        swipeRefreshLayout.setColorSchemeColors(R.color.dark_accent);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                //refresh things here
                ParseUser selfUser = ParseUser.getCurrentUser();
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
                query.whereEqualTo("participants", selfUser);
                query.include("participants");
                query.orderByDescending("updatedAt");
                query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
                query.findInBackground(new FindCallback<ParseObject>() {
                    public void done(List<ParseObject> objects, com.parse.ParseException e) {
                        if (e == null) {
                            Log.d("cm_app", "conversation query results: " + objects.size());
                            setAdapter(objects);
                            swipeRefreshLayout.setRefreshing(false);
                        } else {
                            Log.d("cm_app", "conversation query error: " + e);
                            swipeRefreshLayout.setRefreshing(false);
                        }
                    }
                });
            }
        });

        ParseUser selfUser = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
        query.whereEqualTo("participants", selfUser);
        query.include("participants");
        query.orderByDescending("updatedAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "conversation query results: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "conversation query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List<ParseObject> results) {
        ListView conversationListView = (ListView) findViewById(R.id.conversationListView);
        TextView emptyLabel = (TextView) findViewById(R.id.conversationempty);
        if (results.size()!=0) {
            conversationListView.setVisibility(View.VISIBLE);
            emptyLabel.setVisibility(View.INVISIBLE);
            ConversationAdapter adapter = new ConversationAdapter(this, results);
            conversationListView.setAdapter(adapter);
            conversationListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    ParseObject conversation = results.get(position);
                    String convid = conversation.getObjectId();
                    Intent intent = new Intent(ConversationActivity.this, ChatActivity.class);
                    intent.putExtra("convid", convid);
                    startActivity(intent);
                }
            });
        } else {
            conversationListView.setVisibility(View.INVISIBLE);
            emptyLabel.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        ParseUser selfUser = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
        query.whereEqualTo("participants", selfUser);
        query.include("participants");
        query.orderByDescending("updatedAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "conversation query results: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "conversation query error: " + e);
                }
            }
        });
    }
}
