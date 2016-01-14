package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.util.List;

public class PersonalTalkAdapter extends BaseAdapter {

	public static final String TAG = PersonalTalkAdapter.class.getSimpleName();
	
	private Context context;
	private List<ParseObject> data;

	private static class ViewHolder {
		  public TextView name;
	}

	public PersonalTalkAdapter(Context context, List<ParseObject> data) {
		this.context = context;
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
	public View getView(int position, View view, ViewGroup parent) {
		if (view == null)
		{
			LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			view = inflater.inflate(R.layout.listitem_personaltalk, parent, false);
		}

		ParseObject talk = (ParseObject) data.get(position);
		TextView nameLabel = (TextView)view.findViewById(R.id.talk_name);
		nameLabel.setText(talk.getString("name"));

		return view;
	}

}
