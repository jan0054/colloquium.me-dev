package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.data.YoutubeVideoItem;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.squareup.picasso.Picasso;

import org.w3c.dom.Text;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 3/21/16.
 */
public class StreamListAdapter extends BaseAdapter {
    private final Context context;
    private final List<YoutubeVideoItem> streams;

    public StreamListAdapter(Context context, List<YoutubeVideoItem> results) {
        this.context = context;
        this.streams = results;
    }

    @Override
    public int getCount()
    {
        return streams.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  streams.get(position);
    }

    @Override
    public int getViewTypeCount()
    {
        return 1;
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            view = inflater.inflate(R.layout.listitem_stream, vg, false);
        }
        TextView nameLabel = (TextView)view.findViewById(R.id.streamName);
        TextView descLabel = (TextView)view.findViewById(R.id.streamDescription);
        ImageView previewImage = (ImageView)view.findViewById(R.id.streamImage);
        TextView statusLabel = (TextView)view.findViewById(R.id.streamStatus);

        YoutubeVideoItem videoItem = streams.get(position);
        nameLabel.setText(videoItem.getTitle());
        descLabel.setText(videoItem.getDescription());
        Picasso.with(context.getApplicationContext()).load(videoItem.getThumbnailURL()).into(previewImage);
        String status = videoItem.getLiveStatus();
        if (status.equalsIgnoreCase("live"))
        {
            statusLabel.setText(R.string.stream_live);
            statusLabel.setTextColor(context.getResources().getColor(R.color.live_video_red));
        }
        else
        {
            statusLabel.setText(R.string.stream_archive);
            statusLabel.setTextColor(context.getResources().getColor(R.color.secondary_text));
        }
        return view;
    }
}