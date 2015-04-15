package com.squint.app;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.squint.app.widget.BaseActivity;


public class UploadCareerActivity extends BaseActivity {

    public int career_type; // 0=offer, 1=seek

    TextView contactname_label;
    TextView contactemail_label;
    TextView position_label;
    TextView institution_label;
    TextView datetime_label;
    TextView description_label;
    TextView weblink_label;

    EditText contactname;
    EditText contactemail;
    EditText position;
    EditText institution;
    EditText datetime;
    EditText description;
    EditText weblink;

    String contactname_str;
    String contactemail_str;
    String position_str;
    String institution_str;
    String datetime_str;
    String description_str;
    String weblink_str;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_upload_career);

        career_type = this.getIntent().getExtras().getInt("career_type");

        contactname = (EditText)findViewById(R.id.contactname);
        contactemail = (EditText)findViewById(R.id.contactemail);
        position = (EditText)findViewById(R.id.position);
        institution = (EditText)findViewById(R.id.institution);
        datetime = (EditText)findViewById(R.id.datetime);
        description = (EditText)findViewById(R.id.description);
        weblink = (EditText)findViewById(R.id.weblink);

        contactname_label = (TextView)findViewById(R.id.contactname_label);
        contactemail_label = (TextView)findViewById(R.id.contactemail_label);
        position_label = (TextView)findViewById(R.id.position_label);
        institution_label = (TextView)findViewById(R.id.institution_label);
        datetime_label = (TextView)findViewById(R.id.datetime_label);
        description_label = (TextView)findViewById(R.id.description_label);
        weblink_label = (TextView)findViewById(R.id.weblink_label);

        String title = "Position Available";
        if (career_type == 1)
        {
            title = "Seeking Position";
            contactemail_label.setText("Name:");
            position_label.setText("Seeking position:");
            institution_label.setText("Education (degree/institution):");
            datetime_label.setText("(Expected) Date of degree:");
            description_label.setText("Short self description:");
        }
        mTitle.setText(title);
        configOptions(OPTION_BACK, OPTION_NONE);
    }

    public void postCareer(View view)
    {
        contactname_str = contactname.getText().toString();
        contactemail_str = contactemail.getText().toString();
        position_str = position.getText().toString();
        institution_str = institution.getText().toString();
        datetime_str = datetime.getText().toString();
        description_str = description.getText().toString();
        weblink_str = weblink.getText().toString();
        if (checkFields())
        {
            //all fields filled
            ParseObject careerpost = new ParseObject("career");
            careerpost.put("offer_seek", career_type);
            careerpost.put("contact_name", contactname_str);
            careerpost.put("contact_email", contactemail_str);
            careerpost.put("position", position_str);
            careerpost.put("institution", institution_str);
            careerpost.put("time_duration", datetime_str);
            careerpost.put("description", description_str);
            if (weblink_str.length()>0)
            {
                careerpost.put("link", weblink_str);
            }
            ParseUser cur_user = ParseUser.getCurrentUser();
            ParseObject cur_person = cur_user.getParseObject("person");
            careerpost.put("posted_by", cur_person);
            careerpost.saveInBackground(new SaveCallback() {
                @Override
                public void done(ParseException e) {
                    onBackPressed();
                }
            });
        }
        else
        {
            //found empty fields
            Toast.makeText(this, "Please fill all required fields", Toast.LENGTH_SHORT).show();
        }

    }

    public boolean checkFields()
    {
        if (contactname_str.length()<1)
        {
            return  false;
        }
        else if (contactemail_str.length()<1)
        {
            return false;
        }
        else if (position_str.length()<1)
        {
            return  false;
        }
        else if (institution_str.length()<1)
        {
            return false;
        }
        else if (description_str.length()<1)
        {
            return  false;
        }
        else
        {
            return  true;
        }
    }
}
