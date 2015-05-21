package com.cmmath.app;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;

/**
 * Created by chishengjan on 2/12/15.
 */
public class DiscussionPosterAdapter extends ParseQueryAdapter<ParseObject> {

    public static String event_objid;

    public DiscussionPosterAdapter(Context context) {

        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Poster");
                innerQuery.whereEqualTo("objectId", event_objid);
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Forum");
                query.whereMatchesQuery("source_poster", innerQuery);
                query.include("author_person");
                query.include("source_poster");
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