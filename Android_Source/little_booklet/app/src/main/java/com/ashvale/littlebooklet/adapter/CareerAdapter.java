package com.ashvale.littlebooklet.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.littlebooklet.R;
import com.parse.ParseObject;

import java.util.List;

/**
 * Created by csjan on 9/3/15.
 */
public class CareerAdapter extends BaseAdapter {
    private final Context context;
    private final List careers;

    public CareerAdapter(Context context, List queryresults) {
        this.context = context;
        this.careers = queryresults;
    }

    @Override
    public int getCount()
    {
        return careers.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  careers.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_career, vg, false);
        }

        ParseObject career = (ParseObject)careers.get(position);

        TextView typeLabel = (TextView)view.findViewById(R.id.careerType);
        TextView instLabel = (TextView)view.findViewById(R.id.careerInst);
        TextView contentlabel = (TextView)view.findViewById(R.id.careerContent);

        String typestr = career.getInt("hiring") == 1 ? "Position Available" : "Seeking Job";
        String positionstr = career.getString("position");
        String inststr = career.getString("institution");
        String contentstr = career.getString("content");

        typeLabel.setText(typestr+": "+positionstr);
        instLabel.setText(inststr);
        contentlabel.setText(contentstr);

        return view;
    }
}