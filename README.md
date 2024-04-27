# kbprefs

> Manage macOS defaults / preferences / UserDefaults

## Quick start

Copy `preferences.example.yaml` to `~/.config/preferences/preferences.yaml` to get started, then run `kbprefs watch`. As preferences changes are detected, if they do not match an ignore pattern, they will be updated into `preferences.yaml`.

```shell
mkdir -p ~/.config/preferences
cp preferences.example.yaml ~/.config/preferences/preferences.yaml
swift build --configuration release
.build/release/kbprefs watch
```

`kbprefs` can be copied to a somewhere more convenient so it can be used anywhere.

The default output path is `~/.config/preferences/preferences.yaml`. It can be changed by passing a `-p <some path>` option.

When watching for changes, the script uses 100% CPU on a single thread because of the lazy NSApplication run call. It's usually not used for long though.

After watching and making some changes like adjusting mouse cursor size or moving the dock, there will likely be some preferences in the yaml file you did not intend. Remove any of the unwanted preferences.

Use `kbprefs export` to update values in the preferences file for any matching applications and keys. You can add an value as an empty string then run export to update to the actual value. Ie, add to the yaml file:

```yaml
user:
  com.apple.universalaccess:
    mouseDriverCursorSize: ""
```

Then after running `kbprefs export` will be updated to something like:

```yaml
user:
  com.apple.universalaccess:
    mouseDriverCursorSize: { float: 1.5 }
```

Running `kbprefs import` will write values from the yaml file to the system. This can be used to quickly setup some machine settings to a known state, or to switch between known states using multiple yaml files.

There are no tests.
