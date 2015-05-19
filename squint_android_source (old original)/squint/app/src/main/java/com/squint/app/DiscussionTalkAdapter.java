package com.squint.app;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by chishengjan on 2/12/15.
 */
public class DiscussionTalkAdapter extends ParseQueryAdapter<ParseObject> {

    public static String event_objid;

    public DiscussionTalkAdapter(Context context) {

        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("talk");
                innerQuery.whereEqualTo("objectId", event_objid);
                ParseQuery<ParseObject> query = ParseQuery.getQuery("forum");
                query.whereMatchesQuery("source_talk", innerQuery);
                query.include("author_person");
                query.include("source_talk");
                query.orderByAscending("createdAt");
                return query;
            }
        });
    }

    @Override
    public View getItemView(ParseObject discussion_obj, View v, ViewGroup parent) {
        super.getItemView(discussion_obj, v, parent);
        ParseObject author_person = discussion_obj.getParseObject("author_person");
        String lname = author_person.getString("last_name");
        String fname = author_person.getString("first_name");

        v = View.inflate(getContext(), R.layout.discussion_row, null);

        TextView discussion_content = (TextView) v.findViewById(R.id.discussioncontent);
        discussion_content.setText(discussion_obj.getString("content"));

        TextView discussion_author = (TextView)v.findViewById(R.id.discussionauthor);
        discussion_author.setText(fname + " " + lname);
        return v;
    }
}