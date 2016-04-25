package com.ashvale.cmmath_one.adapter;


import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v13.app.FragmentPagerAdapter;
import android.support.v13.app.FragmentStatePagerAdapter;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.Log;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.ProgramFragment;
import com.ashvale.cmmath_one.fragments.TimelineFragment;
import com.ashvale.cmmath_one.fragments.VenueFragment;
import com.ashvale.cmmath_one.fragments.WordReceiveFragment;


/**
 * Created by csjan on 9/25/15.
 */
public class FragmentViewPagerAdapter extends FragmentPagerAdapter {
    final int PAGE_COUNT = 5;
    private String tabTitles[] = new String[] { "Overview", "Program", "People", "Timeline", "Venue" };
    private Context context;
    /*
    private int[] imageResId = {
            R.drawable.home64,
            R.drawable.program64,
            R.drawable.people64,
            R.drawable.timeline64,
            R.drawable.venue64
    };
    */
    public FragmentViewPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        this.context = context;
    }

    @Override
    public int getCount() {
        return PAGE_COUNT;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position)
        {

            case 0:
                return OverviewFragment.newInstance("", "");

            case 1:
                return ProgramFragment.newInstance("", "");

            case 2:
                return AttendeeFragment.newInstance("", "");

            case 3:
                return TimelineFragment.newInstance("", "");

            case 4:
                return VenueFragment.newInstance("", "");

            default:
                return null;
        }
    }

    @Override
    public CharSequence getPageTitle(int position) {
        // Generate title based on item position
        //return tabTitles[position];

        //Drawable image = context.getResources().getDrawable(imageResId[position]);
        //image.setBounds(0, 0, image.getIntrinsicWidth(), image.getIntrinsicHeight());
        //SpannableString sb = new SpannableString(" ");
        //ImageSpan imageSpan = new ImageSpan(image, ImageSpan.ALIGN_BOTTOM);
        //sb.setSpan(imageSpan, 0, 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        //return sb;
        return null;
    }

}
