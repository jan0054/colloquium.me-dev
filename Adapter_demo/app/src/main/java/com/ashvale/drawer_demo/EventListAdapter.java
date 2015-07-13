package com.ashvale.drawer_demo;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.ParseObject;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by csjan on 7/13/15.
 */
public class EventListAdapter extends BaseAdapter {
    private final Context context;
    private final List events;

    public EventListAdapter(Context context, List queryresults) {
        this.context = context;
        this.events = queryresults;
    }

    @Override
    public int getCount()
    {
        return events.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  events.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

                view = inflater.inflate(R.layout.list_item_event, vg, false);
        }

        ParseObject event = (ParseObject)events.get(position);

        TextView namelabel = (TextView)view.findViewById(R.id.namelabel);
        TextView timelabel = (TextView)view.findViewById(R.id.timelabel);
        TextView organizerlabel = (TextView)view.findViewById(R.id.organizerlabel);
        TextView contentlabel = (TextView)view.findViewById(R.id.contentlabel);

        String namestr = event.getString("name");
        String organizerstr = event.getString("organizer");
        String contentstr = event.getString("content");

        namelabel.setText(namestr);
        organizerlabel.setText(organizerstr);
        contentlabel.setText(contentstr);
        timelabel.setText("to-do:set time string");

        return view;
    }
}
