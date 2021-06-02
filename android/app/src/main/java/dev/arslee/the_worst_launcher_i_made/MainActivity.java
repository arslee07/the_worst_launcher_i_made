package dev.arslee.the_worst_launcher_i_made;

import android.app.WallpaperManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "dev.arslee.the_worst_launcher_i_made/wallpaper";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getWallpaper")) {
                                WallpaperManager wallpaperManager = WallpaperManager.getInstance(this);
                                Drawable wallpaperDrawable = wallpaperManager.getDrawable();

                                Bitmap bitmap = ((BitmapDrawable) wallpaperDrawable).getBitmap();
                                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
                                byte[] bitmapData = stream.toByteArray();

                                result.success(bitmapData);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}