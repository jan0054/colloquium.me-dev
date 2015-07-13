package com.ashvale.drawer_demo;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import java.lang.reflect.Array;

/**
 * Created by csjan on 7/13/15.
 */
public class SettingArrayAdapter extends BaseAdapter {

    private final Context context;

    public SettingArrayAdapter(Context context) {
        //super(context);
        this.context = context;
    }

    @Override
    public int getCount()
    {
        return 5;
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        String[] userIn = {"Signed in as XXX", "Sign out to switch users", "Sign Out"};
        String[] userOut = {"Not signed in yet", "Sign in to access social features", "Sign In"};
        String[] feedback = {"App Feedback", "Email us with app questions or feedback"};
        String[] privacy = {"Privacy & Terms", "Info on how we protect and secure your data"};
        String[] about = {"About Us", "Learn about the developers of this app"};
        String[] preference = {"User Preference", "Setup or change user info and social options"};
        String[] returnobject = {""};
        switch (position)
        {
            case 0:
                returnobject = userIn;
                break;
            case 1:
                returnobject =  feedback;
                break;
            case 2:
                returnobject = privacy;
                break;
            case 3:
                returnobject = about;
                break;
            case 4:
                returnobject = preference;
                break;
        }
        return  returnobject;
    }

    @Override
    public int getViewTypeCount()
    {
        return 2;
    }

    @Override
    public int getItemViewType(int position)
    {
        if (position ==0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        int type = getItemViewType(position);
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            if (type==0)
            {
                view = inflater.inflate(R.layout.list_item_setting, vg, false);
            }
            else
            {
                view = inflater.inflate(R.layout.list_item_generic, vg, false);
            }
        }

        TextView primarylabel = (TextView)view.findViewById(R.id.primarylabel);
        TextView secondarylabel = (TextView)view.findViewById(R.id.secondarylabel);

        String[] primary = context.getResources().getStringArray(R.array.setting_primary_label_array);
        String[] secondary = context.getResources().getStringArray(R.array.setting_secondary_label_array);
        String[] userIn = {"Signed in as XXX", "Sign out to switch users", "Sign Out"};
        String[] userOut = {"Not signed in yet", "Sign in to access social features", "Sign In"};

        if (position != 0)
        {
            primarylabel.setText(primary[position-1]);
            secondarylabel.setText(secondary[position-1]);
        }
        else if (position == 0)
        {
            Button userbutton = (Button)view.findViewById(R.id.userbutton);
            userbutton.setOnClickListener(new View.OnClickListener()
            {
                public void onClick(View v)
                {
                    Toast.makeText(context, "Sign in/out button tap", Toast.LENGTH_SHORT).show();
                }
            });
                primarylabel.setText(userOut[0]);
                secondarylabel.setText(userOut[1]);
                userbutton.setText(userOut[2]);
            }


            return view;
    }
}
