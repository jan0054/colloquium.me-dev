package com.squint.app;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.parse.ParseObject;
import com.squint.app.adapter.PeopleAdapter;
import com.squint.app.data.PeopleDAO;
import com.squint.app.data.PosterDAO;
import com.squint.app.data.TalkDAO;

import android.app.Fragment;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class PeopleFragment extends Fragment implements View.OnClickListener {
	
	public static final String		TAG = PeopleFragment.class.getSimpleName();
	public static Context			mContext;
	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;
    
	private PeopleDAO 				mPeople;
	public List<ParseObject> 		mData;
	public ListView 				mList;
	public static PeopleAdapter		mAdapter;

    //search stuff
    public EditText searchinput;
    public Button dosearch;
    public Button cancelsearch;
    public ArrayList<String> searcharray;
    
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		mPeople = new PeopleDAO(mContext, searcharray);
		mData	= new ArrayList<ParseObject>();
        searcharray = new ArrayList<String>();


		
		View v = inflater.inflate(R.layout.fragment_general, container, false);
		mList = (ListView) v.findViewById(android.R.id.list);
		mList.setEmptyView(v.findViewById(android.R.id.empty));

        searchinput = (EditText)v.findViewById(R.id.searchinput);
        dosearch = (Button)v.findViewById(R.id.dosearch);
        cancelsearch = (Button)v.findViewById(R.id.cancelsearch);
        dosearch.setOnClickListener(this);
        cancelsearch.setOnClickListener(this);
        searchinput.addTextChangedListener(new TextWatcher() {
            @Override
            public void afterTextChanged(Editable s) {}

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start,
                                      int before, int count) {
                if(s.length() == 0)
                {
                    Log.d(TAG, "Backspaced to empty");
                    searcharray.clear();
                    mPeople = new PeopleDAO(mContext, searcharray);
                    mList.setAdapter(mAdapter);
                }
            }
        });

		mAdapter = new PeopleAdapter(mContext, mData);
		mList.setAdapter(mAdapter);	
        return v;	
        
	}
	
	public static PeopleFragment newInstance(Context context) {
		mContext = context;
        return new PeopleFragment();
    }
	
	
	@Override  
    public void onResume() {
        super.onResume();
        if (receiver == null) receiver = new IntentReceiver();  
        mContext.registerReceiver(receiver, getIntentFilter());
    }
	
	@Override  
    public void onPause() {  
        super.onPause();  
        mContext.unregisterReceiver(receiver);
    }
	
	private IntentFilter getIntentFilter() {  
        if (filter == null) {  
        	filter = new IntentFilter();  
        	filter.addAction(PeopleAdapter.ACTION_PERSON_SELECT);
        	filter.addAction(PeopleDAO.ACTION_LOAD_DATA);
        }  
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {  
		  
        @Override  
        public void onReceive(Context context, Intent intent) {
        	Log.d(TAG, "onReceive");
        	String action = intent.getAction(); 	
            if (action.equals(PeopleAdapter.ACTION_PERSON_SELECT)) {
            	//toast(intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_ID));
            	toPage(intent, PeopleDetailsActivity.class);
            } else if (action.equals(PeopleDAO.ACTION_LOAD_DATA)) {
            	mData = mPeople.getData();
            	mAdapter.update(mData);
            	//toast(intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_ID));
            }
        }  
    }
	
	private <T> void toPage(Intent intent, Class<T> cls) {
		intent.setClass(mContext, cls); //PeopleDetailsActivity.class);
		startActivity(intent);
	    getActivity().overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
	}

	public void toast(String message) {
    	Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
	}

    public void setSearchString()
    {
        String raw_input = searchinput.getText().toString();
        String lower_raw = raw_input.toLowerCase();
        String [] split_string = lower_raw.split("\\s+");
        searcharray = new ArrayList<String>(Arrays.asList(split_string));
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.cancelsearch:
                //cancel search button
                Log.d(TAG, "Cancel search");
                searchinput.setText("");
                searcharray.clear();
                mPeople = new PeopleDAO(mContext, searcharray);
                mList.setAdapter(mAdapter);
                break;
            case R.id.dosearch:
                //do search button
                setSearchString();
                Log.d(TAG, "Do search");
                mPeople = new PeopleDAO(mContext, searcharray);
                mList.setAdapter(mAdapter);
                break;
        }
    }

}
