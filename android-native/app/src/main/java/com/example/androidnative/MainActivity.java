package com.example.androidnative;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public final class MainActivity extends Activity {
    private static final String TAG = "RafaBeta";
    private static final long CLEANUP_TIMEOUT_MS = 1500L;

    static {
        System.loadLibrary("native-lib");
    }

    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private TextView terminalOutput;
    private Process activeProcess;

    public native String stringFromJNI();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, "Beta app init started");
        setContentView(createContentView());
        appendLine("app: BETA_INIT_OK");
        appendLine("jni: " + stringFromJNI());
        runCommand("echo BETA_TERMINAL_OK");
    }

    private View createContentView() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        int padding = (int) (16 * getResources().getDisplayMetrics().density);
        root.setPadding(padding, padding, padding, padding);

        Button rerun = new Button(this);
        rerun.setText("Run beta self command");
        rerun.setOnClickListener(view -> runCommand("echo BETA_TERMINAL_OK"));
        root.addView(rerun);

        terminalOutput = new TextView(this);
        terminalOutput.setTextIsSelectable(true);
        terminalOutput.setText("Rafacodephi Termux Beta\n");

        ScrollView scrollView = new ScrollView(this);
        scrollView.addView(terminalOutput);
        root.addView(scrollView, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f));
        return root;
    }

    private void runCommand(String command) {
        executor.execute(() -> {
            int exitCode = -1;
            try {
                appendLine("$ " + command);
                ProcessBuilder builder = new ProcessBuilder("/system/bin/sh", "-c", command);
                builder.redirectErrorStream(true);
                Process process = builder.start();
                synchronized (this) {
                    activeProcess = process;
                }
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                        process.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        appendLine(line);
                    }
                }
                exitCode = process.waitFor();
                appendLine("exit: " + exitCode);
                Log.i(TAG, "Beta command finished with exitCode=" + exitCode);
            } catch (IOException e) {
                appendError("io", e);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                appendError("interrupted", e);
            } finally {
                clearFinishedProcess();
                if (exitCode == 0) {
                    appendLine("cleanup: BETA_CLEANUP_OK");
                }
            }
        });
    }

    private void appendLine(String message) {
        runOnUiThread(() -> terminalOutput.append(message + "\n"));
    }

    private void appendError(String phase, Exception error) {
        Log.e(TAG, "Beta terminal error during " + phase, error);
        appendLine("error[" + phase + "]: " + error.getClass().getSimpleName()
                + ": " + error.getMessage());
    }

    private synchronized void clearFinishedProcess() {
        if (activeProcess != null && !activeProcess.isAlive()) {
            activeProcess = null;
        }
    }

    @Override
    protected void onDestroy() {
        cleanupActiveProcess();
        executor.shutdownNow();
        super.onDestroy();
        Log.i(TAG, "Beta app destroyed after process cleanup");
    }

    private void cleanupActiveProcess() {
        Process process;
        synchronized (this) {
            process = activeProcess;
            activeProcess = null;
        }
        if (process == null || !process.isAlive()) {
            return;
        }
        process.destroy();
        try {
            if (!process.waitFor(CLEANUP_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
                Log.w(TAG, "Beta process did not exit after destroy; forcing cleanup");
                process.destroyForcibly();
                process.waitFor(CLEANUP_TIMEOUT_MS, TimeUnit.MILLISECONDS);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            process.destroyForcibly();
        }
    }
}
