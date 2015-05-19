package com.squint.app.adapter;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.squint.app.PosterDetailsActivity;
import com.squint.app.R;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class PersonalPosterAdapter extends BaseAdapter {

	public static final String		TAG = PersonalPosterAdapter.class.getSimpleName();
	public static final String 		ACTION_SELECT 			   		= "com.squint.action.poster.select";
	public static final String 		EXTRA_POSTER_ID	  			    = "com.squint.data.poster.ID";
	public static final String 		EXTRA_POSTER_NAME	  			= "com.squint.data.poster.NAME";
	public static final String 		EXTRA_POSTER_DESCRIPTION	  	= "com.squint.data.poster.DESCRIPTION";	
	public static final String 		EXTRA_POSTER_START_TIME		    = "com.squint.data.poster.START_TIME";
	public static final String 		EXTRA_POSTER_AUTHOR_FIRSET_NAME	= "com.squint.data.poster.AUTHOR.FIRST_NAME";
	public static final String 		EXTRA_POSTER_LOCATION_NAME 	    = "com.squint.data.poster.LOCATION.NAME";
	
	
	private Context 				context;
	private final LayoutInflater 	inflater;
	private List<ParseObject>	 	data;

	private static class ViewHolder {
		  public TextView name;
	}

	public PersonalPosterAdapter(Context context, List<ParseObject> data) {
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
			convertView = inflater.inflate(R.layout.item_program_personal, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);

		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		convertView.setTag(holder);
		holder.name.setTag(item);
		
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder)v.getTag();				
				ParseObject item = (ParseObject)h.name.getTag();			
				Intent intent = new Intent(PosterDetailsActivity.ACTION_SELECT);
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ID, item.getObjectId());
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_NAME, getName(item));
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_AUTHOR, getAuthor(item));
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_AUTHOR_ID, getAuthorId(item));
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_DESCRIPTION, getDescription(item));
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_LOCATION_NAME, getLocationName(item));

                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_ID, getAbstractId(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_ID, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_CONTENT, getAbstractContent(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_CONTENT, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_PDF, getAbstractPdf(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ABSTRACT_PDF, "");
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
		
	private String getAuthorId(ParseObject object) {
		return object.getParseObject("author").getObjectId();		
	}
	
	private String getDescription(ParseObject object) {
		return object.getString("description");		
	}
	
	private String getLocationName(ParseObject object) {
		return object.getParseObject("location").getString("name");		
	}

    private boolean getAbstractExist (ParseObject object)
    {
        return object.containsKey("abstract");
    }

    private String getAbstractId(ParseObject object) {
        return object.getParseObject("abstract").getObjectId();
    }

    private String getAbstractPdf(ParseObject object) {
        return object.getParseObject("abstract").getParseFile("pdf").getUrl();
    }

    private String getAbstractContent(ParseObject object) {
        return object.getParseObject("abstract").getString("content");
    }
}
