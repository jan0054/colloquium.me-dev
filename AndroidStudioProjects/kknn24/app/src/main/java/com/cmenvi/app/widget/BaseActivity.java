package com.cmenvi.app.widget;

import com.cmenvi.app.MainActivity;
import com.cmenvi.app.UserAttendeeActivity;
import com.parse.GetCallback;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.ParsePush;
import com.parse.SaveCallback;
import com.cmenvi.app.LoginActivity;
import com.cmenvi.app.R;
import com.cmenvi.app.UploadCareerActivity;
import com.cmenvi.app.data._PARAMS;
import com.cmenvi.app.cmenviApplication;

import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class BaseActivity extends FragmentActivity implements OnClickListener, AdapterView.OnItemSelectedListener {
	
	public static final String		TAG = BaseActivity.class.getSimpleName();
	
	public ActionBar	mActionBar;
	public TextView		mTitle;
	public TintableImageView	mOptionLeft;
	public TintableImageView	mOptionRight;
	public TintableImageView	mOptionExtraLeft;
	public TintableImageView	mOptionExtraRight;
    public Spinner dayspinner;
    public Spinner careerspinner;

	public final static int OPTION_NONE			= 0;
	public final static int OPTION_BACK			= R.drawable.actionbar_back;
	public final static int OPTION_TALK			= R.drawable.chat_64_white;
	public final static int OPTION_LOGIN 		= R.drawable.login_64_white;
	public final static int OPTION_LOGOUT		= R.drawable.logout_64_white;
    public final static int OPTION_USER         = R.drawable.preference_64_white;
	public final static int OPTION_DAYS         = 98;
    public final static int OPTION_CAREER       = 99;
	public final static int OPTION_NEWPOST		= R.drawable.actionbar_new;
	public final static int OPTION_NEWCOMMENT	= 91;
	public final static int OPTION_SAVE			= 92;

	public static final String ACTION_FROM = "com.cmenvi.app.action.from";
	public static final String ACTION_TO = "com.cmenvi.app.action.to";
	public static final String USER_TO = "com.cmenvi.app.user.to";
	public static final String USER_FROM = "user";

    protected cmenviApplication app;

	//private LayoutInflater 	layoutInflater;
	//private View 				progress_layout;
	//private FrameLayout 		container;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// Initial Parse
		new Thread(new Runnable() {
	        @Override
	        public void run() {     
        		Parse.initialize(getBaseContext(), _PARAMS.APPLICATION_ID, _PARAMS.CLIENT_KEY);
                ParsePush.subscribeInBackground("", new SaveCallback() {
                    @Override
                    public void done(ParseException e) {
                        if (e == null) {
                            Log.d("com.parse.push", "successfully subscribed to the broadcast channel.");
                        } else {
                            Log.e("com.parse.push", "failed to subscribe for push", e);
                        }
                    }
                });
	        }
	    }).start();
		
        mActionBar = getActionBar();
		mActionBar.setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        mActionBar.setCustomView(R.layout.actionbar);
		mActionBar.setDisplayShowHomeEnabled(false);
		mActionBar.setBackgroundDrawable(getResources().getDrawable(R.drawable.header_gradient_background));
		mActionBar.setDisplayUseLogoEnabled(false);
		mActionBar.setDisplayShowTitleEnabled(false);
		//mActionBar.setLogo(R.drawable.bg_transp);
		//mActionBar.setIcon(R.drawable.bg_transp);
		View view = mActionBar.getCustomView();
		mTitle = (TextView)view.findViewById(R.id.title);
		
		mOptionLeft = (TintableImageView)view.findViewById(R.id.opt_left);
		mOptionRight = (TintableImageView)view.findViewById(R.id.opt_right);
		mOptionExtraLeft = (TintableImageView)view.findViewById(R.id.opt_extra_left);
		mOptionExtraRight = (TintableImageView)view.findViewById(R.id.opt_extra_right);
		
		mOptionLeft.setOnClickListener(this);
		mOptionRight.setOnClickListener(this);
		mOptionExtraLeft.setOnClickListener(this);
		mOptionExtraRight.setOnClickListener(this);

        dayspinner = (Spinner) findViewById(R.id.dayspinner);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this,
                R.array.days_array, R.layout.spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // Apply the adapter to the spinner
        dayspinner.setAdapter(adapter);
        dayspinner.setOnItemSelectedListener(this);



        careerspinner = (Spinner) findViewById(R.id.careerspinner);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter2 = ArrayAdapter.createFromResource(this,
                R.array.career_array, R.layout.spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter2.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // Apply the adapter to the spinner
        careerspinner.setAdapter(adapter2);
        careerspinner.setOnItemSelectedListener(this);

	}

    public void onItemSelected(AdapterView<?> parent, View view,
                               int pos, long id) {
        // An item was selected. You can retrieve the selected item using
        // parent.getItemAtPosition(pos)
        switch (parent.getId())
        {
            case R.id.careerspinner:
                //post career spinner
                if (pos == 1)
                {
                    //offer
                    Intent postCareerIntent = new Intent(this, UploadCareerActivity.class);
                    postCareerIntent.putExtra("career_type",  0);
                    startActivity(postCareerIntent);
                    careerspinner.setSelection(0);
                    break;
                }
                else if (pos == 2)
                {
                    //seek
                    Intent postCareerIntent = new Intent(this, UploadCareerActivity.class);
                    postCareerIntent.putExtra("career_type",  1);
                    startActivity(postCareerIntent);
                    careerspinner.setSelection(0);
                    break;
                }
                else
                {
                    break;
                }

            case R.id.dayspinner:
                //select_day spinner
                switch (pos)
                {
                    case 0:
                        updateDaySpinner(this,0);

                        break;
                    case 1:
                        updateDaySpinner(this,1);
                        break;
                    case 2:
                        updateDaySpinner(this,2);
                        break;
                    case 3:
                        updateDaySpinner(this,3);
                        break;
                }

                break;
        }
    }

    static void updateDaySpinner(Context context, int day) {

        Intent dayIntent = new Intent("day_intent");
        //put whatever data you want to send, if any
        dayIntent.putExtra("day", day);
        //send broadcast
        context.sendBroadcast(dayIntent);
    }

    public void onNothingSelected(AdapterView<?> parent) {
        // Another interface callback
    }
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == android.R.id.home) {
			onBackPressed();
			return true;
		} else return super.onOptionsItemSelected(item);
	}
	
	@Override
	  protected void onResume()
	  {
	    super.onResume();

        app=(cmenviApplication)getApplication();
        app.isVisible = true;

	    //opening transition animations
	    //overridePendingTransition(R.anim.page_translate_open,R.anim.page_scale_close);
	  }

	  @Override
	  protected void onPause()
	  {
	    super.onPause();
          app=(cmenviApplication)getApplication();
          app.isVisible = false;
	    //closing transition animations
	    //overridePendingTransition(R.anim.page_scale_open,R.anim.page_translate_close);
	  }
	
	@Override
	public void onBackPressed() {
		super.onBackPressed();
	    overridePendingTransition (R.anim.page_right_slide_in, R.anim.page_right_slide_out);
	}
	
	
	
    public final boolean isNetwork() {    	
	    ConnectivityManager connection = (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo info = connection.getActiveNetworkInfo();
	    return (info != null && info.isConnected());
    }
    
	public boolean isLogin() {
		ParseUser user = ParseUser.getCurrentUser();
		Log.d(TAG, "User Existing: " + (user != null));
		return (user != null);
	}
    
    
    
    public void clearOptions() {
    	mOptionLeft.setImageDrawable(null);
    	mOptionRight.setImageDrawable(null);
    	mOptionLeft.setVisibility(View.GONE);
    	mOptionRight.setVisibility(View.GONE);
        dayspinner.setVisibility(View.GONE);
        careerspinner.setVisibility(View.GONE);
    }
    
    public void configOptions(int leftDrawableId, int rightDrawableId) {
    	if (leftDrawableId != OPTION_NONE) {
	    	mOptionLeft.setImageResource(leftDrawableId);
	    	mOptionLeft.setTag(leftDrawableId);
	    	mOptionLeft.setVisibility(View.VISIBLE);
    	}

        else {
	    	mOptionLeft.setImageDrawable(null);
	    	mOptionLeft.setVisibility(View.GONE);    		
    	}
        if (rightDrawableId == OPTION_DAYS)
        {
            mOptionRight.setImageDrawable(null);
            mOptionRight.setVisibility(View.GONE);
            dayspinner.setVisibility(View.VISIBLE);
            careerspinner.setVisibility(View.GONE);
            Log.d(TAG, "SPINNER DAY");
        }
        else if (rightDrawableId == OPTION_CAREER)
        {
            mOptionRight.setImageDrawable(null);
            mOptionRight.setVisibility(View.GONE);
            careerspinner.setVisibility(View.VISIBLE);
            dayspinner.setVisibility(View.GONE);
            Log.d(TAG, "SPINNER CAREER");
        }
    	else if (rightDrawableId != OPTION_NONE) {
	    	mOptionRight.setImageResource(rightDrawableId);
	    	mOptionRight.setTag(rightDrawableId);
	    	mOptionRight.setVisibility(View.VISIBLE);
            dayspinner.setVisibility(View.GONE);
            careerspinner.setVisibility(View.GONE);
    	}
        else {
    		mOptionRight.setImageDrawable(null);
    		mOptionRight.setVisibility(View.GONE);
            dayspinner.setVisibility(View.GONE);
            careerspinner.setVisibility(View.GONE);
    	}
    }
    
    public void connectionAlert() {
        new AlertDialog.Builder(this)
     		.setMessage(getString(R.string.dialog_network_error_content)) 
     		.setTitle(getString(R.string.dialog_network_error_title)) 
     		.setCancelable(true) 
     		.setNeutralButton(getString(android.R.string.ok), 
        new DialogInterface.OnClickListener() { 
     		@Override
			public void onClick(DialogInterface dialog, int whichButton){
     			//finish(); 
     		}
     		}).show(); 
     }
    
    public void showAlert(String title, String message) {
        new AlertDialog.Builder(this)
     		.setMessage(message) 
     		.setTitle(title) 
     		.setCancelable(true) 
     		.setNeutralButton(getString(android.R.string.ok), 
        new DialogInterface.OnClickListener() { 
     		@Override
			public void onClick(DialogInterface dialog, int whichButton){
     			//finish(); 
     		}
     		}).show(); 
     }

    
	@Override
	public void onClick(View v) {		
		if((Integer)v.getTag() == OPTION_BACK) {
			onBackPressed();
		}
	}
	
	public <T> void toPage(Intent intent, Class<T> cls) {
		intent.setClass(this, cls); //PeopleDetailsActivity.class);
		startActivity(intent);
	    overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
	}
	
	public <T> void toLoginPage(Class<T> cls, String... params) {		
		Intent intent = new Intent(this, LoginActivity.class);
		intent.putExtra(ACTION_FROM, true);
		if (cls != null) {
			intent.putExtra(ACTION_TO, cls);
			if (params != null && params.length > 0) intent.putExtra(USER_TO, params[0]);
		}
	    startActivity(intent);
	    overridePendingTransition (R.anim.page_right_slide_in, R.anim.page_right_slide_out);
	}
	
	public void toast(String message) {
    	Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
	}

	public void updateIsPerson(ParseUser selfuser) {
		String user_email = selfuser.getEmail();
		ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
		personquery.whereEqualTo("email", user_email);
		personquery.getFirstInBackground(new GetCallback<ParseObject>() {
			@Override
			public void done(ParseObject parseObject, ParseException e) {
				if (parseObject != null) {
					//found a match, user is person: skip to user preference activity
					app = (cmenviApplication) getApplication();
					app.isPerson = true;
				} else {
					toPage(new Intent(), UserAttendeeActivity.class);
					return;
				}
			}
		});
	}

	public void toMainPage() {
		Intent intent = new Intent(this, MainActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(intent);
		overridePendingTransition(R.anim.page_left_slide_in, R.anim.page_left_slide_out);
	}
}
