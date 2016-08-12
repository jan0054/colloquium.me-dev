package com.ashvale.littlebooklet.data;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;

public class _PREFS {
	private Context context;
    private SharedPreferences pref;
    

    
    public static final String PREFS	 		= "PREFS_temp";
    public static final String REG_EMAIL	 	= "X_EMAIL";
    public static final String REG_OBJID		= "X_OBJID";
    public static final String REG_ID			= "X_ID";			// For notification
    public static final String REG_VERSION		= "X_VERSION";		// Fixed value when initialized
    


    // Preference Keys - Boolean
    public static final String LOGIN			= "PREF_LOGIN";
    public static final String NOTIFICATION		= "PREF_NOTIFICATION";
    public static final String ABOUT			= "PREF_ABOUT";
    public static final String FEEDBACK			= "PREF_FEEDBACK";
    public static final String TERMS			= "PREF_TERMS";
    public static final String TECH			    = "PREF_TECH";
    public static final String ADMIN			= "PREF_ADMIN";
    public static final String USER             = "PREF_USER";

	public _PREFS(Context context) {
		this.context = context;
		this.pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
		if (!pref.contains(REG_VERSION)) initPreference();
	}
	
	public void clear() {
		pref.edit().clear().commit();
	}
	
	public void initPreference() {		
		setString(REG_VERSION, getVersion());
		pref.edit().putBoolean(NOTIFICATION, false).commit();
	}
	
	
	public void setRegisterData(String email, String objId, String regId) {
		//Random r = new Random();
		//String auto_captcha = String.format("%04d", r.nextInt(10000));
		
		Editor editor = pref.edit();
		editor.putString(REG_EMAIL, email);
		editor.putString(REG_OBJID, objId);
		editor.putString(REG_ID, regId);
		editor.commit();
	}
	
	public String getEmail() {
		return pref.getString(REG_EMAIL, "");
	}
	
	public String getVersion() {
		String version = "";
		try {
			PackageInfo info;
			info = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			version  = info.versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return version;
	}
	
	public String getString(String key) {
		return pref.getString(key, "");
	}
		
	public void setString(String key, String value) {
		pref.edit().putString(key, (value != null) ? value : "").commit();
	}
	
	
	public boolean isLoggedIn() {
		return pref.getBoolean(LOGIN, false);
	}
	
	public boolean isNotificated() {
		return pref.getBoolean(NOTIFICATION, false);
	}
	
	public void setNotification(boolean isNotificated) {
		pref.edit().putBoolean(NOTIFICATION, isNotificated);
	}
	
	public void setRegistrationId(String regId) {
		pref.edit().putString(REG_ID, regId).commit();		
	}
	
	
	public String getRegistrationId() {
		return pref.getString(REG_ID, "");
	}

	
	@Override
	public String toString() {
		return "REG_ID: "			+ getString(REG_ID) + ", " +
			   "REG_EMAIL: "		+ getString(REG_EMAIL) + ", " +
			   "REG_OBJID: "		+ getString(REG_OBJID) + ", " +
			   "REG_VERSION: "		+ getString(REG_VERSION) + ", " +
			   "Register ID: "	+ isLoggedIn() + ", " +
			   "Notification: "	+ isNotificated()
			   ;
	}

}
