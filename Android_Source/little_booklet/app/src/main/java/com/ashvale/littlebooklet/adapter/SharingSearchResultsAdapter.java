package com.ashvale.littlebooklet.adapter;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.URLUtil;
import android.widget.BaseAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.littlebooklet.R;
import com.parse.ParseFile;
import com.parse.ParseObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 4/26/16.
 */
public class SharingSearchResultsAdapter extends BaseAdapter {

    private final Context context;
    private final List searchResults;

    public SharingSearchResultsAdapter(Context context, List searchResults) {
        this.context = context;
        this.searchResults = searchResults;
    }

    @Override
    public int getCount()
    {
        return searchResults.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  searchResults.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_sharingresult, vg, false);
        }

        ParseObject resultObj = (ParseObject)searchResults.get(position);

        TextView sharingType = (TextView)view.findViewById(R.id.sharing_type);
        TextView sharingTime = (TextView)view.findViewById(R.id.sharing_time);
        TextView sharingContent = (TextView)view.findViewById(R.id.sharing_content);

        int shareType = resultObj.getInt("type");
        if (shareType == 0)
        {
            sharingType.setText(context.getString(R.string.share_type_url));
            sharingContent.setText(resultObj.getString("content"));
            sharingContent.setTag(resultObj.getString("content"));
        }
        else if (shareType == 1)
        {
            sharingType.setText(context.getString(R.string.share_type_file));
            ParseFile file = resultObj.getParseFile("file");
            sharingContent.setText(file.getUrl());
            sharingContent.setTag(file.getUrl());
        }
        else
        {
            sharingType.setText("");
            sharingContent.setText("");
        }

        Date createDate = resultObj.getCreatedAt();
        Format dateFormatter = new SimpleDateFormat("MM/dd");
        sharingTime.setText(dateFormatter.format(createDate));

        sharingContent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getTag().toString() != null && URLUtil.isValidUrl(v.getTag().toString()) == true) {
                    Intent openResult = new Intent(Intent.ACTION_VIEW, Uri.parse(v.getTag().toString()));
                    context.startActivity(openResult);
                } else {
                    Toast.makeText(context, context.getString(R.string.error_invalidlink), Toast.LENGTH_LONG).show();
                }
            }
        });

        return view;
    }
}
