package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.URLUtil;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.parse.Parse;
import com.parse.ParseFile;
import com.parse.ParseGeoPoint;
import com.parse.ParseImageView;
import com.parse.ParseObject;

import java.util.List;

/**
 * Created by csjan on 9/14/15.
 */
public class VenueAdapter extends BaseAdapter {
    public static final String 			ACTION_VENUE_WEBSITE 		= "com.cmmath.action.venue.website";
    public static final String          ACTION_VENUE_URL            = "com.cmmath.data.venue.url";
    public static final String 			ACTION_VENUE_CALL 			= "com.cmmath.action.venue.call";
    public static final String          ACTION_VENUE_PHONE          = "com.cmmath.data.venue.phone";
    public static final String 			ACTION_VENUE_NAVIGATE 		= "com.cmmath.action.venue.navigate";
    public static final String 			EXTRA_VENUE_LAT	  			= "com.cmmath.data.venue.LATITUDE";
    public static final String 			EXTRA_VENUE_LNG				= "com.cmmath.data.venue.LONGITUDE";

    private final Context context;
    private final List venues;

    public VenueAdapter(Context context, List queryresults) {
        this.context = context;
        this.venues = queryresults;
    }

    @Override
    public int getCount()
    {
        return venues.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  venues.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_venue, vg, false);
        }

        ParseObject venue = (ParseObject)venues.get(position);

        ParseImageView imageLabel = (ParseImageView)view.findViewById(R.id.venueImage);
        TextView nameLabel = (TextView)view.findViewById(R.id.venueName);
        ImageButton callLabel = (ImageButton)view.findViewById(R.id.venueCall);
        ImageButton navigateLabel = (ImageButton)view.findViewById(R.id.venueNavigate);
        Button websiteLabel = (Button)view.findViewById(R.id.venueWebsite);
        TextView contentLabel = (TextView)view.findViewById(R.id.venueContent);

        ParseFile image = venue.getParseFile("image");
        imageLabel.setParseFile(image);
        imageLabel.loadInBackground();
        nameLabel.setText(venue.getString("name"));
        callLabel.setTag(venue.getString("phone"));
        navigateLabel.setTag(venue.getParseGeoPoint("coord"));
        websiteLabel.setTag(venue.getString("url"));
        contentLabel.setText(venue.getString("content"));

        websiteLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getTag().toString() != null && URLUtil.isValidUrl(v.getTag().toString()) == true) {
                    Intent intent = new Intent(ACTION_VENUE_WEBSITE);
                    intent.putExtra(ACTION_VENUE_URL, v.getTag().toString());
                    context.sendBroadcast(intent);

                } else {
                    Toast.makeText(context, context.getString(R.string.error_invalidlink), Toast.LENGTH_LONG).show();
                }
            }
        });

        callLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getTag().toString() != null) {
                    Intent intent = new Intent(ACTION_VENUE_CALL);
                    intent.putExtra(ACTION_VENUE_PHONE, v.getTag().toString());
                    context.sendBroadcast(intent);
                } else {
                    Toast.makeText(context, context.getString(R.string.error_invalidphone), Toast.LENGTH_LONG).show();
                }
            }
        });

        navigateLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getTag() != null) {
                    Intent intent = new Intent(ACTION_VENUE_NAVIGATE);
                    intent.putExtra(EXTRA_VENUE_LAT, ((ParseGeoPoint) v.getTag()).getLatitude());
                    intent.putExtra(EXTRA_VENUE_LNG, ((ParseGeoPoint) v.getTag()).getLongitude());
                    context.sendBroadcast(intent);
                } else {
                    Toast.makeText(context, context.getString(R.string.error_invalidgeo), Toast.LENGTH_LONG).show();
                }
            }
        });

        return view;
    }
}
