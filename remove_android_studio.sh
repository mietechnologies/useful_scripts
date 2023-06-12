# Deletes the Android Studio application
rm -Rf /Applications/Android\ Studio.app
# Delete All Android Studio related preferences
# The asterisk here should target all folders/files beginning with the string before it
rm -Rf ~/Library/Preferences/AndroidStudio*
rm -Rf ~/Library/Preferences/Google/AndroidStudio*
# Deletes Studio's plist file
rm -Rf ~/Library/Preferences/com.google.android.*
# Deletes Emulator's plist file
rm -Rf ~/Library/Preferences/com.android.*
# Deletes main plugins
rm -Rf ~/Library/Application\ Support/AndroidStudio*
rm -Rf ~/Library/Application\ Support/Google/AndroidStudio*
# Deletes all logs that Android Studio outputs
rm -Rf ~/Library/Logs/AndroidStudio*
rm -Rf ~/Library/Logs/Google/AndroidStudio*
# Deletes Android Studio's caches
rm -Rf ~/Library/Caches/AndroidStudio*
# Deletes older versions of Android Studio (if any)
rm -Rf ~/.AndroidStudio*