package com.squint.app.adapter;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.squint.app.R;
import com.squint.app.widget.BitmapManager;

import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class VenueAdapter extends BaseAdapter {

	public static final String			TAG = VenueAdapter.class.getSimpleName();
	public static final String 			ACTION_VENUE_SELECT 		= "com.squint.action.venue.select";
	public static final String 			EXTRA_VENUE_ID	  			= "com.squint.data.venue.ID";

	public static final String 			ACTION_VENUE_WEBSITE 		= "com.squint.action.venue.website";
	public static final String 			EXTRA_VENUE_URL	  			= "com.squint.data.venue.URL";

	public static final String 			ACTION_VENUE_CALL 			= "com.squint.action.venue.call";
	public static final String 			EXTRA_VENUE_PHONE	  		= "com.squint.data.venue.PHONE";


	
	public static final String 			ACTION_VENUE_NAVIGATE 		= "com.squint.action.venue.navigate";
	public static final String 			EXTRA_VENUE_LAT	  			= "com.squint.data.venue.LATITUDE";
	public static final String 			EXTRA_VENUE_LNG				= "com.squint.data.venue.LONGITUDE";

	
	private Context 					context;
	private final LayoutInflater 		inflater;
	private List<ParseObject>	 		data;

	private static class ViewHolder {
		  public ImageView photo;
		  public TextView name;
		  public TextView description;
		  public TextView address;
		  public ImageView website;
		  public ImageView navigate;
		  public ImageView call;
	}

	public VenueAdapter(Context context, List<ParseObject> data) {
		this.context = context;
		inflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.data = data;
		BitmapManager.INSTANCE.setPlaceholder(BitmapFactory.decodeResource(context.getResources(), R.drawable.bg_transp));

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
			convertView = inflater.inflate(R.layout.item_venue, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);
			holder.description = (TextView) convertView.findViewById(R.id.description);
			holder.address = (TextView) convertView.findViewById(R.id.address);
			holder.photo = (ImageView) convertView.findViewById(R.id.photo);
			holder.website = (ImageView) convertView.findViewById(R.id.website);
			holder.call = (ImageView) convertView.findViewById(R.id.call);
			holder.navigate = (ImageView) convertView.findViewById(R.id.navigate);			
			convertView.setTag(holder);			
		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		holder.description.setText(getDescription(item));
        holder.description.setMovementMethod(new ScrollingMovementMethod());
		holder.address.setText(getAddress(item));
		
		holder.website.setTag(getUrl(item));
		holder.navigate.setTag(getGeoPoint(item));
		holder.call.setTag(getCall(item));
		convertView.setTag(holder);
		
		holder.website.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent(ACTION_VENUE_WEBSITE);
				intent.putExtra(EXTRA_VENUE_URL, v.getTag().toString());
				context.sendBroadcast(intent);					
			}
			
		});
		
		holder.call.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {			    
				Intent intent = new Intent(ACTION_VENUE_CALL);
				intent.putExtra(EXTRA_VENUE_PHONE, v.getTag().toString());
				context.sendBroadcast(intent);					
			}
			
		});
		
		holder.navigate.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent(ACTION_VENUE_NAVIGATE);
				intent.putExtra(EXTRA_VENUE_LAT, ((ParseGeoPoint)v.getTag()).getLatitude());
				intent.putExtra(EXTRA_VENUE_LNG, ((ParseGeoPoint)v.getTag()).getLongitude());
				context.sendBroadcast(intent);					
			}
			
		});
		
		/*
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ParseObject item = (ParseObject)v.getTag();			
				Intent intent = new Intent(ACTION_VENUE_SELECT);
				intent.putExtra(EXTRA_VENUE_ID, item.getObjectId());
				context.sendBroadcast(intent);						
			}
		});
		*/
		
		BitmapManager.INSTANCE.loadBitmap(getPhotoUrl(item), holder.photo, 0, 0);
		
		return convertView;
	}
	
	public void update(List<ParseObject> feeds) {
		if (data == null) data = new ArrayList<ParseObject>();
		else data.clear();
	    data.addAll(feeds);
	    this.notifyDataSetChanged();
		Log.d(TAG, "Update: " + feeds.size());
	}

	private String getName(ParseObject object) {
		return object.getString("name");		
	}
	
	private String getDescription(ParseObject object) {
		return object.getString("description");
	}
	
	private String getAddress(ParseObject object) {
		return object.getString("address");		
	}
	
	private String getPhotoUrl(ParseObject object) {
		return object.getParseFile("photo").getUrl();		
	}
	
	private String getUrl(ParseObject object) {
		Log.d(TAG, "URL: " + object.getString("url"));
		return object.getString("url");		
	}
	
	private String getCall(ParseObject object) {
		return object.getString("phone");		
	}
	
	private ParseGeoPoint getGeoPoint(ParseObject object) {	
		return object.getParseGeoPoint("coord");		
	}
	
	/*
	private double getLatitude(ParseObject object) {	
		return object.getParseGeoPoint("coord").getLatitude();		
	}
	
	private double getLongitude(ParseObject object) {	
		return object.getParseGeoPoint("coord").getLongitude();		
	}
	*/
	
}
