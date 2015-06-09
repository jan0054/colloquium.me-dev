package com.cmenvi.app;

import com.cmenvi.app.widget.BaseActivity;
import android.os.Bundle;

public class MessageActivity extends BaseActivity {
	
	public static final String TAG = MessageActivity.class.getSimpleName();



	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_conversation);		
		mTitle.setText(getString(R.string.title_conversation));		
		configOptions(OPTION_BACK, OPTION_NONE);
	}
	
	@Override
	public void onResume() {		
		super.onResume();
	}

	
}
