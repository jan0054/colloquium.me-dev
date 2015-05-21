package com.cmmath.app.widget;

import com.cmmath.app.R;

import android.content.Context;
import android.preference.TwoStatePreference;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ToggleButton;

public class TogglePreference extends TwoStatePreference {
	private final Listener mListener = new Listener();
    private OnToggleButtonClickListener mExternalListener;
    
	public TogglePreference(Context context) {
		super(context);
	}
	
	public TogglePreference(Context context, AttributeSet attrs) {
        super(context, attrs);
    }
	
	public TogglePreference(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }
	
	@Override protected View onCreateView(ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater)getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE); 
        return inflater.inflate(R.layout.preference_row_toggle, parent, false);
    }

  	@Override protected void onBindView(View view) {
        super.onBindView(view);
        ToggleButton toggleButton = (ToggleButton) view.findViewById(R.id.toggle_button);
        toggleButton.setChecked(isChecked());
        toggleButton.setOnCheckedChangeListener(mListener);
    }

  	@Override protected void onClick() {
        if (mExternalListener != null) mExternalListener.onPreferenceClick();
    }
  	
    public static interface OnToggleButtonClickListener {
        void onPreferenceClick();
    }
    
  	public void setToggleButtonClickListener(OnToggleButtonClickListener listener) {
        mExternalListener = listener;
    }
  	
  	private class Listener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (!callChangeListener(isChecked)) {
                // Listener didn't like it, change it back.
                // CompoundButton will make sure we don't recurse.
                buttonView.setChecked(!isChecked);
                return;
            }

            TogglePreference.this.setChecked(isChecked);
        }
    }
  	
}