package com.squint.app.adapter;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.squint.app.R;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class CareerAdapter extends BaseAdapter {

	public static final String			TAG = CareerAdapter.class.getSimpleName();
	public static final String 			ACTION_CAREER_SELECT 		= "com.squint.action.career.select";
	public static final String 			EXTRA_CAREER_ID	  			= "com.squint.data.career.ID";
	public static final String 			EXTRA_CAREER_TITLE			= "com.squint.data.career.TITLE";
	public static final String 			EXTRA_CAREER_POSITION		= "com.squint.data.career.POSITION";
	public static final String 			EXTRA_CAREER_INSTITUTION	= "com.squint.data.career.INSTITUTION";
	public static final String 			EXTRA_CAREER_POSTEDBY		= "com.squint.data.career.POSTEDBY";
	public static final String 			EXTRA_CAREER_DESCRIPTION	= "com.squint.data.career.DESCRIPTION";
	public static final String 			EXTRA_CAREER_EMAIL			= "com.squint.data.career.EMAIL";
    public static final String 			EXTRA_CAREER_NAME			= "com.squint.data.career.NAME";
    public static final String 			EXTRA_CAREER_TIME			= "com.squint.data.career.TIME";
    public static final String 			EXTRA_CAREER_TYPE			= "com.squint.data.career.TYPE";
    public static final String 			EXTRA_CAREER_LINK			= "com.squint.data.career.LINK";
	
	
	private Context 					context;
	private final LayoutInflater 		inflater;
	private List<ParseObject>	 		data;

	private static class ViewHolder {
		  //public ImageView image;
		  public TextView position;
		  public TextView contact;
		  public TextView institution;
          public TextView ctype;
	}

	public CareerAdapter(Context context, List<ParseObject> data) {
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

	@SuppressLint("InflateParams")
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;		
		if (convertView == null) {
			convertView = inflater.inflate(R.layout.item_career, null);
			holder = new ViewHolder();
			holder.position = (TextView) convertView.findViewById(R.id.position);
			holder.institution = (TextView) convertView.findViewById(R.id.institution);
			holder.contact = (TextView) convertView.findViewById(R.id.author);
            holder.ctype = (TextView) convertView.findViewById(R.id.type);

		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.position.setText(getPosition(item));
		holder.institution.setText(getInstitution(item));
		holder.contact.setText(context.getString(R.string.post_by) + " " + getPostedBy(item));
        holder.ctype.setText(getTypeString(item));
		convertView.setTag(holder);
		holder.position.setTag(item);
		
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder)v.getTag();				
				ParseObject item = (ParseObject)h.position.getTag();			
				Intent intent = new Intent(ACTION_CAREER_SELECT);
				intent.putExtra(EXTRA_CAREER_ID, item.getObjectId());
				intent.putExtra(EXTRA_CAREER_INSTITUTION, getInstitution(item));
				intent.putExtra(EXTRA_CAREER_POSITION, getPosition(item));
				intent.putExtra(EXTRA_CAREER_DESCRIPTION, getDescription(item));
				intent.putExtra(EXTRA_CAREER_POSTEDBY, getPostedBy(item));
				intent.putExtra(EXTRA_CAREER_EMAIL, getEmail(item));
                intent.putExtra(EXTRA_CAREER_NAME, getContactname(item));
                intent.putExtra(EXTRA_CAREER_TIME, getDatetime(item));

                intent.putExtra(EXTRA_CAREER_TYPE, (int)getType(item));
                intent.putExtra(EXTRA_CAREER_LINK, getWeblink(item));

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

	private String getInstitution(ParseObject object) {
		return object.getString("institution");		
	}
	
	private String getPostedBy(ParseObject object) {
		ParseObject po = object.getParseObject("posted_by");
		return po.getString("first_name") + " " + po.getString("last_name");
	}
	
	private String getPosition(ParseObject object) {
		return object.getString("position");		
	}

    private String getDatetime(ParseObject object) {
        return object.getString("time_duration");
    }

    private String getContactname(ParseObject object) {
        return object.getString("contact_name");
    }

	private String getEmail(ParseObject object) {
        return object.getString("contact_email");
	}

    private String getWeblink(ParseObject object) {
        String weblink =  object.getString("link");
        if (weblink != null)
        {
            return weblink;
        }
        else
        {
            return  "";
        }
    }

    private int getType (ParseObject object) {
        int offerseek = object.getInt("offer_seek");
        return  offerseek;
    }

    private String getTypeString(ParseObject object) {
        int offerseek = object.getInt("offer_seek");
        if (offerseek == 1)
        {
            return "Seeking position:";
        }
        else
        {
            return  "Position available";
        }
    }

	private String getDescription(ParseObject object) {
		return object.getString("description");
	}
	
}
