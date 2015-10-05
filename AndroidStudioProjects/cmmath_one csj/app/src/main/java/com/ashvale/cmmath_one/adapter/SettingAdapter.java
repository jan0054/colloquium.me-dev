package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.LoginActivity;
import com.ashvale.cmmath_one.R;
import com.parse.ParseUser;

/**
 * Created by csjan on 9/10/15.
 */
public class SettingAdapter extends BaseAdapter {

    private final Context context;

    public SettingAdapter(Context context) {
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
                if(ParseUser.getCurrentUser()!=null)//user log in
                {
                    returnobject = userIn;
                }
                else//no user
                {
                    returnobject = userOut;
                }
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
                view = inflater.inflate(R.layout.listitem_usersetting, vg, false);
            }
            else
            {
                view = inflater.inflate(R.layout.listitem_standardsetting, vg, false);
            }
        }

        TextView primarylabel = (TextView)view.findViewById(R.id.primarylabel);
        TextView secondarylabel = (TextView)view.findViewById(R.id.secondarylabel);

        String[] primary = context.getResources().getStringArray(R.array.setting_primary_label_array);
        String[] secondary = context.getResources().getStringArray(R.array.setting_secondary_label_array);
        String[] userIn = {"Signed in as ", "Sign out to switch users", "Sign Out"};
        String[] userOut = {"Not signed in yet", "Sign in to access social features", "Sign In"};

        if (position != 0)
        {
            primarylabel.setText(primary[position-1]);
            secondarylabel.setText(secondary[position-1]);
        }
        else if (position == 0)
        {
            Button userbutton = (Button)view.findViewById(R.id.userbutton);
            userbutton.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    //Toast.makeText(context, "Sign in/out button tap", Toast.LENGTH_SHORT).show();
                    SharedPreferences userStatus;
                    userStatus = context.getSharedPreferences("LOGIN", 0); //6 = readable+writable by other apps, use 0 for private
                    SharedPreferences.Editor editor = userStatus.edit();
                    editor.putInt("skiplogin", 0);
                    editor.commit();
                    if (ParseUser.getCurrentUser() == null)//need sing in
                    {
                        context.startActivity(new Intent(context, LoginActivity.class));
                    } else//log out
                    {
                        ParseUser.logOut();
                        notifyDataSetChanged();
                    }
                }
            });
            if(ParseUser.getCurrentUser()!=null) //user log in
            {
                String userIn0 = userIn[0]+ParseUser.getCurrentUser().get("first_name")+" "+ParseUser.getCurrentUser().get("last_name");
                primarylabel.setText(userIn0);
                secondarylabel.setText(userIn[1]);
                userbutton.setText(userIn[2]);
            }
            else //no user
            {
                primarylabel.setText(userOut[0]);
                secondarylabel.setText(userOut[1]);
                userbutton.setText(userOut[2]);
            }
        }


        return view;
    }
}
