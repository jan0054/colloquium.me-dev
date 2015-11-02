package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseFile;
import com.parse.ParseObject;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Created by csjan on 9/14/15.
 */
public class CommentAdapter extends BaseAdapter {
    public static final String			TAG = CommentAdapter.class.getSimpleName();
    public static final String 			ACTION_POST_SELECT 		= "com.cmmath_one.action.comment.select";
    public static final String 			EXTRA_POST_ID	  		= "com.cmmath_one.data.comment.ID";
    public static final String 			EXTRA_POST_NAME			= "com.cmmath_one.data.comment.NAME";
    public static final String 			EXTRA_POST_AUTHORNAME	= "com.cmmath_one.data.comment.AUTHORNAME";
    public static final String 			EXTRA_POST_CONTENT		= "com.cmmath_one.data.comment.CONTENT";
    public static final String 			EXTRA_POST_CREATEDAT	= "com.cmmath_one.data.comment.CREATEDAT";

    private SimpleDateFormat sdf;
    private final Context context;
    private final List comments;

    public CommentAdapter(Context context, List queryresults) {
        this.context = context;
        this.comments = queryresults;
    }

    @Override
    public int getCount()
    {
        return comments.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return comments.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_comment, vg, false);
        }

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

        ParseObject comment = (ParseObject) comments.get(position);

        TextView authornameLabel = (TextView)view.findViewById(R.id.comment_authorname);
        TextView createdAtLabel = (TextView)view.findViewById(R.id.comment_createdAt);
        TextView contentLabel = (TextView)view.findViewById(R.id.comment_content);

        authornameLabel.setText(getAuthor(comment));
        createdAtLabel.setText(getCreatedAt(comment));
        contentLabel.setText(getContent(comment));

        return view;
    }

    private String getAuthor(ParseObject object) {
        ParseObject author = object.getParseObject("author");
        return (author == null) ? context.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getCreatedAt(ParseObject object) {
        return sdf.format(object.getCreatedAt());
    }

    private String getContent(ParseObject object) {
        return object.getString("content");
    }

}
