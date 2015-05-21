package com.cmmath.app;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import com.cmmath.app.data._PARAMS;
import com.cmmath.app.data._PREFS;
import com.cmmath.app.widget.TogglePreference;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceClickListener;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;


public class SettingsFragment extends PreferenceFragment
	 							  implements OnSharedPreferenceChangeListener {
	
		private static final String TAG = SettingsFragment.class.getSimpleName();
	
		private Activity 			mActivity;
		private static Context 		mContext;
		private SharedPreferences 	prefs;
		private ListView 			lv;
		public static final String SETTINGS_ABOUT = "com.squint.app.settings.about";
		public static final String SETTINGS_TERMS = "com.squint.app.settings.terms";
		public static final String SETTINGS_FEEDBACK = "com.squint.app.settings.feedback";
        public static final String SETTINGS_TECH = "com.squint.app.settings.tech";
        public static final String SETTINGS_ADMIN = "com.squint.app.settings.admin";
		
		@Override
		public void onCreate(Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);
			mActivity = getActivity();
			mContext = mActivity.getBaseContext();
			
			PreferenceManager prefMgr = getPreferenceManager(); 
			prefMgr.setSharedPreferencesName(_PREFS.PREFS);
			prefMgr.setSharedPreferencesMode(Context.MODE_PRIVATE);
			addPreferencesFromResource(R.xml.preferences);
			prefs = getPreferenceScreen().getSharedPreferences();
		    //prefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
			Log.d(TAG, prefs.toString());
		    initContent();		
		}
		
		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
		Bundle savedInstanceState) {

		View v = super.onCreateView(inflater, container, savedInstanceState);
		if(v != null) {
		v.setBackgroundColor(getResources().getColor(R.color.dark_bg));
		lv = (ListView) v.findViewById(android.R.id.list);
		lv.setPadding(0, 0, 0, 0);
		lv.setDivider(new ColorDrawable(mContext.getResources().getColor(R.color.light_bg)));
		lv.setDividerHeight(1);
		}
		
		return v;
		}
		
		private void initContent() {
			
			final String[] titles = getResources().getStringArray(R.array.detail_title);
			final String[] subjects = getResources().getStringArray(R.array.detail_subject);
			final String[] actions = getResources().getStringArray(R.array.detail_action);
			
			Preference about = (Preference) findPreference(_PREFS.ABOUT);
			about.setOnPreferenceClickListener(new OnPreferenceClickListener() {
				@Override
				public boolean onPreferenceClick(Preference preference) {
					Log.d(TAG, preference.getKey());
					Intent intent = new Intent(mContext, SettingsDetailsActivity.class);
					intent.putExtra(SettingsDetailsActivity.TITLE, titles[0]);
					intent.putExtra(SettingsDetailsActivity.SUBJECT, subjects[0]);
					intent.putExtra(SettingsDetailsActivity.CONTENT, getContent(R.raw.about));
					intent.putExtra(SettingsDetailsActivity.ACTION, actions[0]);
				    startActivity(intent);
				    getActivity().overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);					
					return false;
				}
			});
			
			Preference terms = (Preference) findPreference(_PREFS.TERMS);
			terms.setOnPreferenceClickListener(new OnPreferenceClickListener(){
				@Override
				public boolean onPreferenceClick(Preference preference) {
					Log.d(TAG, preference.getKey());
					Intent intent = new Intent(mContext, SettingsDetailsActivity.class);
					intent.putExtra(SettingsDetailsActivity.TITLE, titles[1]);
					intent.putExtra(SettingsDetailsActivity.SUBJECT, subjects[1]);
					intent.putExtra(SettingsDetailsActivity.CONTENT, getContent(R.raw.terms));
					intent.putExtra(SettingsDetailsActivity.ACTION, actions[1]);
					startActivity(intent);	
				    getActivity().overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);					
					return false;
				}
			});	
			
			Preference feedback = (Preference) findPreference(_PREFS.FEEDBACK);
			feedback.setOnPreferenceClickListener(new OnPreferenceClickListener(){
				@Override
				public boolean onPreferenceClick(Preference preference) {
					Log.d(TAG, preference.getKey());
					try {
						sendEmail(_PARAMS.FEEDBACK_TITLE, _PARAMS.FEEDBACK_CONTENT, new String[]{_PARAMS.FEEDBACK_EMAIL}, null);
					} catch (Exception e){
						e.getStackTrace();
					}
					
					return false;
				}
			});

            Preference tech = (Preference) findPreference(_PREFS.TECH);
            tech.setOnPreferenceClickListener(new OnPreferenceClickListener(){
                @Override
                public boolean onPreferenceClick(Preference preference) {
                    Log.d(TAG, preference.getKey());
                    try {
                        sendEmail(_PARAMS.TECH_TITLE, _PARAMS.TECH_CONTENT, new String[]{_PARAMS.TECH_EMAIL}, null);
                    } catch (Exception e){
                        e.getStackTrace();
                    }

                    return false;
                }
            });

            Preference admin = (Preference) findPreference(_PREFS.ADMIN);
            admin.setOnPreferenceClickListener(new OnPreferenceClickListener(){
                @Override
                public boolean onPreferenceClick(Preference preference) {
                    Log.d(TAG, preference.getKey());
                    try {
                        sendEmail(_PARAMS.ADMIN_TITLE, _PARAMS.ADMIN_CONTENT, new String[]{_PARAMS.ADMIN_EMAIL}, null);
                    } catch (Exception e){
                        e.getStackTrace();
                    }

                    return false;
                }
            });

		}	
		
		@Override
		public void onResume() {
			super.onResume();
			prefs.registerOnSharedPreferenceChangeListener(this);      
		}	
		
		@Override
		public void onPause() {
			super.onPause();
			prefs.unregisterOnSharedPreferenceChangeListener(this);		
		}	
		
		@Override
		public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
			Preference pref = findPreference(key);
			if (pref instanceof TogglePreference) {
				TogglePreference p = (TogglePreference) pref;
				Log.d(TAG, key + "/" + p.isChecked());
			}
		}
		
		public static SettingsFragment newInstance(Context context) {
			mContext = context;
			SettingsFragment fragment = new SettingsFragment();
			/* if any argument
			Bundle args = new Bundle();
			args.putInt(ARG_SECTION_NUMBER, sectionNumber);
			fragment.setArguments(args);
			*/
	        return fragment;
	    }
		
		public String getContent(int resourceId) {
			String result = "";
		    try {
		        InputStream in = getResources().openRawResource(resourceId);
		        byte[] b = new byte[in.available()];
		        in.read(b);
		        result = new String(b);
		    } catch (Exception e) {
		        result = "Error: can't show file.";
		    }
		    return result;
		}
		
		private void sendEmail(String title, String content, String[] emails, Uri imageUri) throws IOException {
			
		    Intent emailIntent = new Intent();
		    emailIntent.setAction(Intent.ACTION_SEND);
	    	emailIntent.setType("application/image");
		    if (imageUri != null) {
		    	emailIntent.putExtra(Intent.EXTRA_STREAM, imageUri);	   
		    }
		    Intent openInChooser = Intent.createChooser(emailIntent, "Share");
		    
		    // Extract all package labels
		    PackageManager pm = mContext.getPackageManager();
		    
		    Intent sendIntent = new Intent(Intent.ACTION_SEND);     
		    sendIntent.setType("text/plain");
		    
		    List<ResolveInfo> resInfo = pm.queryIntentActivities(sendIntent, 0);
		    List<LabeledIntent> intentList = new ArrayList<LabeledIntent>();
		    
		    for (int i = 0; i < resInfo.size(); i++) {
		        ResolveInfo ri = resInfo.get(i);
		        String packageName = ri.activityInfo.packageName;		        
		        Log.d(TAG, "package: " + packageName);
		        // Append and repackage the packages we want into a LabeledIntent
		        if(packageName.contains("android.email")) {
		            emailIntent.setPackage(packageName);
		        } else if (packageName.contains("android.gm")) 	{		
		            Intent intent = new Intent();
		            intent.setComponent(new ComponentName(packageName, ri.activityInfo.name));
		            intent.setAction(Intent.ACTION_SEND);
		            intent.setType("text/plain");
		            intent.putExtra(Intent.EXTRA_EMAIL,  emails);
					intent.putExtra(Intent.EXTRA_SUBJECT, title);
					intent.putExtra(Intent.EXTRA_TEXT, content);
					if (imageUri != null) {
						intent.setType("message/rfc822");
						intent.putExtra(Intent.EXTRA_STREAM, imageUri);	
					}
		            intentList.add(new LabeledIntent(intent, packageName, ri.loadLabel(pm), ri.icon));
		        }
		    }
		    // convert intentList to array
		    LabeledIntent[] extraIntents = intentList.toArray( new LabeledIntent[ intentList.size() ]);

		    openInChooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents);
		    startActivity(openInChooser);
		    
		}

}	
