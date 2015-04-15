package com.squint.app;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.squint.app.adapter.CareerAdapter;
import com.squint.app.data.CareerDAO;

import android.app.Fragment;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class CareerFragment extends Fragment {
	
	public static final String		TAG = CareerFragment.class.getSimpleName();
	public static Context			mContext;
	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;
	
	private CareerDAO 				mCareer;
	public static List<ParseObject> mData;
	public ListView 				mList;
	public static CareerAdapter		mAdapter;

    public EditText searchinput;
    public Button dosearch;
    public Button cancelsearch;
    
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		mCareer = new CareerDAO(mContext);
		mData	= new ArrayList<ParseObject>();
		
		View v = inflater.inflate(R.layout.fragment_general, container, false);
		mList = (ListView) v.findViewById(android.R.id.list);
		mList.setEmptyView(v.findViewById(android.R.id.empty));
		mAdapter = new CareerAdapter(mContext, mData);
		mList.setAdapter(mAdapter);

        searchinput = (EditText)v.findViewById(R.id.searchinput);
        dosearch = (Button)v.findViewById(R.id.dosearch);
        cancelsearch = (Button)v.findViewById(R.id.cancelsearch);
        searchinput.setVisibility(View.GONE);
        dosearch.setVisibility(View.GONE);
        cancelsearch.setVisibility(View.GONE);

        return v;	
        
	}
	
	public static CareerFragment newInstance(Context context) {
		mContext = context;
        return new CareerFragment();
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
        	filter.addAction(CareerAdapter.ACTION_CAREER_SELECT);
        	filter.addAction(CareerDAO.ACTION_LOAD_DATA);
        }  
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {  

        @Override  
        public void onReceive(Context context, Intent intent) {
        	Log.d(TAG, "onReceive");
        	String action = intent.getAction(); 	
            if (action.equals(CareerAdapter.ACTION_CAREER_SELECT)) {
            	//toast(intent.getStringExtra(CareerAdapter.EXTRA_CAREER_ID));
    			intent.setClass(mContext, CareerDetailsActivity.class);
    			startActivity(intent);
    		    getActivity().overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
            } else if (action.equals(CareerDAO.ACTION_LOAD_DATA)) {
            	mData = mCareer.getData();
            	mAdapter.update(mData);
            }
        }  
    }

	public void toast(String message) {
    	Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
	}	

}
