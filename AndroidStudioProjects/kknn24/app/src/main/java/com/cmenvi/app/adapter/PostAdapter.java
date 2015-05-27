package com.cmenvi.app.adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.cmenvi.app.R;
import com.cmenvi.app.data.PostDAO;
import com.cmenvi.app.widget.BitmapManager;
import com.parse.ParseFile;
import com.parse.ParseObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class PostAdapter extends BaseAdapter {

	public static final String			TAG = PostAdapter.class.getSimpleName();
	public static final String 			ACTION_POST_SELECT 		= "com.cmenvi.action.post.select";
	public static final String 			EXTRA_POST_ID	  		= "com.cmenvi.data.post.ID";
	public static final String 			EXTRA_POST_NAME			= "com.cmenvi.data.post.NAME";
	public static final String 			EXTRA_POST_ATTACHMENT	= "com.cmenvi.data.post.ATTACHMENT";
	public static final String 			EXTRA_POST_AUTHORNAME	= "com.cmenvi.data.post.AUTHORNAME";
	public static final String 			EXTRA_POST_CONTENT		= "com.cmenvi.data.post.CONTENT";
	public static final String 			EXTRA_POST_IMAGE	    = "com.cmenvi.data.post.IMAGE";
	public static final String 			EXTRA_POST_CREATEDAT	= "com.cmenvi.data.post.CREATEDAT";
	public static final String 			EXTRA_POST_DATE		    = "com.cmenvi.data.post.DATE";

	private Context 					context;
	private final LayoutInflater 		inflater;
	private SimpleDateFormat 			sdf;
	private List<ParseObject>	 		data;

	private static class ViewHolder {
		public TextView name;
		public TextView authorname;
		public TextView createdAt;
		public TextView content;
		public ImageView image;
	}

	public PostAdapter(Context context, List<ParseObject> data) {
		this.context = context;
		inflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.data = data;
		sdf = new SimpleDateFormat("MM-dd hh:mm a", Locale.getDefault());
		sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
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
			convertView = inflater.inflate(R.layout.item_post, null);
			holder = new ViewHolder();
			holder.authorname = (TextView) convertView.findViewById(R.id.author_name);
			holder.createdAt = (TextView) convertView.findViewById(R.id.createdAt);
			holder.content = (TextView) convertView.findViewById(R.id.content);
			holder.image = (ImageView) convertView.findViewById(R.id.image);
		} else holder = (ViewHolder) convertView.getTag();

		ParseObject item = data.get(position);
		holder.authorname.setText(getAuthorname(item));
		holder.createdAt.setText(getCreatedAt(item));
		holder.content.setText(getContent(item));
		convertView.setTag(holder);
		holder.authorname.setTag(item);

		convertView.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				ViewHolder h = (ViewHolder) v.getTag();
				ParseObject item = (ParseObject) h.authorname.getTag();
				Intent intent = new Intent(ACTION_POST_SELECT);
				intent.putExtra(EXTRA_POST_ID, item.getObjectId());
				intent.putExtra(EXTRA_POST_AUTHORNAME, getAuthorname(item));
				intent.putExtra(EXTRA_POST_CREATEDAT, getCreatedAt(item));
				intent.putExtra(EXTRA_POST_CONTENT, getContent(item));
				intent.putExtra(EXTRA_POST_IMAGE, getPhotoUrl(item));
				context.sendBroadcast(intent);
			}
		});
		BitmapManager.INSTANCE.loadBitmap(getPhotoUrl(item), holder.image, 0, 0);
		return convertView;
	}

	public void update(List<ParseObject> feeds) {
		if (data == null) data = new ArrayList<ParseObject>();
		else data.clear();
		data.addAll(feeds);
		notifyDataSetChanged();
		Log.d(TAG, "Update: " + data.size());
	}

	private String getName(ParseObject object) {
		return object.getString(PostDAO.NAME);
	}

	private String getAuthorname(ParseObject object) {
		return object.getString(PostDAO.AUTHORNAME);
	}

	private String getCreatedAt(ParseObject object) {
		return sdf.format(object.getCreatedAt());
	}

	private String getContent(ParseObject object) {
		return object.getString(PostDAO.CONTENT);
	}

	private String getPhotoUrl(ParseObject object) {
		ParseFile postImage = object.getParseFile(PostDAO.IMAGE);
		if(postImage != null)
			return postImage.getUrl();
		else
			return null;
	}
}
