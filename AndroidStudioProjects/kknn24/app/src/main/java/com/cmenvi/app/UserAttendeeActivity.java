package com.cmenvi.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.cmenvi.app.widget.BaseActivity;


public class UserAttendeeActivity extends BaseActivity {

    public ParseUser selfuser;
    public ParseObject selfperson;
    public EditText fname_input;
    public EditText lname_input;
    public EditText inst_input;
    public TextView save_attendee;
    public TextView skip_attendee;
    public TextView status_label;
    public String fname;
    public String lname;
    public String inst;
    public String user_email;
    protected cmenviApplication app;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        //initialize and setup
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_attendee);
        mTitle.setText("Attendee Setup");
        configOptions(OPTION_NONE, OPTION_NONE);

        fname_input = (EditText) findViewById(R.id.fname_input);
        lname_input = (EditText) findViewById(R.id.lname_input);
        inst_input = (EditText) findViewById(R.id.inst_input);
        status_label = (TextView) findViewById(R.id.status);
        save_attendee = (TextView) findViewById(R.id.save_attendee);
        save_attendee.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    saveAttendee();
                }
            });
        skip_attendee = (TextView) findViewById(R.id.skip_attendee);
        skip_attendee.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                skipAttendee();
            }
        });

        //disable the button before we find out whether this user is a person
        save_attendee.setEnabled(false);
        save_attendee.setTextColor(getResources().getColor(R.color.button_title));
        Toast.makeText(this, "Searching attendees...", Toast.LENGTH_LONG).show();

         //get user info (and check if is person)
        if (ParseUser.getCurrentUser() != null) {
            selfuser = ParseUser.getCurrentUser();
        }
        user_email = selfuser.getEmail();
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
        personquery.whereEqualTo("email", user_email);
        personquery.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if (parseObject != null) {
                    //found a match, user is person: skip to user preference activity
                    app = (cmenviApplication) getApplication();
                    app.isPerson = true;
                    toUserPreference();
                } else {
                    //no match, user not a person
                    status_label.setText("Sorry, we couldn't find you in the attendee list, if you are attending this event, please provide your information below.");
                    save_attendee.setEnabled(true);
                    save_attendee.setTextColor(getResources().getColor(R.color.dark_accent));
                }
            }
        });
    }

    public void saveAttendee()
    {
        fname = fname_input.getText().toString();
        lname = lname_input.getText().toString();
        inst = inst_input.getText().toString();
        //check fields
        if (fname.length()>0 && lname.length()>0 && inst.length()>0) {
            //all fields are non-empty, can sign up as attendee
            //first disable the button so no double-clicking
            save_attendee.setEnabled(false);
            save_attendee.setTextColor(getResources().getColor(R.color.background));

            ParseObject person = new ParseObject("Person");
            person.put("is_user", 1);
            person.put("chat_status", 1);
            person.put("email", user_email);
            person.put("first_name", fname);
            person.put("last_name", lname);
            person.put("institution", inst);
            person.put("user", selfuser);

            selfuser.put("person", person);
            selfuser.put("is_person", 1);
            selfuser.put("chat_status", 1);
            selfuser.put("first_name", fname);
            selfuser.put("last_name", lname);

            selfperson = person;
            Toast.makeText(this, "Saving...", Toast.LENGTH_LONG).show();
            selfuser.saveInBackground(new SaveCallback() {
                @Override
                public void done(ParseException e) {
                    //created person successfully, go to chat/email preference setup page
                    save_attendee.setEnabled(true);
                    save_attendee.setTextColor(getResources().getColor(R.color.dark_accent));
                    app = (cmenviApplication) getApplication();
                    app.isPerson = true;
                    toUserPreference();
                }
            });
        }
        else
        {
            Toast.makeText(this, "Please fill out all fields.", Toast.LENGTH_LONG).show();

        }
    }

    public void skipAttendee()
    {
        toMainPage();
    }

    private void toMainPage() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
        overridePendingTransition(R.anim.page_left_slide_in, R.anim.page_left_slide_out);
    }

    private void toUserPreference() {
        Intent intent = new Intent(this, UserPreferenceActivity.class);
        startActivity(intent);
    }

}
