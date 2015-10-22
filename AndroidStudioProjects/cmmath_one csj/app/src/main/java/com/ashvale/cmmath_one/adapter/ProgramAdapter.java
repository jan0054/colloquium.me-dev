package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import org.w3c.dom.Text;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Created by csjan on 9/14/15.
 */
public class ProgramAdapter extends BaseAdapter {
    private final Context context;
    private final List talks;
    private SimpleDateFormat sdf;


    public ProgramAdapter(Context context, List queryresults) {
        this.context = context;
        this.talks = queryresults;
    }

    @Override
    public int getCount()
    {
        return talks.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  talks.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_program, vg, false);
        }

        ParseObject talk = (ParseObject)talks.get(position);

        TextView nameLabel = (TextView)view.findViewById(R.id.program_name);
        TextView authornameLabel = (TextView)view.findViewById(R.id.program_authorname);
        TextView contentLabel = (TextView)view.findViewById(R.id.program_content);
        TextView locationLabel = (TextView)view.findViewById(R.id.program_locationname);
        TextView starttimeLabel = (TextView)view.findViewById(R.id.program_starttime);

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));

        nameLabel.setText(talk.getString("name"));
        authornameLabel.setText(getAuthor(talk));
        contentLabel.setText(talk.getString("content"));
        locationLabel.setText(getLocationName(talk));
        starttimeLabel.setText(getStartTime(talk));

        return view;
    }

    private String getAuthor(ParseObject object) {
        ParseObject author = object.getParseObject("author");
        return (author == null) ? context.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getLocationName(ParseObject object) {
        ParseObject location = object.getParseObject("location");
        return (location == null) ? "location TBD" : location.getString("name");
    }

    private String getStartTime(ParseObject object) {
        return sdf.format(object.getDate("start_time"));
    }

}
