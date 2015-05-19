package com.squint.android.widget;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.util.Base64;
import android.util.Log;

public class PhotoHandler {
	

	public static String httpEncodeBitmap(Bitmap photo) {    
		ByteArrayOutputStream bArray = new ByteArrayOutputStream();
	    //photo.compress(Bitmap.CompressFormat.JPEG, 100, bArray);
	    byte[] b = bArray.toByteArray();
	    return Base64.encodeToString(b, Base64.DEFAULT);
	}
	
	public static String encodeBitmapToString(Bitmap photo) {    
		ByteArrayOutputStream bArray = new ByteArrayOutputStream();
	    photo.compress(Bitmap.CompressFormat.JPEG, 100, bArray);
	    byte[] b = bArray.toByteArray();
	    return Base64.encodeToString(b, Base64.DEFAULT);
	}
	
	public static Bitmap decodeBitmapFromString(String encodedPhoto) {
	    if (encodedPhoto == null || encodedPhoto.length() == 0) return null;
	    else {
	    	byte[] b = Base64.decode(encodedPhoto, Base64.DEFAULT);
	    	return BitmapFactory.decodeByteArray(b, 0, b.length);
	    }	
	}
	
	public static Bitmap getBitmapFromDrawable(Context context, int resourceId) {
		return BitmapFactory.decodeResource(context.getResources(), resourceId);
	}
	
	public static Bitmap scaleBitmap(Bitmap photo, float scale) {
		 int bmpWidth = photo.getWidth();
		 int bmpHeight = photo.getHeight();
	     Matrix matrix = new Matrix();
	     matrix.postScale(scale, scale);
	     return Bitmap.createBitmap(photo, 0, 0, bmpWidth, bmpHeight, matrix, true);
	}
	
	public static Bitmap scaleBitmap(Bitmap photo, int max_size) {
		 int bmpWidth = photo.getWidth();
		 int bmpHeight = photo.getHeight();
		 float scale = 1;
	     Matrix matrix = new Matrix();
		 if (bmpWidth >= bmpHeight) scale = (float)max_size / bmpWidth;
		 else scale = (float)max_size / bmpHeight;
	     matrix.postScale(scale, scale);
	     return Bitmap.createBitmap(photo, 0, 0, bmpWidth, bmpHeight, matrix, false);
	}
	
	public static Bitmap cropBitmap(Bitmap photo) {
		 int bmpWidth = photo.getWidth();
		 int bmpHeight = photo.getHeight();
		 
		 if (bmpWidth >= bmpHeight) {
			  return Bitmap.createBitmap(photo, 
					  					 bmpWidth/2 - bmpHeight/2, 0,
					  					 bmpHeight, bmpHeight);
		 }else{
			  return Bitmap.createBitmap(photo,
					  					 0, bmpHeight/2 - bmpWidth/2,
					  					bmpWidth, bmpWidth);
		 }
	}
	
	public static Bitmap cropScaleBitmap(Bitmap photo, int req_size) {
		 Bitmap crop_photo = cropBitmap(photo);
		 return scaleBitmap(crop_photo, req_size);
	}
	
	// Read local bitmap 
	public static Bitmap readBitmapFromStorage(Context context, Uri selectedImage) { 
		Bitmap bm = null; 
		BitmapFactory.Options options = new BitmapFactory.Options(); 
		options.inSampleSize = 2; // if 4 means 1/4, 3 means 1/3, such like that.
		//options.inJustDecodeBounds = true; // try smaller
		AssetFileDescriptor fileDescriptor = null; 
		
		try { 
			fileDescriptor = context.getContentResolver().openAssetFileDescriptor(selectedImage,"r");
		} catch (FileNotFoundException e) { 
			e.printStackTrace(); 
		} 
		finally{ 
		try { 
			bm = BitmapFactory.decodeFileDescriptor(fileDescriptor.getFileDescriptor(), null, options); 
			fileDescriptor.close(); 
			} catch (IOException e) { 
				e.printStackTrace(); 
			} 
		}
		
		int rotate = 0;
        ExifInterface exif;
		try {
			exif = new ExifInterface(selectedImage.getPath());
	        int exifOrientation = exif.getAttributeInt(
	                ExifInterface.TAG_ORIENTATION,
	                ExifInterface.ORIENTATION_NORMAL);
	        Log.d("Exif Orientation", exifOrientation + "");
	        Log.d("0", ExifInterface.ORIENTATION_NORMAL + "");
	        Log.d("90", ExifInterface.ORIENTATION_ROTATE_90 + "");
	        Log.d("180", ExifInterface.ORIENTATION_ROTATE_180 + "");
	        Log.d("270", ExifInterface.ORIENTATION_ROTATE_270 + "");
	                switch (exifOrientation) {
	                case ExifInterface.ORIENTATION_ROTATE_90:
	        	        rotate = 90;
	        	        break; 
	                case ExifInterface.ORIENTATION_ROTATE_180:
	        	        rotate = 180;
	        	        break;
	                case ExifInterface.ORIENTATION_ROTATE_270:
	        	        rotate = 270;
	        	        break;
	                }	
		} catch (IOException e) {
			e.printStackTrace();
		}	
		
        if (rotate != 0) {
	        int w = bm.getWidth();
	        int h = bm.getHeight();
	
	        //Setting pre rotate
	        Matrix mtx = new Matrix();
	        mtx.preRotate(rotate);
	
	        // Rotating Bitmap & convert to ARGB_8888, required by tess
	        bm = Bitmap.createBitmap(bm, 0, 0, w, h, mtx, false);
	        bm = bm.copy(Bitmap.Config.ARGB_8888, true);
        }
		
		return bm; 
	}
	
    public static Bitmap decodeSampleBitmapFromUri(String path, int width, int height) {
    	Bitmap bm = null;
    	final BitmapFactory.Options options = new BitmapFactory.Options();
    	options.inJustDecodeBounds = true;
    	BitmapFactory.decodeFile(path, options);
    	
    	options.inSampleSize = calculateInSampleSize(options, width, height);
    	options.inJustDecodeBounds = false;
    	bm = BitmapFactory.decodeFile(path, options);
    	return bm;
    }
    
    private static int calculateInSampleSize(BitmapFactory.Options options, int width, int height) {
    	final int h = options.outHeight;
    	final int w = options.outWidth;
    	int inSampleSize = 1;
    	
    	if (h > height || w > width) {
    		if (w > h) inSampleSize = Math.round((float)h / (float)height);
    		else inSampleSize = Math.round((float)w /(float)width);  		
    	}
    	return inSampleSize;
    }

	
}
