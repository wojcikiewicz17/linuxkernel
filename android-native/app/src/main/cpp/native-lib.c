#include <jni.h>

JNIEXPORT jstring JNICALL
Java_com_example_androidnative_MainActivity_stringFromJNI(JNIEnv *env, jobject thiz) {
    (void)thiz;
    const char *message = "Hello from C JNI (armeabi-v7a + arm64-v8a)";
    return (*env)->NewStringUTF(env, message);
}
