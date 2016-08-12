package com.ashvale.littlebooklet.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.littlebooklet.R;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Created by csjan on 9/14/15.
 */
public class TimelineAdapter extends BaseAdapter {
    public static final String			TAG = TimelineAdapter.class.getSimpleName();
    public static final String 			ACTION_POST_SELECT 		= "com.uiucalum.action.post.select";
    public static final String 			EXTRA_POST_ID	  		= "com.uiucalum.data.post.ID";
    public static final String 			EXTRA_POST_NAME			= "com.uiucalum.data.post.NAME";
    public static final String 			EXTRA_POST_ATTACHMENT	= "com.uiucalum.data.post.ATTACHMENT";
    public static final String 			EXTRA_POST_AUTHORNAME	= "com.uiucalum.data.post.AUTHORNAME";
    public static final String 			EXTRA_POST_CONTENT		= "com.uiucalum.data.post.CONTENT";
    public static final String 			EXTRA_POST_IMAGE	    = "com.uiucalum.data.post.IMAGE";
    public static final String 			EXTRA_POST_CREATEDAT	= "com.uiucalum.data.post.CREATEDAT";
    public static final String 			EXTRA_POST_DATE		    = "com.uiucalum.data.post.DATE";

    private SimpleDateFormat sdf;
    private final Context context;
    private final List posts;

    public TimelineAdapter(Context context, List queryresults) {
        this.context = context;
        this.posts = queryresults;
    }

    @Override
    public int getCount()
    {
        return posts.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return posts.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_timeline, vg, false);
        }

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

        ParseObject post = (ParseObject)posts.get(position);

        ParseImageView imageLabel = (ParseImageView)view.findViewById(R.id.timeline_image);
        TextView authornameLabel = (TextView)view.findViewById(R.id.timeline_authorname);
        TextView createdAtLabel = (TextView)view.findViewById(R.id.timeline_createdAt);
        TextView contentLabel = (TextView)view.findViewById(R.id.timeline_content);

        ParseFile image = post.getParseFile("preview");
        imageLabel.setParseFile(image);
        imageLabel.loadInBackground();
        authornameLabel.setText(getAuthor(post));
        createdAtLabel.setText(getCreatedAt(post));
        contentLabel.setText(getContent(post));

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
