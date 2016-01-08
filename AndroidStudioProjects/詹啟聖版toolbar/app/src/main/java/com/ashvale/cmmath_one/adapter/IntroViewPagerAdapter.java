package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;

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

        String[] titleArray = context.getResources().getStringArray(R.array.intro_title_array);
        String[] contentArray = context.getResources().getStringArray(R.array.intro_content_array);
        TypedArray imageArray = context.getResources().obtainTypedArray(R.array.intro_image_array);

        for (int i = 0; i<pageNumber; i++) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View v = inflater.inflate(R.layout.intro_layout, null);
            ImageView introImage = (ImageView) v.findViewById(R.id.introImage);
            TextView introTitle = (TextView) v.findViewById(R.id.introTitle);
            TextView introContent = (TextView) v.findViewById(R.id.introContent);

//            introImage.setImageResource(imageArray.getResourceId(i, -1));
            switch (i){
                case 0:
                    introImage.setImageResource(R.drawable.tut_chooseevent);
                case 1:
                    introImage.setImageResource(R.drawable.tut_home);
                case 2:
                    introImage.setImageResource(R.drawable.tut_drawer);
                case 3:
                    introImage.setImageResource(R.drawable.tut_overview);
            }
            introTitle.setText(titleArray[i]);
            introContent.setText(contentArray[i]);
            mListViews.add(v);
        }
        imageArray.recycle();
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
