# RM2000 Portable

<img src="https://upload.wikimedia.org/wikipedia/en/6/6c/Replica_%28Front_Cover%29.png" align="right" width="128" height="128" style="margin: 0 10px">

RM2000 Portable is a lightweight audio sampling tool for macOS. It uses the ScreenCaptureKit introduced in macOS 12 Monterey.

Quickly record audio samples from any application, organize them with tags, and search them from anywhere

# Building

RM2000 Portable requires Xcode and macOS 13 or newer.

It is recommended to have a Development Signing Certificate active on Xcode so that the Screen Recording permission dialog doesn't show up after every single build. A **Development Signing Certificate** is not the same as an **Apple Developer ID** and is completely free to make.

1. Open the settings for `RM2000.xcodeproj`

2. Go to the `Signing and Capabilities` tab

3. Selecting the `replica` target

4. Create a new Development seam and set Signing Certificate as "Development"

## Power of Persuasion

Proposed feature overview:

* Use SwiftUI for a native and fast UI, similar to Voice Memos.app

![image](crude_mockup.png)

* Clever file naming scheme - the tags are a part of the filename, making audio samples searchable from any DAW

![image](filename_mockup.png)

[replica_filename_demo.webm](https://github.com/marceloexc/replica/assets/35786323/15420d9e-4e9a-4e76-a085-eb8186673db8)


* Use ScreenCaptureKit for inbuilt support of recording system audio in a variety of formats - [no more messing around with Soundflower](https://github.com/mattingalls/Soundflower)

## Considerations

Google tells me the max character limit for file names on macOS (APFS) is 255 characters...so we can't go over that. Wasn't able to find max limits for Windows (NTFS) or Linux (ext4)

## Related reading
 
* [QuickRecorder](https://github.com/lihaoyun6/QuickRecorder)
* [File over app](https://stephango.com/file-over-app)
* [SwiftLAME](https://github.com/hidden-spectrum/SwiftLAME?tab=readme-ov-file)
* [denote](https://github.com/protesilaos/denote) (inspiration for file naming scheme)
* [linkding](https://github.com/sissbruecker/linkding) (inspiration for tagging system)
