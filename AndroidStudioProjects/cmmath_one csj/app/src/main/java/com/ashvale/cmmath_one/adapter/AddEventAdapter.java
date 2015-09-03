package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 9/3/15.
 */
public class AddEventAdapter extends BaseAdapter {
    private final Context context;
    private final List events;

    public AddEventAdapter(Context context, List queryresults) {
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

            view = inflater.inflate(R.layout.listitem_eventpicker, vg, false);
        }

        ParseObject event = (ParseObject)events.get(position);

        TextView namelabel = (TextView)view.findViewById(R.id.nameLabel);
        TextView timelabel = (TextView)view.findViewById(R.id.timeLabel);
        TextView organizerlabel = (TextView)view.findViewById(R.id.organizerLabel);
        TextView contentlabel = (TextView)view.findViewById(R.id.contentLabel);

        Date startdate = event.getDate("start_time");
        Date enddate = event.getDate("end_time");
        Format dateformatter = new SimpleDateFormat("MM-dd");
        String startstr = dateformatter.format(startdate);
        String endstr = dateformatter.format(enddate);
        String contentstr = event.getString("content");
        String namestr = event.getString("name");
        String orgstr = event.getString("organizer");

        namelabel.setText(namestr);
        organizerlabel.setText(orgstr);
        contentlabel.setText(contentstr);
        timelabel.setText(startstr+" ~ "+endstr);

        return view;
    }
}