package com.ashvale.cmmath_one;

import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class SignupActivity extends Activity {

    public static final String TAG = SignupActivity.class.getSimpleName();
    private EditText mUsername;
    private EditText mPassword;
    private EditText mFirstname;
    private EditText mLastname;
    private EditText mInstitution;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);
        mUsername 	= (EditText) findViewById(R.id.username);
        mPassword 	= (EditText) findViewById(R.id.password);
        mFirstname  = (EditText) findViewById(R.id.firstname);
        mLastname   = (EditText) findViewById(R.id.lastname);
        mInstitution= (EditText) findViewById(R.id.institution);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void signup(View view) {
        String username     = mUsername.getText().toString();
        String password     = mPassword.getText().toString();
        String email        = mUsername.getText().toString();
        String firstname    = mFirstname.getText().toString();
        String lastname     = mLastname.getText().toString();
        String institution  = mInstitution.getText().toString();
        if (username.isEmpty() || password.isEmpty() || email.isEmpty()) {
            toast("Please fill in all fields");
            return;
        }

        ParseUser user = new ParseUser();
        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.put("first_name", firstname);
        user.put("last_name", lastname);
        user.put("notifications", 1);

        user.signUpInBackground(new SignUpCallback() {
            @Override
            public void done(ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "Sign Up done");
                    //after successful signup, associate user to installation(this phone), in order to receive push notifications
                    ParseInstallation installation = ParseInstallation.getCurrentInstallation();
                    installation.put("user",ParseUser.getCurrentUser());
                    installation.saveInBackground();

                    toPreferencePage();
                    //toMainPage();
                } else {
                    Log.d("cm_app", "Sign Up: " + "failed"+e.getMessage());
                    onSignupFailed(e.getCode(), e.getMessage());
                }
            }

        });
    }

    private void onSignupFailed(int code, String msg) {
        toast("Error (" + code + "): " + msg + "!");
    }

    public void toLoginPage(View view) {
        onBackPressed();
    }

    private void toPreferencePage() {
        Intent intent = new Intent(this, UserPreferenceActivity.class);
        startActivity(intent);
    }
}
