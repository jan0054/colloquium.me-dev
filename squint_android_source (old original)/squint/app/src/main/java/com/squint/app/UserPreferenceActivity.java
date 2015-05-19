package com.squint.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.squint.app.widget.BaseActivity;


public class UserPreferenceActivity extends BaseActivity {

    public ParseUser selfuser;
    public int email_on;
    public int chat_on;
    public int is_person;
    public String link_str;
    public ParseObject selfperson;

    public Switch email_switch;
    public Switch chat_switch;
    public EditText link_input;
    public TextView save_preference;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_preference);
        mTitle.setText(getString(R.string.title_conversation));
        configOptions(OPTION_NONE, OPTION_NONE);

        save_preference = (TextView) findViewById(R.id.save_preference);
        save_preference.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                savePreferences();
            }
        });
        //default disable stuff
        email_switch = (Switch) findViewById(R.id.email_switch);
        chat_switch = (Switch) findViewById(R.id.chat_switch);
        link_input = (EditText) findViewById(R.id.link_input);
        email_switch.setEnabled(false);
        chat_switch.setEnabled(false);
        link_input.setEnabled(false);
        is_person = 0;
        email_on = 0;
        chat_on = 0;
        link_str = "";

        //check if current user is person
        if (ParseUser.getCurrentUser() != null)
        {
            selfuser = ParseUser.getCurrentUser();
        }
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("person");
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
            email_switch.setEnabled(true);
            chat_switch.setEnabled(true);
            link_input.setEnabled(true);
            //set email/chat variables
            if (selfuser.containsKey("email_on"))
            {
                email_on = selfuser.getInt("email_on");
            }
            else
            {
                email_on = 0;
            }
            if (selfuser.containsKey("chat_on"))
            {
                chat_on = selfuser.getInt("chat_on");
            }
            else
            {
                chat_on = 1;
            }
            //set email/chat switch initial position
            if (email_on == 1)
            {
                email_switch.setChecked(true);
            }
            else
            {
                email_switch.setChecked(false);
            }
            if (chat_on == 1)
            {
                chat_switch.setChecked(true);
            }
            else
            {
                chat_switch.setChecked(false);
            }
            //set listener and callback for the switches
            email_switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked)
                    {
                        //email set to public
                        email_on = 1;
                    }
                    else if (!isChecked)
                    {
                        //email set to private
                        email_on = 0;
                    }
                }
            });
            chat_switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked)
                    {
                        //chat set to on
                        chat_on = 1;
                    }
                    else if (!isChecked)
                    {
                        //chat set to off
                        chat_on = 0;
                    }
                }
            });
            //get link if exist and set as default text in url input
            if (selfperson.containsKey("link"))
            {
                link_str = selfperson.getString("link");
            }
            link_input.setText(link_str);
            //set status text with name included;
            String lname = selfperson.getString("last_name");
            String fname = selfperson.getString("first_name");
            String status_str = String.format("Hello %s %s, please set your email and chat preferences below, you can change these preferences anytime.", fname, lname);
            TextView status_tv = (TextView) findViewById(R.id.status);
            status_tv.setText(status_str);
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
            link_str = link_input.getText().toString();
            selfuser.put("email_on", email_on);
            selfuser.put("chat_on", chat_on);
            selfuser.put("isperson", is_person);
            selfuser.put("person", selfperson);
            selfuser.saveInBackground();
            selfperson.put("email_on", email_on);
            selfperson.put("chat_on", chat_on);
            selfperson.put("is_user", is_person);
            selfperson.put("user", selfuser);
            selfperson.put("link", link_str);
            selfperson.saveInBackground();
        }
        toMainPage();
    }
/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_user_preference, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
*/
    private void toMainPage() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
        overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
    }
}
