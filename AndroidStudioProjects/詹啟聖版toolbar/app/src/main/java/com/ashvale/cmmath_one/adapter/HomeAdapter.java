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
public class HomeAdapter extends BaseAdapter {
    private final Context context;
    private final List eventlist;

    public HomeAdapter(Context context, List queryresults) {
        this.context = context;
        this.eventlist = queryresults;
    }

    @Override
    public int getCount()
    {
        return eventlist.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  eventlist.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_home, vg, false);
        }

        ParseObject event = (ParseObject)eventlist.get(position);

        TextView timeLabel = (TextView)view.findViewById(R.id.eventTime);
        TextView nameLabel = (TextView)view.findViewById(R.id.eventName);
        TextView contentlabel = (TextView)view.findViewById(R.id.eventContent);
        TextView orglabel = (TextView)view.findViewById(R.id.eventOrg);

        Date startdate = event.getDate("start_time");
        Date enddate = event.getDate("end_time");
        Format dateformatter = new SimpleDateFormat("MM/dd");
        String startstr = dateformatter.format(startdate);
        String endstr = dateformatter.format(enddate);
        String contentstr = event.getString("content");
        String namestr = event.getString("name");
        String orgstr = event.getString("organizer");

        timeLabel.setText(startstr+" ~ "+endstr);
        nameLabel.setText(namestr);
        contentlabel.setText(contentstr);
        orglabel.setText(orgstr);

        return view;
    }
}
