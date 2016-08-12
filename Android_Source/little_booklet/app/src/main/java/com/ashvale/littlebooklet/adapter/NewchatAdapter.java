package com.ashvale.littlebooklet.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.littlebooklet.R;
import com.parse.ParseUser;

import java.util.List;

/**
 * Created by csjan on 9/30/15.
 */
public class NewchatAdapter extends BaseAdapter {
    private final Context context;
    private final List invitees;
    private final int[] selectedPositions;

    public NewchatAdapter(Context context, List queryresults, int[] selectedpositions) {
        this.context = context;
        this.invitees = queryresults;
        this.selectedPositions = selectedpositions;
    }

    @Override
    public int getCount()
    {
        return invitees.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  invitees.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_newchat, vg, false);
        }

        ParseUser invitee = (ParseUser)invitees.get(position);
        String name = invitee.getString("first_name") + " " + invitee.getString("last_name");
        TextView nameLabel = (TextView)view.findViewById(R.id.newchat_name);
        TextView institutionLabel = (TextView)view.findViewById(R.id.newchat_institution);
        ImageView checkbox = (ImageView)view.findViewById(R.id.checkbox);

        nameLabel.setText(name);
        institutionLabel.setText(invitee.getString("institution"));

        int selected = selectedPositions[position];
        if (selected == 1)
        {
            checkbox.setImageResource(R.drawable.check);
            checkbox.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
            nameLabel.setTextColor(context.getResources().getColor(R.color.primary_color_icon));
        }
        else
        {
            checkbox.setImageResource(R.drawable.emptycircle);
            checkbox.setColorFilter(context.getResources().getColor(R.color.unselected_icon));
            nameLabel.setTextColor(context.getResources().getColor(R.color.primary_text));
        }

        return view;
    }
}
