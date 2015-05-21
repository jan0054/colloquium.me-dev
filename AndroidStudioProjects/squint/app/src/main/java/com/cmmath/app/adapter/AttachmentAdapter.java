package com.cmmath.app.adapter;

import java.util.ArrayList;
import java.util.List;

import com.parse.ParseObject;
import com.cmmath.app.AttachmentDetailsActivity;
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

public class AttachmentAdapter extends BaseAdapter {

	public static final String		TAG = AttachmentAdapter.class.getSimpleName();

	
	private Context 				context;
	private final LayoutInflater 	inflater;
	private List<ParseObject>	 	data;

	private static class ViewHolder {
		  public TextView name;
		  public TextView author_name;
	}

	public AttachmentAdapter(Context context, List<ParseObject> data) {
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
			convertView = inflater.inflate(R.layout.item_attachment, null);
			holder = new ViewHolder();
			holder.name = (TextView) convertView.findViewById(R.id.name);
			holder.author_name = (TextView) convertView.findViewById(R.id.author_name);

		} else holder = (ViewHolder) convertView.getTag();
		
		ParseObject item = data.get(position);
		holder.name.setText(getName(item));
		holder.author_name.setText(getAuthor(item));
		convertView.setTag(holder);
		holder.name.setTag(item);
		
		convertView.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder)v.getTag();				
				ParseObject item = (ParseObject)h.name.getTag();			
				Intent intent = new Intent(AttachmentDetailsActivity.ACTION_SELECT);
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_ID, item.getObjectId());
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_NAME, getName(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR, getAuthor(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR_ID, getAuthorId(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR_INSTITUTION, getAuthorInstitution(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR_EMAIL, getAuthorEmail(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR_LINK, getAuthorWebsite(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_PDF, getPdfUrl(item));
				intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_CONTENT, getContent(item));
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
	
	private String getAuthorInstitution(ParseObject object) {
		return object.getParseObject("author").getString("institution");		
	}
	
	private String getAuthorEmail(ParseObject object) {
		return object.getParseObject("author").getString("email");		
	}
	
	private String getAuthorWebsite(ParseObject object) {
		return object.getParseObject("author").getString("link");		
	}	
	
	private String getContent(ParseObject object) {
		return object.getString("content");		
	}
	
	private String getPdfUrl(ParseObject object) {
        if (object.has("pdf")) {
            return object.getParseFile("pdf").getUrl();
        }
        else {
            return  "";
        }
	}
	
}
