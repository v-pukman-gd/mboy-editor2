
## Push to Itch
add `version.txt` to folder and make a `.zip` file

```
cd EXPORT/2.2
butler push WIN.zip vfpe/mboy-editor:win --userversion 2.2
butler push MACOS.zip vfpe/mboy-editor:mac --userversion 2.2
butler push LINUX.zip vfpe/mboy-editor:linux --userversion 2.2
```

```
cd /Users/boom/Projects/godot/EXPORT/2.1.1
butler push MACOS.zip vfpe/mboy-editor:mac --userversion 2.1.1
butler push WIN64.zip vfpe/mboy-editor:win --userversion 2.1.1
butler push LINUX64.zip vfpe/mboy-editor:linux --userversion 2.1.1
```
