package com.cmmath.app.adapter;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.cmmath.app.R;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class PeopleAdapter extends BaseAdapter {

	public static final String			TAG = PeopleAdapter.class.getSimpleName();
	public static final String 			ACTION_PERSON_SELECT 		= "com.squint.action.person.select";
	public static final String 			EXTRA_PERSON_ID	  			= "com.squint.data.person.ID";
	public static final String 			EXTRA_PERSON_NAME			= "com.squint.data.person.NAME";
	public static final String 			EXTRA_PERSON_INSTITUTION	= "com.squint.data.person.INSTITUTION";
	public static final String 			EXTRA_PERSON_EMAIL			= "com.squint.data.person.EMAIL";
	public static final String 			EXTRA_PERSON_LINK			= "com.squint.data.person.LINK";
    public static final String 			EXTRA_PERSON_CHATSTATUS	    = "com.squint.data.person.CHATSTATUS";
    public static final String 			EXTRA_PERSON_EMAILSTATUS	= "com.squint.data.person.EMAILSTATUS";
    public static final String 			EXTRA_PERSON_ISUSER		    = "com.squint.data.person.ISUSER";
	
	private Context 					context;
	private final LayoutInflater 		inflater;
	private List<ParseObject>	 		data;

	private static class ViewHolder {
		  public TextView name;
		  public TextView institution;
	}

	public PeopleAdapter(Context context, List<ParseObject> data) {
		this.context = context;
		inflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.data = data;
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
			convertView = inflater.inflate(R.layout.item_people, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);
			holder.institution = (TextView) convertView.findViewById(R.id.institution);
		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		holder.institution.setText(getInstitution(item));
		convertView.setTag(holder);
		holder.name.setTag(item);
		
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder)v.getTag();
				ParseObject item = (ParseObject)h.name.getTag();			
				Intent intent = new Intent(ACTION_PERSON_SELECT);
				intent.putExtra(EXTRA_PERSON_ID, item.getObjectId());
				intent.putExtra(EXTRA_PERSON_NAME, getName(item));
				intent.putExtra(EXTRA_PERSON_INSTITUTION, getInstitution(item));
				intent.putExtra(EXTRA_PERSON_EMAIL, getEmail(item));
				intent.putExtra(EXTRA_PERSON_LINK, getWebsite(item));
                intent.putExtra(EXTRA_PERSON_CHATSTATUS, getChat_status(item));
                intent.putExtra(EXTRA_PERSON_EMAILSTATUS, getEmail_status(item));
                intent.putExtra(EXTRA_PERSON_ISUSER, getIs_user(item));
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
		Log.d(TAG, "Update: " + data.size());
	}

	private String getInstitution(ParseObject object) {
		return object.getString("institution");		
	}
	
	private String getName(ParseObject object) {
		return object.getString("last_name") + ", " + object.getString("first_name");
	}
	
	private String getEmail(ParseObject object) {
		return object.getString("email");		
	}
	
	private String getWebsite(ParseObject object) {
		return object.getString("link");		
	}

    private int getChat_status(ParseObject object) {
        return object.getInt("chat_status");
    }

    private int getEmail_status(ParseObject object) {
        return object.getInt("email_status");
    }

    private int getIs_user(ParseObject object) { return object.getInt("is_user");}
}
