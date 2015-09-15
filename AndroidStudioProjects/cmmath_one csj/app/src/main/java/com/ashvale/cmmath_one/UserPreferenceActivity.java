package com.ashvale.cmmath_one;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.HashSet;
import java.util.List;
import java.util.Set;


public class UserPreferenceActivity extends BaseActivity {

    public ParseUser selfuser;
    public int email_on;
    public int event_on;
    public int chat_on;
    public int is_person;
    public String pref_fnamestr;
    public String pref_lnamestr;
    public String pref_inststr;
    public String pref_linkstr;
    public ParseObject selfperson;

    public Switch pref_emailswitch;
    public Switch pref_eventswitch;
    public Switch pref_chatswitch;
    public EditText pref_fnameinput;
    public EditText pref_lnameinput;
    public EditText pref_instinput;
    public EditText pref_linkinput;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_preference);

        //default disable stuff
        pref_emailswitch = (Switch) findViewById(R.id.pref_emailswitch);
        pref_eventswitch = (Switch) findViewById(R.id.pref_eventswitch);
        pref_chatswitch = (Switch) findViewById(R.id.pref_chatswitch);
        pref_fnameinput = (EditText) findViewById(R.id.pref_fnameinput);
        pref_lnameinput = (EditText) findViewById(R.id.pref_lnameinput);
        pref_instinput = (EditText) findViewById(R.id.pref_instinput);
        pref_linkinput = (EditText) findViewById(R.id.pref_linkinput);
        pref_emailswitch.setEnabled(false);
        pref_eventswitch.setEnabled(false);
        pref_chatswitch.setEnabled(false);
        pref_fnameinput.setEnabled(false);
        pref_lnameinput.setEnabled(false);
        pref_instinput.setEnabled(false);
        pref_linkinput.setEnabled(false);
        is_person = 0;
        email_on = 0;
        event_on = 0;
        chat_on = 0;
        pref_fnamestr = "";
        pref_lnamestr = "";
        pref_inststr = "";
        pref_linkstr = "";

        //check if current user is person
        if (ParseUser.getCurrentUser() != null)
        {
            selfuser = ParseUser.getCurrentUser();
        }
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
        personquery.whereEqualTo("email", selfuser.getEmail());
        personquery.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if (parseObject != null)
                {
                    //found a match, user is person
                    is_person = 1;
                    selfperson = parseObject;
                }
                else
                {
                    //no match, user not a person
                    is_person = 0;
                }
                setupData();
            }
        });
    }

    public void setupData()
    {
        if (is_person == 1)
        {
            //user is person
            pref_emailswitch.setEnabled(true);
            pref_chatswitch.setEnabled(true);
            pref_linkinput.setEnabled(true);
            //set email/chat variables
            if (selfuser.containsKey("email_status"))
            {
                email_on = selfuser.getInt("email_status");
            }
            else
            {
                email_on = 0;
            }
            if (selfuser.containsKey("event_status"))
            {
                event_on = selfuser.getInt("event_status");
            }
            else
            {
                event_on = 1;
            }
            if (selfuser.containsKey("chat_status"))
            {
                chat_on = selfuser.getInt("chat_status");
            }
            else
            {
                chat_on = 1;
            }
            //set email/chat switch initial position
            if (email_on == 1)
            {
                pref_emailswitch.setChecked(true);
            }
            else
            {
                pref_emailswitch.setChecked(false);
            }
            if (event_on == 1)
            {
                pref_eventswitch.setChecked(true);
            }
            else
            {
                pref_eventswitch.setChecked(false);
            }
            if (chat_on == 1)
            {
                pref_chatswitch.setChecked(true);
            }
            else
            {
                pref_chatswitch.setChecked(false);
            }
            //set listener and callback for the switches
            pref_emailswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked) {
                        //email set to public
                        email_on = 1;
                    } else if (!isChecked) {
                        //email set to private
                        email_on = 0;
                    }
                }
            });
            pref_eventswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked) {
                        //email set to public
                        event_on = 1;
                    } else if (!isChecked) {
                        //email set to private
                        event_on = 0;
                    }
                }
            });
            pref_chatswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked) {
                        //chat set to on
                        chat_on = 1;
                    } else if (!isChecked) {
                        //chat set to off
                        chat_on = 0;
                    }
                }
            });
            //get link if exist and set as default text in url input
            if (selfperson.containsKey("first_name"))
            {
                pref_linkstr = selfperson.getString("first_name");
            }
            pref_fnameinput.setText(pref_fnamestr);
            if (selfperson.containsKey("last_name"))
            {
                pref_lnamestr = selfperson.getString("last_name");
            }
            pref_lnameinput.setText(pref_lnamestr);
            if (selfperson.containsKey("institution"))
            {
                pref_inststr = selfperson.getString("institution");
            }
            pref_instinput.setText(pref_inststr);
            if (selfperson.containsKey("link"))
            {
                pref_linkstr = selfperson.getString("link");
            }
            pref_linkinput.setText(pref_linkstr);
        }
        else
        {
            //user is not person
        }
    }

    public void savePreferences()
    {
        if (is_person == 1)
        {
            selfuser.put("email_status", email_on);
            selfuser.put("event_status", event_on);
            selfuser.put("chat_status", chat_on);
            selfuser.put("is_person", is_person);
            selfuser.put("first_name", pref_fnameinput.getText().toString());
            selfuser.put("last_name", pref_lnameinput.getText().toString());
            selfuser.put("institution", pref_instinput.getText().toString());
            selfuser.put("link", pref_linkinput.getText().toString());
            selfuser.saveInBackground();
        }
   //     toMainPage();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_userpreference, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.savepreference) {
            savePreferences();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
