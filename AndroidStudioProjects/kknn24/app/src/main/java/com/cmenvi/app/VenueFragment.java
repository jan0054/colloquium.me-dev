package com.cmenvi.app;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.cmenvi.app.adapter.VenueAdapter;
import com.cmenvi.app.data.VenueDAO;

import android.app.Fragment;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class VenueFragment extends Fragment {
	
	public static final String		TAG = VenueFragment.class.getSimpleName();
	public static Context			mContext;
	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;
	
	private VenueDAO 				mVenue;
	public static List<ParseObject> mData;
	public ListView 				mList;
	public static VenueAdapter		mAdapter;

    public EditText searchinput;
    public Button dosearch;
    public Button cancelsearch;
    
    
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		mVenue = new VenueDAO(mContext);
		mData	= new ArrayList<ParseObject>();
		
		View v = inflater.inflate(R.layout.fragment_general, container, false);
		mList = (ListView) v.findViewById(android.R.id.list);
		mList.setEmptyView(v.findViewById(android.R.id.empty));
		mAdapter = new VenueAdapter(mContext, mData);
		mList.setAdapter(mAdapter);

        searchinput = (EditText)v.findViewById(R.id.searchinput);
        dosearch = (Button)v.findViewById(R.id.dosearch);
        cancelsearch = (Button)v.findViewById(R.id.cancelsearch);
        searchinput.setVisibility(View.GONE);
        dosearch.setVisibility(View.GONE);
        cancelsearch.setVisibility(View.GONE);

        return v;	
        
	}
	
	public static VenueFragment newInstance(Context context) {
		mContext = context;
		VenueFragment fragment = new VenueFragment();
		/* if any argument
		Bundle args = new Bundle();
		args.putInt(ARG_SECTION_NUMBER, sectionNumber);
		fragment.setArguments(args);
		*/
        return fragment;
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
	
    private void getCall(String number) {
		Intent dial = new Intent();
	    dial.setAction(Intent.ACTION_CALL);
	    dial.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
	    dial.setData(Uri.parse("tel:" + number));
		startActivity(dial);
    }
    
    private void getSite(String url) {
          Intent ie = new Intent(Intent.ACTION_VIEW,Uri.parse(url));
          startActivity(ie);
    }
    
    private void getMap(double lat, double lng) {
		try {
			//String label = _PARAMS.COMPANY;
			String uriBegin = "geo:" + lat + "," + lng;
			//String query = _PARAMS.LATITUDE + "," + _PARAMS.LONGITUDE + "(" + label + ")";
			//String encodedQuery = Uri.encode(query);
			//String uriString = uriBegin + "?q=" + encodedQuery + "&z=16"; // if label required
			String uriString = uriBegin + "?q=" + "&z=16"; // if label required
			Uri mapUri = Uri.parse(uriString); // if label required
			
			//Uri mapUri = Uri.parse(uriBegin);
			Intent maps = new Intent(android.content.Intent.ACTION_VIEW, mapUri);
			startActivity(maps);
 		} catch (Exception e) {
			toast("The application of Google Maps is not found!");
		}
    } 
	
	private IntentFilter getIntentFilter() {  
        if (filter == null) {  
        	filter = new IntentFilter();  
        	filter.addAction(VenueAdapter.ACTION_VENUE_WEBSITE);
        	filter.addAction(VenueAdapter.ACTION_VENUE_CALL);
        	filter.addAction(VenueAdapter.ACTION_VENUE_NAVIGATE);
        	filter.addAction(VenueDAO.ACTION_LOAD_DATA);
        }  
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {  
		  
        @Override  
        public void onReceive(Context context, Intent intent) {
        	Log.d(TAG, "onReceive");
        	String action = intent.getAction(); 	
            if (action.equals(VenueAdapter.ACTION_VENUE_WEBSITE)) {
            	getSite(intent.getStringExtra(VenueAdapter.EXTRA_VENUE_URL));
            	
            } else if (action.equals(VenueAdapter.ACTION_VENUE_CALL)) {
            	getCall(intent.getStringExtra(VenueAdapter.EXTRA_VENUE_PHONE));
            	
            } else if (action.equals(VenueAdapter.ACTION_VENUE_NAVIGATE)) {
            	double lat = intent.getDoubleExtra(VenueAdapter.EXTRA_VENUE_LAT, 0);
            	double lng = intent.getDoubleExtra(VenueAdapter.EXTRA_VENUE_LNG, 0);
            	if (lat != 0 && lng != 0) getMap(lat, lng);

            } else if (action.equals(VenueDAO.ACTION_LOAD_DATA)) {
            	mData = mVenue.getData();
            	mAdapter.update(mData);
            }
        }  
    }

	public void toast(String message) {
    	Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
	}	

}
