package com.cmmath.app.adapter;

import java.util.ArrayList;
import java.util.List;
import com.parse.ParseObject;
import com.cmmath.app.PosterDetailsActivity;
import com.cmmath.app.R;
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

public class PosterAdapter extends BaseAdapter {

	public static final String		TAG = PosterAdapter.class.getSimpleName();
	private Context 				context;
	private final LayoutInflater 	inflater;
	private List<ParseObject>	 	data;

	private static class ViewHolder {
		  //public ImageView image;
		  public TextView name;
		  public TextView description;
		  public TextView author_name;
		  public TextView location_name;
	}

	public PosterAdapter(Context context, List<ParseObject> data) {
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
			convertView = inflater.inflate(R.layout.item_poster, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);
			holder.description = (TextView) convertView.findViewById(R.id.description);
			holder.author_name = (TextView) convertView.findViewById(R.id.author_name);
			holder.location_name = (TextView) convertView.findViewById(R.id.location_name);

		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		holder.author_name.setText(getAuthor(item));
		holder.description.setText(getDescription(item));
		holder.location_name.setText(getLocationName(item));
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
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_CONTENT, getDescription(item));
				intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_LOCATION_NAME, getLocationName(item));
                intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_AUTHOR_INSTITUTION, getAuthorInstitution(item));
                intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_AUTHOR_EMAIL, getAuthorEmail(item));
                intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_AUTHOR_WEBSITE, getAuthorWebsite(item));

                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_ID, getAbstractId(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_ID, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_CONTENT, getAbstractContent(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_CONTENT, "");
                }
                if (getAbstractExist(item))
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_PDF, getAbstractPdf(item));
                }
                else
                {
                    intent.putExtra(PosterDetailsActivity.EXTRA_POSTER_ATTACHMENT_PDF, "");
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

    private String getAuthorInstitution(ParseObject object) {
        return object.getParseObject("author").getString("institution");
    }

    private String getAuthorEmail(ParseObject object) {
        return object.getParseObject("author").getString("email");
    }

    private String getAuthorWebsite(ParseObject object) {
        return object.getParseObject("author").getString("link");
    }
}
