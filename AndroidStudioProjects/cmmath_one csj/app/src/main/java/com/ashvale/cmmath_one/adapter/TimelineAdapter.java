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
public class TimelineAdapter extends BaseAdapter {
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
        return  posts.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_venue, vg, false);
        }

        ParseObject post = (ParseObject)posts.get(position);

        TextView primaryLabel = (TextView)view.findViewById(R.id.primarylabel);
        TextView secondaryLabel = (TextView)view.findViewById(R.id.secondarylabel);

        primaryLabel.setText(post.getString("content"));
        secondaryLabel.setText(post.getString("content"));

        return view;
    }
}
