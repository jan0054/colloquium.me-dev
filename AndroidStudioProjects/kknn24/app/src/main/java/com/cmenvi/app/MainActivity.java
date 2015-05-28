package com.cmenvi.app;

import java.util.Locale;

import com.parse.ParseInstallation;
import com.parse.ParseUser;
import com.cmenvi.app.widget.BaseActivity;
import android.annotation.SuppressLint;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v13.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TextView;

public class MainActivity extends BaseActivity {

	public static final String 	TAG 	 = MainActivity.class.getSimpleName();

    public TabHost 				mTabHost;
	SectionsPagerAdapter 		mSectionsPagerAdapter;
	ViewPager 					mViewPager;	

    public int day;

	// Tab
	public static final int[] TAB_TITLES = {R.string.title_program,
											R.string.title_people,
											R.string.title_timeline,
											R.string.title_venue,
											R.string.title_settings};
	public static final int[] TAB_ICONS = { R.drawable.tab_program,
											R.drawable.tab_people,
											R.drawable.tab_career,
											R.drawable.tab_travel,
											R.drawable.tab_settings };

	protected cmenviApplication app;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_main);

		mSectionsPagerAdapter = new SectionsPagerAdapter(getFragmentManager());
 		mViewPager = (ViewPager) findViewById(R.id.pager);
		mViewPager.setAdapter(mSectionsPagerAdapter);
		mViewPager.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
					@Override
					public void onPageScrollStateChanged(int state) {
						if (state == 1) {
							mOptionExtraRight.setVisibility(View.GONE);
							mOptionRight.setVisibility(View.VISIBLE);
							mOptionLeft.setEnabled(true);
							mOptionLeft.setAlpha(1f);
						}
					}
					
					@Override
					public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {}						
			
					@Override
					public void onPageSelected(int position) {
						mTabHost.setCurrentTab(position);			
					}
				});
		
		// Tabs	
		mTabHost =  (TabHost)findViewById(android.R.id.tabhost);
        mTabHost.setOnTabChangedListener(tabListener);
        mTabHost.setup();
		initTabs();
		mViewPager.setCurrentItem(0);

	}

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            day = intent.getIntExtra("day",0);
            //toast("got intent:"+day);

            ProgramFragment fragment = (ProgramFragment) getFragmentManager().findFragmentByTag(makeFragmentName(mViewPager.getId(),0));
            if (fragment != null) {
                fragment.refreshDay(day);
            }

        }
    };
    private static String makeFragmentName(int viewId, int index) {
        return "android:switcher:" + viewId + ":" + index;
    }
	
	@SuppressLint("InflateParams")
	private View createTabView(final int id) {
        View view = LayoutInflater.from(this).inflate(R.layout.tab_custom, null);
        ImageView tab_icon = (ImageView)view.findViewById(R.id.icon);
        TextView tab_title = (TextView)view.findViewById(R.id.title);
        tab_icon.setImageDrawable(getResources().getDrawable(TAB_ICONS[id]));
        tab_title.setText(getString(TAB_TITLES[id]));
        return view;
    }
	
    public void initTabs(){
		for (int i = 0; i < mSectionsPagerAdapter.getCount(); i++) {			
			// Tab on Bottom
			TabHost.TabSpec spec;
			spec = mTabHost.newTabSpec(Integer.toString(i));
			spec.setIndicator(mSectionsPagerAdapter.getPageTitle(i), getResources().getDrawable(TAB_ICONS[i]));
			spec.setContent(new TabHost.TabContentFactory() {
        		@Override
				public View createTabContent(String tag) {
        			return findViewById(R.id.realtabcontent);
        		}
    		});
	        spec.setIndicator(createTabView(i));
			mTabHost.addTab(spec);
		}
    }
	
    TabHost.OnTabChangeListener tabListener    =   new TabHost.OnTabChangeListener() {
        @Override
        public void onTabChanged(String tabId) {
      	  int id = Integer.parseInt(tabId);	 
      	  mTitle.setText(TAB_TITLES[id]);
      	  mViewPager.setCurrentItem(id);
      	  mTabHost.setCurrentTab(id);
      	  
      	  View fv = getCurrentFocus();
      	  if (fv != null){
  	    	  InputMethodManager imm = (InputMethodManager)fv.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
  	    	  imm.hideSoftInputFromWindow(fv.getWindowToken(), 0);
      	  }
      	  
      	  // Configure title and options
      	  switch(id) {
      	  case 0:
              //configOptions(OPTION_NONE, OPTION_DAYS);
      		  clearOptions();
      		  break;
      	  case 1:
      		  configOptions(OPTION_NONE, OPTION_TALK);          	  
          	  break;
      	  case 2:
      		  //clearOptions();
          	configOptions(OPTION_NONE, OPTION_NEWPOST);
          	break;
      	  case 3:
      		  clearOptions();
          	  break;
      	  case 4:
      		  if (!isLogin()) configOptions(OPTION_NONE, OPTION_LOGIN);          	  
      		  else configOptions(OPTION_USER, OPTION_LOGOUT);
          	  break;          	  
          default:
      		  clearOptions();
      		  break;
      	  }
        }
      };
      
	
	@Override  
    protected void onResume() {
        super.onResume();
        this.registerReceiver(mMessageReceiver, new IntentFilter("day_intent"));
    }

	@Override  
    protected void onPause() {  
        super.onPause();
        this.unregisterReceiver(mMessageReceiver);
    }

	public class SectionsPagerAdapter extends FragmentPagerAdapter {

		public SectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int position) {

			switch (position) {
            case 0:
                //ProgramFragment pf = new ProgramFragment();
                //Bundle args = new Bundle();
                //args.putInt("day", day);
                //pf.setArguments(args);
                //return pf;
                return ProgramFragment.newInstance(getBaseContext());
            case 1: return PeopleFragment.newInstance(getBaseContext());
            case 2: return TimelineFragment.newInstance(getBaseContext());
            case 3: return VenueFragment.newInstance(getBaseContext());
            case 4: return SettingsFragment.newInstance(getBaseContext());
            //default: return CareerFragment.newInstance(getBaseContext());
            default:return ProgramFragment.newInstance(getBaseContext());
			}
		}

		@Override
		public int getCount() { 
			return 5;	// Tab amount
		}

		@Override
		public CharSequence getPageTitle(int position) {
			Locale l = Locale.getDefault();
			switch (position) {
			case 0:
				return getString(R.string.title_program).toUpperCase(l);
			case 1:
				return getString(R.string.title_people).toUpperCase(l);
			case 2:
				return getString(R.string.title_timeline).toUpperCase(l);
			case 3:
				return getString(R.string.title_venue).toUpperCase(l);
			case 4:
				return getString(R.string.title_settings).toUpperCase(l);
			}
			return null;
		}
	}

	
	@Override
	public void onClick(View v) {
		int resId = v.getId();
		if (resId == R.id.opt_left || resId == R.id.opt_right) {
			int optId = (Integer)v.getTag();
			switch(optId) {
				case OPTION_BACK:
					onBackPressed();
					break;
				case OPTION_LOGOUT:
					ParseUser.logOut();
					app = (cmenviApplication) getApplication();
					app.isPerson = false;

					//after logging out, remove user from installation so this phone doesn't get push notifications anymore
					ParseInstallation installation = ParseInstallation.getCurrentInstallation();
					installation.remove("user");
					installation.saveInBackground();

					configOptions(OPTION_NONE, OPTION_LOGIN);
					Intent intent = new Intent(this, LoginActivity.class);
					intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(intent);
					overridePendingTransition (R.anim.page_left_slide_in, R.anim.page_left_slide_out);
					break;
				case OPTION_LOGIN:
					toLoginPage(null);
					break;
				case OPTION_TALK:
					ParseUser user = ParseUser.getCurrentUser();
					if (user != null) {
						//toast("My Conversation List: " + user.getObjectId());
						toPage(new Intent(), ConversationActivity.class);
					} else {
						toast("Please log in first!");
						toLoginPage(ConversationActivity.class);
					}
					break;
				case OPTION_USER:
					ParseUser selfuser = ParseUser.getCurrentUser();
					if (selfuser != null) {
						app = (cmenviApplication) getApplication();
						if (!app.isPerson) {
							updateIsPerson(selfuser);
						} else {
							toPage(new Intent(), UserPreferenceActivity.class);
						}
					} else {
						toast("Please log in first!");
						toLoginPage(ConversationActivity.class);
					}
					break;
				case OPTION_NEWPOST:
					ParseUser thisuser = ParseUser.getCurrentUser();
					if (thisuser != null) {
						app = (cmenviApplication) getApplication();
						if (!app.isPerson) {
							updateIsPerson(thisuser);
						} else {
						}
					} else {
						toast("Please log in first!");
						toLoginPage(ConversationActivity.class);
						return;
					}
					toPage(new Intent(), NewPostActivity.class);
					break;
				case OPTION_NEWCOMMENT:
					break;
				case OPTION_SAVE:
					toMainPage();
					break;
			}
		}
	}

}
