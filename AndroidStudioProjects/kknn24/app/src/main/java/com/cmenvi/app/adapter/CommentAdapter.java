package com.cmenvi.app.adapter;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.cmenvi.app.R;
import com.cmenvi.app.data.CommentDAO;
import com.cmenvi.app.data.PostDAO;
import com.parse.ParseObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class CommentAdapter extends BaseAdapter {

	public static final String			TAG = CommentAdapter.class.getSimpleName();
	public static final String 			ACTION_COMMENT_SELECT 			= "com.cmenvi.action.comment.select";
	public static final String 			EXTRA_COMMENT_ID	  			= "com.cmenvi.data.comment.ID";
	public static final String 			EXTRA_COMMENT_POST				= "com.cmenvi.data.comment.POST";
	public static final String 			EXTRA_COMMENT_AUTHOR			= "com.cmenvi.data.comment.AUTHOR";
	public static final String 			EXTRA_COMMENT_AUTHORNAME		= "com.cmenvi.data.comment.AUTHORNAME";
	public static final String 			EXTRA_COMMENT_CONTENT			= "com.cmenvi.data.comment.CONTENT";
	public static final String 			EXTRA_COMMENT_DATE	    		= "com.cmenvi.data.comment.DATE";
	public static final String 			EXTRA_COMMENT_CREATEDAT			= "com.cmenvi.data.comment.CREATEDAT";
	public static final String 			EXTRA_COMMENT_UPDATEDAT		    = "com.cmenvi.data.comment.UPDATEDAT";

	private Context 					context;
	private final LayoutInflater 		inflater;
	private SimpleDateFormat			sdf;
	private List<ParseObject>	 		data;

	private static class ViewHolder {
		public TextView authorname;
		public TextView content;
		public TextView createdAt;
	}

	public CommentAdapter(Context context, List<ParseObject> data) {
		this.context = context;
		inflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.data = data;
		sdf = new SimpleDateFormat("MM-dd hh:mm a", Locale.getDefault());
		sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
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
		Log.d(TAG, "GetView");
		ViewHolder holder;
		if (convertView == null) {
			convertView = inflater.inflate(R.layout.item_comment, null);
			holder = new ViewHolder();
			holder.authorname = (TextView) convertView.findViewById(R.id.author_name);
			holder.content = (TextView) convertView.findViewById(R.id.content);
			holder.createdAt = (TextView) convertView.findViewById(R.id.createdAt);
		} else holder = (ViewHolder) convertView.getTag();

		ParseObject item = data.get(position);
		holder.authorname.setText(getAuthorname(item));
		holder.content.setText(getContent(item));
		holder.createdAt.setText(getCreatedAt(item));
		convertView.setTag(holder);

		return convertView;
	}

	public void update(List<ParseObject> feeds) {
		if (data == null) data = new ArrayList<ParseObject>();
		else data.clear();
		data.addAll(feeds);
		notifyDataSetChanged();
		Log.d(TAG, "Update: " + data.size());
	}

	private String getAuthorname(ParseObject object) {
		return object.getString(CommentDAO.AUTHORNAME);
	}

	private String getContent(ParseObject object) {
		return object.getString(CommentDAO.CONTENT);
	}

	private String getCreatedAt(ParseObject object) {
		Log.d(TAG, "AAA");
		return sdf.format(object.getCreatedAt());
	}

}
