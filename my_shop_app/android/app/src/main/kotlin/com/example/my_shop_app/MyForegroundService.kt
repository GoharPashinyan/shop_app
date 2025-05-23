package com.example.my_shop_app

import android.app.*
import android.bluetooth.le.*
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.Handler
import android.util.Log
import androidx.core.app.NotificationCompat
import okhttp3.*
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class MyForegroundService : Service() {

    private lateinit var scanner: BluetoothLeScanner
    private lateinit var scanCallback: ScanCallback
    private val handler = Handler()
    private var isScanning = false

    private val targetBeacon = "d1 a9 53 39 5d bf 47 82 95 ef 12 5b 0b 9b a5 fa c5"
    private var userId: Int = -1 // Ստանալու ենք SharedPreferences-ից

    private val scanIntervalMillis = 60_000L // սկան ամեն 1 րոպեն մեկ
    private val scanDurationMillis = 10_000L // սկան տևողությունը՝ 10 վայրկյան

    override fun onCreate() {
        super.onCreate()
        startNotificationChannel()
        startForeground(1, createNotification("Ծառայությունը ակտիվ է"))

        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter = bluetoothManager.adapter
        scanner = adapter.bluetoothLeScanner

        scanCallback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val data = result.scanRecord?.manufacturerSpecificData ?: return

                for (i in 0 until data.size()) {
                    val bytes = data.valueAt(i)
                    val hex = bytes.joinToString(" ") { b -> "%02x".format(b) }

                    if (hex == targetBeacon && isScanning) {
                        Log.d("BLE", "🚨 Հայտնաբերվեց բեքոն։ Ուղարկում ենք հարցում backend-ին։")
                        fetchDiscountedProducts()
                        isScanning = false
                        break
                    }
                }
            }
        }

        startPeriodicScan()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.user_id", null)
        userId = raw?.toIntOrNull() ?: -1

        Log.d("SERVICE", " Սերվիսը սկսվել է օգտատեր $userId համար")
        return START_STICKY
    }


    private fun startPeriodicScan() {
        handler.post(object : Runnable {
            override fun run() {
                Log.d("BLE", " Սկսում ենք սկան 1 րոպեն մեկ")

                isScanning = true
                startBLEScan()

                handler.postDelayed({
                    stopBLEScan()
                    Log.d("BLE", " Կանգնեցվեց սկանավորումը")
                }, scanDurationMillis)

                handler.postDelayed(this, scanIntervalMillis)
            }
        })
    }

    private fun startBLEScan() {
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()

        scanner.startScan(null, settings, scanCallback)
        Log.d("BLE", " Սկսվել է BLE սկանավորումը")
    }

    private fun stopBLEScan() {
        scanner.stopScan(scanCallback)
    }

    private fun fetchDiscountedProducts() {
        if (userId == -1) {
            Log.e("HTTP", " Չի գտնվել user_id։")
            return
        }

        val client = OkHttpClient.Builder()
            .callTimeout(10, TimeUnit.SECONDS)
            .build()

        val url = "http://192.168.1.39:8080/store_api/check_discounts.php?user_id=$userId"

        val request = Request.Builder()
            .url(url)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: java.io.IOException) {
                Log.e("HTTP", " Սխալ՝ $e")
            }

            override fun onResponse(call: Call, response: Response) {
                if (response.isSuccessful) {
                    val json = JSONObject(response.body?.string() ?: "{}")
                    val products = json.optJSONArray("products") ?: return

                    for (i in 0 until products.length()) {
                        val product = products.getJSONObject(i)
                        val title = product.getString("name")
                        val discount = product.getString("Discount")

                        sendNotification("$title - Զեղչ $discount%")
                    }
                } else {
                    Log.e("HTTP", " Սխալ HTTP պատասխանի կոդ՝ ${response.code}")
                }
            }
        })
    }

    private fun sendNotification(content: String) {
        val notification = createNotification(content)
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(System.currentTimeMillis().toInt(), notification)
    }

    private fun createNotification(content: String): Notification {
        return NotificationCompat.Builder(this, "beacon_channel")
            .setContentTitle("📣 Զեղչված ապրանք")
            .setContentText(content)
            .setSmallIcon(R.mipmap.ic_launcher) // սա պետք է իսկապես գոյություն ունենա
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
    }

    private fun startNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "beacon_channel",
                "Beacon Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        stopBLEScan()
    }
}
