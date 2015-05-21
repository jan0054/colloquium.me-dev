package com.cmmath.app;

import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseUser;
import com.parse.SignUpCallback;
import com.cmmath.app.widget.BaseActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

public class SignupActivity extends BaseActivity {
	
	public static final String TAG = SignupActivity.class.getSimpleName();
	private EditText mUsername;
	private EditText mPassword;
	private EditText mEmail;


	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_signup);		
		mTitle.setText(getString(R.string.title_signup));
		mUsername 	= (EditText) findViewById(R.id.username);
		mPassword 	= (EditText) findViewById(R.id.password);
		mEmail		= (EditText) findViewById(R.id.email);		
	}
	
	@Override
	public void onResume() {		
		super.onResume();
	}
	
	public void signup(View view) {
		String username = mUsername.getText().toString();
		String password = mPassword.getText().toString();
		String email    = mEmail.getText().toString();
		if (username.isEmpty() || password.isEmpty() || email.isEmpty()) {
			toast("Wrong username and/or password!");
			return;
		}
		
		ParseUser user = new ParseUser();
		user.setUsername(username);
		user.setPassword(password);
		user.setEmail(email);
		user.put("notifications", 1);
		user.signUpInBackground(new SignUpCallback() {

			@Override
			public void done(ParseException e) {				
				if (e == null) {
					Log.d(TAG, "Sign Up: " + "passed");
                    //after successful signup, associate user to installation(this phone), in order to receive push notifications
                    ParseInstallation installation = ParseInstallation.getCurrentInstallation();
                    installation.put("user",ParseUser.getCurrentUser());
                    installation.saveInBackground();

                    toPreferencePage();
					//toMainPage();
				} else {
					Log.d(TAG, "Sign Up: " + "failed");
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
	
	private void toMainPage() {
		Intent intent = new Intent(this, MainActivity.class);	
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
	    startActivity(intent);
	    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
	}

    private void toPreferencePage()
    {
        Intent intent = new Intent(this, UserAttendeeActivity.class);
        startActivity(intent);
    }
}
