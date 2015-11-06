package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Created by csjan on 9/14/15.
 */
public class AnnounceAdapter extends BaseAdapter {
    public static final String 			ACTION_VENUE_WEBSITE 		= "com.cmmath.action.venue.website";
    public static final String          ACTION_VENUE_URL            = "com.cmmath.data.venue.url";
    public static final String 			ACTION_VENUE_CALL 			= "com.cmmath.action.venue.call";
    public static final String          ACTION_VENUE_PHONE          = "com.cmmath.data.venue.phone";
    public static final String 			ACTION_VENUE_NAVIGATE 		= "com.cmmath.action.venue.navigate";
    public static final String 			EXTRA_VENUE_LAT	  			= "com.cmmath.data.venue.LATITUDE";
    public static final String 			EXTRA_VENUE_LNG				= "com.cmmath.data.venue.LONGITUDE";

    private final Context context;
    private final List announces;
    private SimpleDateFormat sdf;

    public AnnounceAdapter(Context context, List queryresults) {
        this.context = context;
        this.announces = queryresults;
    }

    @Override
    public int getCount()
    {
        return announces.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  announces.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_announcement, vg, false);
        }

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

        ParseObject announce = (ParseObject) announces.get(position);

        TextView authornameLabel = (TextView)view.findViewById(R.id.announce_authorname);
        TextView createdAtLabel = (TextView)view.findViewById(R.id.announce_createdAt);
        TextView contentLabel = (TextView)view.findViewById(R.id.announce_content);

        authornameLabel.setText(getAuthor(announce));
        createdAtLabel.setText(getCreatedAt(announce));
        contentLabel.setText(getContent(announce));

        return view;
    }

    private String getAuthor(ParseObject object) {
        ParseUser author = object.getParseUser("author");
        return (author == null) ? context.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getCreatedAt(ParseObject object) {
        return sdf.format(object.getCreatedAt());
    }

    private String getContent(ParseObject object) {
        return object.getString("content");
    }
}
