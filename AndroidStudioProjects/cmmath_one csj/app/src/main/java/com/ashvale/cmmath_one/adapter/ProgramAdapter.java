package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.util.List;

/**
 * Created by csjan on 9/14/15.
 */
public class ProgramAdapter extends BaseAdapter {
    private final Context context;
    private final List talks;

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

        TextView primaryLabel = (TextView)view.findViewById(R.id.primarylabel);
        TextView secondaryLabel = (TextView)view.findViewById(R.id.secondarylabel);

        primaryLabel.setText(talk.getString("name"));
        secondaryLabel.setText(talk.getString("content"));

        return view;
    }
}
