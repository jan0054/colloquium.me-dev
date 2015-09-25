package com.ashvale.cmmath_one.adapter;


import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.support.v13.app.FragmentPagerAdapter;
import android.support.v13.app.FragmentStatePagerAdapter;
import android.util.Log;

import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.ProgramFragment;
import com.ashvale.cmmath_one.fragments.TimelineFragment;
import com.ashvale.cmmath_one.fragments.VenueFragment;


/**
 * Created by csjan on 9/25/15.
 */
public class FragmentViewPagerAdapter extends FragmentPagerAdapter {
    final int PAGE_COUNT = 5;
    private String tabTitles[] = new String[] { "Overview", "Program", "People", "Timeline", "Venue" };
    private Context context;

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
                return VenueFragment.newInstance("", "");

            case 4:
                return TimelineFragment.newInstance("", "");

            default:
                return null;
        }
    }

    @Override
    public CharSequence getPageTitle(int position) {
        // Generate title based on item position
        return tabTitles[position];
    }

}
