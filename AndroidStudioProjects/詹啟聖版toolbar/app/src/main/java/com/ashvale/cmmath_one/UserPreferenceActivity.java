package com.ashvale.cmmath_one;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;

import com.parse.ParseObject;
import com.parse.ParseUser;


public class UserPreferenceActivity extends DetailActivity {

    public ParseUser selfuser;
    public int email_on;
    public int event_on;
    public int chat_on;
    public int is_person;
    public String src_act;
    public String pref_fnamestr;
    public String pref_lnamestr;
    public String pref_inststr;
    public String pref_linkstr;
    public ParseObject selfperson;

    public android.support.v7.widget.SwitchCompat pref_emailswitch;
    public android.support.v7.widget.SwitchCompat pref_eventswitch;
    public android.support.v7.widget.SwitchCompat pref_chatswitch;
    public EditText pref_fnameinput;
    public EditText pref_lnameinput;
    public EditText pref_instinput;
    public EditText pref_linkinput;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_preference);
        super.onCreateView();

        src_act = this.getIntent().getExtras().getString("src");

        //default disable stuff
        pref_emailswitch = (android.support.v7.widget.SwitchCompat) findViewById(R.id.pref_emailswitch);
        pref_eventswitch = (android.support.v7.widget.SwitchCompat) findViewById(R.id.pref_eventswitch);
        pref_chatswitch = (android.support.v7.widget.SwitchCompat) findViewById(R.id.pref_chatswitch);
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
            is_person = 1;
        }
        setupData();
    }

    public void setupData()
    {
        if (is_person == 1)
        {
            //user is person
            pref_emailswitch.setEnabled(true);
            pref_eventswitch.setEnabled(true);
            pref_chatswitch.setEnabled(true);
            pref_fnameinput.setEnabled(true);
            pref_lnameinput.setEnabled(true);
            pref_instinput.setEnabled(true);
            pref_linkinput.setEnabled(true);
            //set email/chat variables
            email_on = selfuser.getInt("email_status");
            event_on = selfuser.getInt("event_status");
            chat_on = selfuser.getInt("chat_status");
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
            if (selfuser.containsKey("first_name"))
            {
                pref_fnamestr = selfuser.getString("first_name");
            }
            pref_fnameinput.setText(pref_fnamestr);
            if (selfuser.containsKey("last_name"))
            {
                pref_lnamestr = selfuser.getString("last_name");
            }
            pref_lnameinput.setText(pref_lnamestr);
            if (selfuser.containsKey("institution"))
            {
                pref_inststr = selfuser.getString("institution");
            }
            pref_instinput.setText(pref_inststr);
            if (selfuser.containsKey("link"))
            {
                pref_linkstr = selfuser.getString("link");
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
            selfuser.put("first_name", pref_fnameinput.getText().toString());
            selfuser.put("last_name", pref_lnameinput.getText().toString());
            selfuser.put("institution", pref_instinput.getText().toString());
            selfuser.put("link", pref_linkinput.getText().toString());
            selfuser.saveInBackground();
        }
        finischSetting(null);
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
    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void finischSetting(View view) {
        Intent intent;
        if(src_act.equals("settings")) {
            intent = new Intent(this, SettingsActivity.class);
        } else if(src_act.equals("signup")) {
            intent = new Intent(this, AddeventActivity.class);
        } else {
            intent = new Intent(this, HomeActivity.class);
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

}
