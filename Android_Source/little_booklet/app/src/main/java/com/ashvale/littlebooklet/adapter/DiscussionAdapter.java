package com.ashvale.littlebooklet.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ashvale.littlebooklet.R;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;

/**
 * Created by chishengjan on 2/12/15.
 */
public class DiscussionAdapter extends ParseQueryAdapter<ParseObject> {

    public static String event_objid;

    public DiscussionAdapter(Context context) {

        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Talk");
                innerQuery.whereEqualTo("objectId", event_objid);
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Forum");
                query.whereMatchesQuery("source", innerQuery);
                query.include("author");
                query.include("source");
                query.orderByAscending("createdAt");
                return query;
            }
        });
    }

    @Override
    public View getItemView(ParseObject discussion_obj, View v, ViewGroup parent) {
        super.getItemView(discussion_obj, v, parent);
        ParseUser author = discussion_obj.getParseUser("author");
        String lname = author.getString("last_name");
        String fname = author.getString("first_name");

        v = View.inflate(getContext(), R.layout.listitem_discussion_row, null);

        TextView discussion_content = (TextView) v.findViewById(R.id.discussion_content);
        discussion_content.setText(discussion_obj.getString("content"));

        TextView discussion_author = (TextView)v.findViewById(R.id.discussion_author);
        discussion_author.setText(fname + " " + lname);
        return v;
    }
}