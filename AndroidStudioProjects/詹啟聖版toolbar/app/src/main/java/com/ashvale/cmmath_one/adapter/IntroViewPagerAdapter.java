package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.cmmath_one.LoginActivity;
import com.ashvale.cmmath_one.R;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by huangyueh-yi on 12/15/15.
 */
public class IntroViewPagerAdapter extends PagerAdapter {
    private final Context context;
    private List<View> mListViews;
    int pageNumber;

    public IntroViewPagerAdapter(Context context, int pageNumber) {
        this.context = context;
        this.pageNumber = pageNumber;
        mListViews = new ArrayList<View>();

        String[] textArray = context.getResources().getStringArray(R.array.intro_text_array);
        TypedArray imageArray = context.getResources().obtainTypedArray(R.array.intro_image_array);

        for (int i = 0; i<pageNumber; i++) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View v = inflater.inflate(R.layout.intro_layout, null);
            ImageView introImage = (ImageView) v.findViewById(R.id.introImage);
            TextView introText = (TextView) v.findViewById(R.id.introText);

            introImage.setImageDrawable(imageArray.getDrawable(i));
            introText.setText(textArray[i]);
            mListViews.add(v);
        }
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object)   {
        container.removeView((View) object);
    }


    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        View view = mListViews.get(position);
        container.addView(view);
        return view;
    }

    @Override
    public int getCount() {
        return  mListViews.size();
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0==arg1;
    }
}
