
package com.shodanuk.rnestimoteandroid;


import android.content.Context;
import android.os.Looper;
import android.util.Log;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.EstimoteSDK;
import com.estimote.sdk.Region;
import com.estimote.sdk.SystemRequirementsChecker;
import com.estimote.sdk.Utils;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.Promise;

import java.util.EnumSet;

import java.util.List;
import java.util.UUID;


public class RNEstimoteModule extends ReactContextBaseJavaModule {
    private static final String LOG_TAG = "RNEstimoteModule";
    private ReactApplicationContext mReactContext;
    private BeaconManager mBeaconManager;

    private static final String EVENT_ENTER_REGION = "didEnterRegion";
    private static final String EVENT_EXIT_REGION = "didExitRegion";
    private static final String EVENT_DID_RANGE = "didRangeBeacons";
    private static final String EVENT_DID_FAIL = "didFailWithError";

    public RNEstimoteModule(ReactApplicationContext reactContext, BeaconManager beaconManager) {
        super(reactContext);
        Log.d(LOG_TAG, "RNEstimoteModule - started");

        Looper.prepare();

        mReactContext = reactContext;
        mBeaconManager = beaconManager;

        setupMonitoringListeners();
        setupRangingListeners();
        setupErrorListeners();
    }

    private void setupRangingListeners() {
        mBeaconManager.setRangingListener(new BeaconManager.RangingListener() {
            @Override
            public void onBeaconsDiscovered(Region region, List<Beacon> list) {
                WritableArray beacons = new WritableNativeArray();
                WritableMap params = new WritableNativeMap();
                WritableMap regionMap = new WritableNativeMap();

                regionMap.putString("identifier", region.getIdentifier());
                regionMap.putString("uuid", region.getProximityUUID().toString());

                params.putMap("region", regionMap);

                for (Beacon beacon : list) {
                    WritableMap beaconMap = new WritableNativeMap();

                    beaconMap.putString("uuid", beacon.getProximityUUID().toString());
                    beaconMap.putInt("major", beacon.getMajor());
                    beaconMap.putInt("minor", beacon.getMinor());
                    beaconMap.putInt("rssi", beacon.getRssi());
                    beaconMap.putString("proximity", Utils.computeProximity(beacon).toString());
                    beaconMap.putDouble("accuracy", Utils.computeAccuracy(beacon));

                    beacons.pushMap(beaconMap);
                }

                params.putArray("beacons", beacons);

                mReactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(EVENT_DID_RANGE, params);
            }
        });
    }

    private void setupMonitoringListeners() {
        mBeaconManager.setMonitoringListener(new BeaconManager.MonitoringListener() {
            @Override
            public void onEnteredRegion(Region region, List<Beacon> list) {
                WritableMap params = new WritableNativeMap();
                params.putString("region", region.getIdentifier());
                params.putString("uuid", region.getProximityUUID().toString());
                mReactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(EVENT_ENTER_REGION, params);
            }
            @Override
            public void onExitedRegion(Region region) {
                WritableMap params = new WritableNativeMap();
                params.putString("region", region.getIdentifier());
                params.putString("uuid", region.getProximityUUID().toString());
                mReactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(EVENT_EXIT_REGION, params);
            }

        });
    }

    private void setupErrorListeners() {
        mBeaconManager.setErrorListener(new BeaconManager.ErrorListener() {
            @Override
            public void onError(Integer errorID) {
                WritableMap params = new WritableNativeMap();
                params.putString("error", errorID.toString());
                mReactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(EVENT_DID_FAIL, params);
            }
        });
    }


    private Region convertReadableMapToBeaconRegion(ReadableMap regionMap) {
        Integer major = null;
        Integer minor = null;

        if (regionMap.hasKey("major")) {
            major = regionMap.getInt("major");
        }

        if (regionMap.hasKey("minor")) {
            minor = regionMap.getInt("minor");
        }

        Region region = new Region(regionMap.getString("identifier"),
                                    UUID.fromString(regionMap.getString("uuid")),
                                    major,
                                    minor);

        return region;
    }

    @Override
    public String getName() {
      return LOG_TAG;
    }

    @ReactMethod
    public void requestAlwaysAuthorization(final Promise promise) {
        SystemRequirementsChecker.check(getCurrentActivity(), new SystemRequirementsChecker.Callback() {
            @Override
            public void onRequirementsMissing(EnumSet<SystemRequirementsChecker.Requirement> enumSet) {
                promise.resolve(enumSet.toString());
            }
        });
    }

    @ReactMethod
    public void requestWhenInUseAuthorization() {
        Log.w(LOG_TAG, "requestWhenInUseAuthorization is not available on Android");
    }

    @ReactMethod
    public void getAuthorizationStatus() {
        Log.w(LOG_TAG, "getAuthorizationStatus is not available on Android");
    }

    @ReactMethod
    public void startMonitoringForRegion(ReadableMap regionMap) {
        final Region region = this.convertReadableMapToBeaconRegion(regionMap);
        mBeaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                mBeaconManager.startMonitoring(region);
            }
        });
    }

    @ReactMethod
    public void stopMonitoringForRegion(ReadableMap regionMap) {
        final Region region = this.convertReadableMapToBeaconRegion(regionMap);
        mBeaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                mBeaconManager.stopMonitoring(region);
            }
        });
    }

    @ReactMethod
    public void stopMonitoringForAllRegions() {
        Log.w(LOG_TAG, "stopMonitoringForAllRegions is not available on Android");
    }

    @ReactMethod
    public void requestStateForRegion() {
        Log.w(LOG_TAG, "requestStateForRegion is not available on Android");
    }

    @ReactMethod
    public void startRangingBeaconsInRegion(ReadableMap regionMap) {
        final Region region = this.convertReadableMapToBeaconRegion(regionMap);
        mBeaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                mBeaconManager.startRanging(region);
            }
        });
    }

    @ReactMethod
    public void stopRangingBeaconsInRegion(ReadableMap regionMap) {
        final Region region = this.convertReadableMapToBeaconRegion(regionMap);
        mBeaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                mBeaconManager.stopRanging(region);
            }
        });
    }

    @ReactMethod
    public void stopRangingBeaconsInAllRegions() {
        Log.w(LOG_TAG, "stopRangingBeaconsInAllRegions is not available on Android");
    }
}
