package com.ashvale.cmmath_one;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class NewPostActivity extends AppCompatActivity {
    public static final String		TAG = NewPostActivity.class.getSimpleName();

    private SharedPreferences savedEvents;
    private ParseObject currenteventObject;
    public EditText post_input;
    public ImageButton post_photo;
    public ImageButton post_camera;
    public ImageButton post_deleteimage;
    public ParseImageView post_image;
    public Bitmap bitmap = null;
    private Uri imageUri, imageUri2;

    private final static int PICK_IMAGE_REQUEST = 1;
    private final static int TAKE_PIC = 2;
    private final static int CROP_PHOTO = 3;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_post);

        //default disable stuff
        post_input = (EditText) findViewById(R.id.post_input);
        post_input.setEnabled(true);
        post_photo = (ImageButton) findViewById(R.id.btn_photo);
        post_camera = (ImageButton) findViewById(R.id.btn_camera);
        post_deleteimage = (ImageButton) findViewById(R.id.btn_delete);
        post_image = (ParseImageView) findViewById(R.id.post_image);

        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Colloquium_Me");
        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                Log.d("Colloquium_Me", "failed to create directory");
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_new_post, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        Log.d("cm_app", "itemID = " + item.getItemId());
        if(item.getItemId()== android.R.id.home) {
            onBackPressed();
            return true;
        } else if (id == R.id.savepost) {
            saveNewPost();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    public Uri setUri(int havefolder)
    {
        Calendar c = Calendar.getInstance();
        System.out.println("Current time => "+c.getTime());
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String formattedDate = sdf.format(c.getTime());
        String filename;
        if(havefolder == 1) {
            filename = "Colloquium_Me/IMG_" + formattedDate + ".jpg";
        } else {
            filename = "IMG_"+formattedDate+".jpg";
        }
        return Uri.fromFile(new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), filename));
    }

    public void selectPhoto(View view)
    {
        Intent intent = new Intent();
        // Show only images, no videos or anything else
        intent.setType("image/jpeg");
        intent.setAction(Intent.ACTION_PICK);
        // Always show the chooser (if there are multiple options available)
        startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_REQUEST);
    }

    public void selectCamera(View view)
    {
        Intent intent = new Intent();
        // Show only images, no videos or anything else
        intent.setAction(MediaStore.ACTION_IMAGE_CAPTURE);
        imageUri = setUri(1);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
        // Always show the chooser (if there are multiple options available)
        startActivityForResult(intent, TAKE_PIC);
    }

    private void cropPhoto(Uri uri)
    {
        Log.d("TAG", "in cropPhoto " + uri.toString());

        Intent intent = new Intent();
        intent.setAction("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/jpeg");
        intent.putExtra("crop", "true");// crop=true 有這句才能叫出裁剪頁面.
        intent.putExtra("aspectX", 1);// 这兩項為裁剪框的比例.
        intent.putExtra("aspectY", 1);// x:y=1:1
        intent.putExtra("outputX", 1080);//圖片尺寸
        intent.putExtra("outputY", 1080);
//        intent.putExtra("return-data", false);
        imageUri2 = setUri(0);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri2);
        startActivityForResult(intent, CROP_PHOTO);
    }

    public void deleteImage(View view)
    {
        post_deleteimage.setEnabled(false);
        post_deleteimage.setClickable(false);
        post_deleteimage.setVisibility(View.INVISIBLE);

        bitmap = null;
        post_image.setImageBitmap(bitmap);

        post_photo.setEnabled(true);
        post_photo.setClickable(true);
        post_photo.setVisibility(View.VISIBLE);
        post_camera.setEnabled(true);
        post_camera.setClickable(true);
        post_camera.setVisibility(View.VISIBLE);
    }

    public void disableBtn()
    {
        post_camera.setEnabled(false);
        post_camera.setClickable(false);
        post_camera.setVisibility(View.INVISIBLE);
        post_photo.setEnabled(false);
        post_photo.setClickable(false);
        post_photo.setVisibility(View.INVISIBLE);

        post_deleteimage.setEnabled(true);
        post_deleteimage.setClickable(true);
        post_deleteimage.setVisibility(View.VISIBLE);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK ) {
            ParseImageView imageView = (ParseImageView) findViewById(R.id.post_image);
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
                        Log.d(TAG, String.valueOf(bitmap));
                        imageView.setImageBitmap(bitmap);
                        disableBtn();
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
            toast("Empty input.");
            return;
        }
        savedEvents = this.getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");
        currenteventObject = ParseObject.createWithoutData("Event", currentId);

        ParseObject postmsg = new ParseObject("Post");
        postmsg.put("content", message);
        postmsg.put("author", currentUser);
        postmsg.put("event", currenteventObject);
        if(bitmap!=null) {
            Calendar c = Calendar.getInstance();
            System.out.println("Current time => "+c.getTime());
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            String formattedDate = sdf.format(c.getTime());
            String filename = currentUser.getString("username")+formattedDate+".jpg";
            String perviewname = "preview"+filename;
            //toast(filename);
            ParseFile image = new ParseFile(filename, bitmapToByteArray(bitmap));
            ParseFile previewimage = new ParseFile(perviewname, bitmapToByteArrayPreview(bitmap));
            postmsg.put("image", image);
            postmsg.put("preview", previewimage);
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
        bmp.compress(Bitmap.CompressFormat.JPEG, 70, stream);
        byte[] byteArray = stream.toByteArray();
        Log.d("cm_app", "NEWPost "+byteArray.toString());
        return byteArray;
    }

    public static byte[] bitmapToByteArrayPreview(Bitmap bmp)
    {
        Bitmap bmp2 = Bitmap.createScaledBitmap(bmp, 480, 480, false);
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bmp2.compress(Bitmap.CompressFormat.JPEG, 70, stream);
        byte[] byteArray = stream.toByteArray();
        Log.d("cm_app", "NEWPost Preview "+byteArray.toString());
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
    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

}
