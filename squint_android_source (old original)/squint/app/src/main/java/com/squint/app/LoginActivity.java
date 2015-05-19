package com.squint.app;

import java.io.Serializable;

import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseUser;
import com.squint.app.widget.BaseActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

public class LoginActivity<T> extends BaseActivity {
	
	public static final String TAG = LoginActivity.class.getSimpleName();
	private EditText mUsername;
	private EditText mPassword;
	private boolean isFrom;
	private Class<T> nextTo;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login);
		
		mTitle.setText(getString(R.string.title_login));
		mUsername = (EditText) findViewById(R.id.username);
		mPassword = (EditText) findViewById(R.id.password);
		if (isLogin()) skip(null);
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void onResume() {		
		super.onResume();
		Intent intent = getIntent();
		isFrom = intent.getBooleanExtra(ACTION_FROM, false);
		Serializable sClass = intent.getSerializableExtra(ACTION_TO);
		if (sClass != null && sClass instanceof Class) 	nextTo = (Class<T>) sClass;		
		//nextTo = (Class<T>) intent.getSerializableExtra(ACTION_TO);
		Log.d(TAG, "From/Next: " + isFrom + "/" + ((nextTo != null) ? nextTo.getName():"n/a") + ", User-To:" + intent.getStringExtra(USER_TO));
		Log.d(TAG, "From Settings? " + isFrom);
	}
	
	public void skip(View view) {
		if (view == null) isFrom = false;
		if (isFrom) {
			onBackPressed();
		} else {
			Intent intent = new Intent(this, MainActivity.class);	
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
		    startActivity(intent);
		    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
		}
	}
	
	private void toNext() {
		Intent intent = getIntent();
		Log.d(TAG, "To Class Name: " + nextTo.getName() + ", User: " + intent.getStringExtra(USER_FROM));	
		intent.setClass(this, nextTo);
	    finish();
		startActivity(intent);
	    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);				
	}
	
	@Override
	public void onBackPressed() {
		super.onBackPressed();
	    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
	}
	
	
	public void login(View view) {
		String username = mUsername.getText().toString();
		String password = mPassword.getText().toString();
		
		// TODO: Add more check-out for username and password!
		if (username.length() == 0 || password.length() == 0) {
			toast("Wrong username and/or password!");
			return;
		}
		
		ParseUser.logInInBackground(username, password,
									new LogInCallback() {
										@Override
										public void done(ParseUser user, ParseException e) {
											if (user != null) {
											    Log.d(TAG, "Login: " + "passed");
											    final String uid = user.getObjectId();

                                                //after successful login, associate user to installation(this phone), in order to receive push notifications
                                                ParseInstallation installation = ParseInstallation.getCurrentInstallation();
                                                installation.put("user",ParseUser.getCurrentUser());
                                                installation.saveInBackground();

											        new Handler().postDelayed(new Runnable() {
											            public void run() {
											            	  if (isFrom && nextTo != null) {
											            		  getIntent().putExtra(USER_FROM, uid);
											            		  toNext();
											            	  } else skip(null);
											            }
											        }, 100);
											    } else {
												  Log.d(TAG, "Login: " + "failed");
												  final int code = e.getCode();
												  final String msg = e.getMessage();
											      new Handler().postDelayed(new Runnable() {
											            public void run() {
														      onLoginFailed(code, msg);
											            }
											        }, 100);
											    }										
										}					
		});
		
		Log.d(TAG, "U/P: " + mUsername.getText().toString() + ", " + mPassword.getText().toString());
	}
	
	public void toSignupPage(View view) {
		Intent intent = new Intent(this, SignupActivity.class);
	    startActivity(intent);
	    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);		
	}
	
	private void onLoginFailed(int code, String msg) {
		toast("Error (" + code + "): " + msg + "!");
	}
	
	
}
