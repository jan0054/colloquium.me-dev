package com.cmenvi.app.adapter;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.parse.ParseObject;
import com.cmenvi.app.R;
import com.cmenvi.app.TalkDetailsActivity;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class PersonalTalkAdapter extends BaseAdapter {

	public static final String		TAG = PersonalTalkAdapter.class.getSimpleName();	
	
	private Context 				context;
	private final LayoutInflater 	inflater;
	private SimpleDateFormat 		sdf;
	private List<ParseObject>	 	data;

	private static class ViewHolder {
		  public TextView name;
	}

	public PersonalTalkAdapter(Context context, List<ParseObject> data) {
		this.context = context;
		inflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.data = data;
		sdf = new SimpleDateFormat("MM-dd hh:mm a", Locale.getDefault());
		Log.d(TAG, "FEED SIZE: " + Integer.toString(data.size()));
	}

	@Override
	public int getCount() {
		return data.size();
	}
	
	@Override
	public ParseObject getItem(int position) {
		return data.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;		
		if (convertView == null) {
			convertView = inflater.inflate(R.layout.item_program_personal, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);
		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		holder.name.setTag(item);
		convertView.setTag(holder);
		
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder)v.getTag();				
				ParseObject item = (ParseObject)h.name.getTag();			
				Intent intent = new Intent(TalkDetailsActivity.ACTION_SELECT);
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ID, item.getObjectId());
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_NAME, getName(item));
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_AUTHOR, getAuthor(item));
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_START_TIME, getStartTime(item));
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_CONTENT, getDescription(item));
				intent.putExtra(TalkDetailsActivity.EXTRA_TALK_LOCATION_NAME, getLocationName(item));

                if (getAbstractExist(item))
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_ID, getAbstractId(item));
                }
                else
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_ID, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_CONTENT, getAbstractContent(item));
                }
                else
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_CONTENT, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_PDF, getAbstractPdf(item));
                }
                else
                {
                    intent.putExtra(TalkDetailsActivity.EXTRA_TALK_ATTACHMENT_PDF, "");
                }
				context.sendBroadcast(intent);						
			}
		});
		
		return convertView;
	}
	
	public void update(List<ParseObject> feeds) {
		if (data == null) data = new ArrayList<ParseObject>();
		else data.clear();
	    data.addAll(feeds);
	    notifyDataSetChanged();
		Log.d(TAG, "Update: " + feeds.size());
	}
	
	
	private String getName(ParseObject object) {
		return object.getString("name");		
	}
	
	private String getAuthor(ParseObject object) {
		ParseObject author = object.getParseObject("author");
		return (author == null) ? context.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
	}
	
	private String getDescription(ParseObject object) {
		return object.getString("content");
	}
	
	private String getLocationName(ParseObject object) {
		return object.getParseObject("location").getString("name");		
	}
	
	private String getStartTime(ParseObject object) {
		return sdf.format(object.getDate("start_time"));		
	}

    private boolean getAbstractExist (ParseObject object)
    {
        return object.containsKey("attachment");
    }

    private String getAbstractId(ParseObject object) {
        String result = object.getParseObject("attachment").getObjectId();
        if (result.length()>=1)
        {
            return result;
        }
        else
        {
            return "";
        }
    }

    private String getAbstractPdf(ParseObject object) {
        String result =  object.getParseObject("attachment").getParseFile("pdf").getUrl();
        if (result.length()>=1)
        {
            return result;
        }
        else
        {
            return "";
        }
    }

    private String getAbstractContent(ParseObject object) {
        String result =  object.getParseObject("attachment").getString("content");
        if (result.length()>=1)
        {
            return result;
        }
        else
        {
            return "";
        }
    }
	
}
