package com.cmmath.app;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.parse.ParseObject;
import com.cmmath.app.adapter.AttachmentAdapter;
import com.cmmath.app.adapter.PosterAdapter;
import com.cmmath.app.adapter.TalkAdapter;
import com.cmmath.app.data.AbstractDAO;
import com.cmmath.app.data.PosterDAO;
import com.cmmath.app.data.TalkDAO;

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
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class ProgramFragment extends Fragment implements OnClickListener {
	
	public static final String		TAG = ProgramFragment.class.getSimpleName();
	public static Context			mContext;
	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;
	
	private TalkDAO 				mTalkDAO;
	private PosterDAO 				mPosterDAO;
	private AbstractDAO 			mAttachmentDAO;
	public static List<ParseObject> mTalkData;
	public static List<ParseObject> mPosterData;
	public static List<ParseObject> mAttachmentData;
	
	public static TalkAdapter		mTalkAdapter;
	public static PosterAdapter		mPosterAdapter;
	public static AttachmentAdapter	mAttachmentAdapter;

	public ListView 				mList;
	private Button mTalk;
	private Button mPoster;
	private Button mAttachment;

    //search and day filter stuff
    public int selected_seg;
    public EditText searchinput;
    public Button dosearch;
    public Button cancelsearch;
    public int talkday;
    public ArrayList<String> searcharray;
    
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        //Bundle args = getArguments();
        //talkday = args.getInt("day", 0);
        selected_seg = 0;
        talkday = 0;
        searcharray = new ArrayList<String>();
		mTalkDAO = new TalkDAO(mContext, searcharray, talkday);
		mPosterDAO = new PosterDAO(mContext, searcharray);
		mAttachmentDAO = new AbstractDAO(mContext);
		mTalkData	= new ArrayList<ParseObject>();
		mPosterData	= new ArrayList<ParseObject>();	
		mAttachmentData = new ArrayList<ParseObject>();
		View v = inflater.inflate(R.layout.fragment_program, container, false);
		mTalk = (Button)v.findViewById(R.id.switch_talk);
		mPoster = (Button)v.findViewById(R.id.switch_poster);
		mAttachment = (Button)v.findViewById(R.id.switch_attachment);
		mTalk.setOnClickListener(this);
		mPoster.setOnClickListener(this);
		mAttachment.setOnClickListener(this);

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
                    switch (selected_seg)
                    {
                        case 0:
                            mTalkDAO = new TalkDAO(mContext, searcharray, talkday);
                            mList.setAdapter(mTalkAdapter);
                            break;
                        case 1:
                            mPosterDAO = new PosterDAO(mContext, searcharray);
                            mList.setAdapter(mPosterAdapter);
                            break;
                    }
                }
            }
        });
		
		mList = (ListView) v.findViewById(android.R.id.list);
		mList.setEmptyView(v.findViewById(android.R.id.empty));
		mTalkAdapter = new TalkAdapter(mContext, mTalkData);
		mPosterAdapter = new PosterAdapter(mContext, mPosterData);
		mAttachmentAdapter = new AttachmentAdapter(mContext, mAttachmentData);
		onClick(mTalk);
		
        return v;	
        
	}



	public static ProgramFragment newInstance(Context context) {
		mContext = context;
        return new ProgramFragment();
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
        	filter.addAction(TalkDetailsActivity.ACTION_SELECT);
        	filter.addAction(PosterDetailsActivity.ACTION_SELECT);
        	filter.addAction(AttachmentDetailsActivity.ACTION_SELECT);
        	filter.addAction(TalkDAO.ACTION_LOAD_DATA);
        	filter.addAction(PosterDAO.ACTION_LOAD_DATA);
        	filter.addAction(AbstractDAO.ACTION_LOAD_DATA);
        }  
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {  
		  
        @Override  
        public void onReceive(Context context, Intent intent) {
        	Log.d(TAG, "onReceive");
        	String action = intent.getAction();
        	
            if (action.equals(TalkDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, TalkDetailsActivity.class);
            	
            } else if (action.equals(PosterDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, PosterDetailsActivity.class);
            	
            } else if (action.equals(AttachmentDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, AttachmentDetailsActivity.class);
            	//toast(intent.getStringExtra(AbstractAdapter.EXTRA_ABSTRACT_ID));
            	
            } else if (action.equals(TalkDAO.ACTION_LOAD_DATA)) {
            	try {
            		mTalkData = mTalkDAO.getData();
            		mTalkAdapter.update(mTalkData);
            	} catch (Exception e) { Log.d(TAG, "Talk data is null!"); }
            } else if (action.equals(PosterDAO.ACTION_LOAD_DATA)) {
            	try {
            	mPosterData = mPosterDAO.getData();
            	mPosterAdapter.update(mPosterData);
            	} catch (Exception e) { Log.d(TAG, "Poster data is null!"); }
            } else if (action.equals(AbstractDAO.ACTION_LOAD_DATA)) {
            	try {
            		mAttachmentData = mAttachmentDAO.getData();
            		mAttachmentAdapter.update(mAttachmentData);
            	} catch (Exception e) { Log.d(TAG, "Abstract data is null!"); }
            	
            }         
        }  
    }
	
	private <T> void toPage(Intent intent, Class<T> cls) {
		intent.setClass(mContext, cls);
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

    public void refreshDay(int day)
    {
        Log.d(TAG, "Day refreshed");
        talkday = day;
        mTalkDAO = new TalkDAO(mContext, searcharray, talkday);
        //mList.setAdapter(mTalkAdapter);
    }

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.switch_talk:
			mList.setAdapter(mTalkAdapter);
			mTalk.setSelected(true);
			mPoster.setSelected(false);
			mAttachment.setSelected(false);
			mTalk.setEnabled(false);
			mPoster.setEnabled(true);
			mAttachment.setEnabled(true);
            selected_seg = 0;
            searchinput.setText("");
            searcharray.clear();
			//toast("Talk");
			break;
		case R.id.switch_poster:
			mList.setAdapter(mPosterAdapter);
			mTalk.setSelected(false);
			mPoster.setSelected(true);
			mAttachment.setSelected(false);
			mTalk.setEnabled(true);
			mPoster.setEnabled(false);
			mAttachment.setEnabled(true);
            selected_seg = 1;
            searchinput.setText("");
            searcharray.clear();
			//toast("Poster");
			break;
		case R.id.switch_attachment:
			mList.setAdapter(mAttachmentAdapter);
			mTalk.setSelected(false);
			mPoster.setSelected(false);
			mAttachment.setSelected(true);
			mTalk.setEnabled(true);
			mPoster.setEnabled(true);
			mAttachment.setEnabled(false);
            selected_seg = 2;
            searchinput.setText("");
            searcharray.clear();
			//toast("Abstract");
			break;
        case R.id.cancelsearch:
            //cancel search button
            Log.d(TAG, "Cancel search");
            searchinput.setText("");
            searcharray.clear();
            switch (selected_seg)
            {
                case 0:
                    mTalkDAO = new TalkDAO(mContext, searcharray, talkday);
                    mList.setAdapter(mTalkAdapter);
                    break;
                case 1:
                    mPosterDAO = new PosterDAO(mContext, searcharray);
                    mList.setAdapter(mPosterAdapter);
                    break;
            }
            break;
        case R.id.dosearch:
            //do search button
            Log.d(TAG, "Do search");
            switch (selected_seg)
            {
                case 0:
                    setSearchString();
                    mTalkDAO = new TalkDAO(mContext, searcharray, talkday);
                    mList.setAdapter(mTalkAdapter);
                    break;
                case 1:
                    setSearchString();
                    mPosterDAO = new PosterDAO(mContext, searcharray);
                    mList.setAdapter(mPosterAdapter);
                    break;
            }
            break;
		}
	}	
}
