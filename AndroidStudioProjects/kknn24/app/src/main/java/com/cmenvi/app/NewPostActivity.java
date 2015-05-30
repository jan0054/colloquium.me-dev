package com.cmenvi.app;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Camera;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.cmenvi.app.data.PostDAO;
import com.cmenvi.app.widget.BaseActivity;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;


public class NewPostActivity extends BaseActivity {

    public ParseUser selfuser;
    public int email_on;
    public int chat_on;
    public int is_person;
    public String link_str;
    public ParseObject selfperson;

    public EditText post_input;
    public TextView save_post;
    public ImageButton photo_camera;
    public Bitmap bitmap = null;
    private Uri imageUri, imageUri2;

    private final static int PICK_IMAGE_REQUEST = 1;
    private final static int TAKE_PIC = 2;
    private final static int CROP_PHOTO = 3;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_newpost);
        mTitle.setText(getString(R.string.title_newpost));
        configOptions(OPTION_BACK, OPTION_NONE);

        save_post = (TextView) findViewById(R.id.save_post);
        save_post.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveNewPost();
            }
        });
        //default disable stuff
        post_input = (EditText) findViewById(R.id.post_input);
        post_input.setEnabled(true);

        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Colloquium_Me");
        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                Log.d("Colloquium_Me", "failed to create directory");
            }
        }
        Calendar c = Calendar.getInstance();
        System.out.println("Current time => "+c.getTime());
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String formattedDate = sdf.format(c.getTime());
        String filename = "Colloquium_Me/IMG_"+formattedDate+".jpg";
        imageUri=Uri.fromFile(new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), filename));
//        imageUri=Uri.fromFile(new File(Environment.getExternalStorageDirectory(), "test.jpg"));

        c = Calendar.getInstance();
        System.out.println("Current time => "+c.getTime());
        sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        formattedDate = sdf.format(c.getTime());
        String filename2 = "Colloquium_Me/IMG_"+formattedDate+".jpg";
        imageUri2=Uri.fromFile(new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), filename2));

        //check if current user is person
        if (ParseUser.getCurrentUser() != null)
        {
            selfuser = ParseUser.getCurrentUser();
        }
    }

    public void selectPhoto(View view)
    {
        Intent intent = new Intent();
        // Show only images, no videos or anything else
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_PICK);
        // Always show the chooser (if there are multiple options available)
        startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_REQUEST);
    }

    public void selectCamera(View view)
    {
        Intent intent = new Intent();
        // Show only images, no videos or anything else
        intent.setAction(MediaStore.ACTION_IMAGE_CAPTURE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
        // Always show the chooser (if there are multiple options available)
        startActivityForResult(intent, TAKE_PIC);
    }

    private void cropPhoto(Uri uri)
    {
        Log.d("TAG", "in cropPhoto " + uri.toString());

        Intent intent = new Intent();
        intent.setAction("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");// crop=true 有這句才能叫出裁剪頁面.
        intent.putExtra("aspectX", 1);// 这兩項為裁剪框的比例.
        intent.putExtra("aspectY", 1);// x:y=1:1
        intent.putExtra("outpuX", 1080);//圖片尺寸
        intent.putExtra("outputY", 1080);
//        intent.putExtra("return-data", false);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri2);
        startActivityForResult(intent, CROP_PHOTO);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK ) {
            ImageView imageView = (ImageView) findViewById(R.id.post_image);
            switch (requestCode) {
                case PICK_IMAGE_REQUEST:
                    if( data != null && data.getData() != null) {
                        Uri uri = data.getData();
                        Log.d(TAG, "cropPhoto uri="+uri.toString());
                        cropPhoto(uri);
                    }
                    break;
                case TAKE_PIC:
                    cropPhoto(imageUri);
                    break;
                case CROP_PHOTO:
                    try {
                        bitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), imageUri2);
                        // Log.d(TAG, String.valueOf(bitmap));
                        imageView.setImageBitmap(bitmap);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    break;
                default:
                    break;
            }
            //覆蓋原來的Activity
        super.onActivityResult(requestCode, resultCode, data);

        }
    }
    public void saveNewPost()
    {
        Log.i(TAG, "send post button pressed");
        //setup all the data for the new post object
        EditText editText = (EditText) findViewById(R.id.post_input);
        ImageView imageView = (ImageView) findViewById(R.id.post_image);
        final String message = editText.getText().toString();
        Log.i(TAG, message);
        ParseUser currentUser = ParseUser.getCurrentUser();

        if(message.length()<1) {
            toast("Empty imput.");
            return;
        }
        ParseObject postmsg = new ParseObject("Post");
        postmsg.put(PostDAO.CONTENT, message);
        postmsg.put(PostDAO.AUTHOR, currentUser);
        postmsg.put(PostDAO.AUTHORNAME, currentUser.getUsername());
        if(bitmap!=null) {
            Calendar c = Calendar.getInstance();
            System.out.println("Current time => "+c.getTime());
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            String formattedDate = sdf.format(c.getTime());
            String filename = selfuser.getUsername()+formattedDate+".jpg";
            toast(filename);
            ParseFile image = new ParseFile(filename, bitmapToByteArray(bitmap));
            postmsg.put(PostDAO.IMAGE, image);
        }
        ParseACL commentACL = new ParseACL(ParseUser.getCurrentUser());
        commentACL.setPublicReadAccess(true);
        commentACL.setPublicWriteAccess(true);
        postmsg.setACL(commentACL);
        postmsg.saveInBackground(new SaveCallback() {
            public void done(ParseException e) {
                if (e == null) {
                    //saved complete
                    EditText edt = (EditText) findViewById(R.id.post_input);
                    edt.setText("");
                    Log.i(TAG, "new post save success");
                } else {
                    Log.i(TAG, "sendPost save fail");
                    //did not save successfully
                }
            }
        });
        onBackPressed();
    }
    public static byte[] bitmapToByteArray(Bitmap bmp)
    {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.JPEG, 100, stream);
        byte[] byteArray = stream.toByteArray();
        Log.d("NEWPost", byteArray.toString());
        return byteArray;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        if(bitmap != null) {
            bitmap.recycle();
            bitmap = null;
        }
    }

/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_user_preference, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
*/

}
