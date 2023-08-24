[🇬🇧](./) [🇷🇺](./README_RUS.html)

![Cover](https://github.com/DenDmitriev/GrabShot/assets/65191747/a52c4252-d0a7-47d1-8a80-87c8ea5ce7f7)

# GrabShot
A macOS application for creating a series of screenshots from a video file.

## Content
- [Overview](#overview)
  - [Features](#features)
    - [Video import](#video-import)
    - [Image grabbing](#image-grabbing)
    - [Result](#result)
      - [Shots](#shots)
      - [Barcode](#barcode)
  - [Settings](#settings)
    - [Capture Settings](#capture-settings)
    - [Barcode Settings](#barcode-settings)
- [Support](#support)
- [Privacy Policy](./PrivacyPolicyEn.html)
- [License](#license)

# Overview
## Features
### Video import
At startup, a window opens where the user can drag and drop video files. The application supports the following video formats: .flv, .mkv, .ogg, .mxf, .3gp, .avi, .mov, .mp4, .mpg, .vob.

<img width="798" alt="drop" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/34400f2c-0b03-46dd-a159-20e6f31c9807">

There is also a classic way to select a file through the navigation bar of the application on top of "File -> Select Video" or keyboard shortcuts ⌘ + O.

<img width="214" alt="menuOpenVideo" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/dde66e40-d247-4ae8-943f-bc7facaede6a">

There is a tabbed element on the navigation bar of the application so that the user can switch between working windows.

### Image grabbing
After importing the video file/files, the application automatically switches to the image capture tab.

<img width="812" alt="GrabReady" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/8e91865d-32ab-4a64-bd61-320b976ac845">

Here is a table where we see the selected video with information fields.
The first column indicates the inclusion and disconnection of video from the grab queue. If you uncheck the box, the video will not be in the queue for grabbing.
The second column indicates the file locations. Clicking on it will open a file explorer for the location of the original video file. 
The third column is an indication of the export folder for screenshots with a path. Clicking opens a dialog box with the choice of the catalog to export or change it. If it is not possible to see the whole path in the field, then you can expand the window horizontally.
Then the duration of the video. The value is taken from the video metadata.
The next column is the capture range, when clicked, a window opens with the setting of the start and end points by timecode. By default, the range is "Full". In order for the timecode input fields to become active, you need to select the "Excerpt" range, and to return to normal mode, return to "Full". If the entered timecode parameters go beyond the acceptable limits, the application will return the values to the boundary values for this video.

<img width="812" alt="RangeSetting" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/a2782b51-dd70-490e-aeb4-f99246bd7ac5">

The next column is the number of capture frames at the output at the current interval at the bottom and the selected grabbing range.
The last column is the progress bar. Which displays the progress relative to a single video file.

Below the settings there is a field for a color barcode that will be dynamically drawn with each capture frame. [Color Barcode](https://thefilmstage.com/movie-barcode-an-entire-feature-film-in-one-image/) is the tonal color palette of the frames in the film, it reflects the color character of the colors used in the work. It is used to analyze the tonal and color content of a video file or its excerpt. There is a button on the barcode field to view the barcode. 
The last zone is the overall progress of the capture queue with start/stop and cancel buttons.

When you start the process by pressing the Start button, the grab of frames begins. Above the progress school there is a log description of what is happening at the moment, what is the current frame and how many of them are in the queue.

<img width="812" alt="GrabProcess" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/faa124c6-a915-49ed-943c-8471c5f5754c">


### Result

#### Shots
The resulting frames in the process are saved to disk at the specified path by the user in an automatically created folder with the same name as the video file. The name of the frames is the name of the video file with the timecode suffix. If the barcode saving switch is enabled in the settings, it will be saved in the same directory. At the end, a file explorer will open with the capture results folder.

<img width="1032" alt="Output" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/e37c97a6-8c4c-4daf-9e03-f64dc378e3db">

#### Barcode
The resulting color barcode can be viewed by clicking on its field. The file is also saved to the frames folder.

<img width="812" alt="StripView" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/6768a6ba-ff39-417f-8a05-dd7479320fc7">

Below are a few barcodes from different movies.

 - [Severance](https://www.kinopoisk.ru/series/1343318/)
  ![Severance S01E01 1080p rus LostFilm TVStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/a69d156f-1c5a-4e5e-b4c0-0b4ebfbd58ef)

 - [Fantastic Mr. Fox](https://www.kinopoisk.ru/film/86621/?utm_referrer=www.google.com)
![Fantastic Mr Fox 2009 1080p BluRay DTS Rus Eng HDCLUBStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/f5a92065-6a33-40f4-ae3b-0d76d43c1c2f)

 - [Tár](https://www.kinopoisk.ru/film/4511218/)
  ![Tár (2022) BDRip 1080p-V_odne_riloStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/836774c2-d841-48e8-9eea-cb1b05a5ec18)


## Settings
The operation of the application can be configured. The launch of the window for this lies in an intuitive place - in the upper panel of the system by clicking on the name of the program or by command ⌘ + ,. 

<img width="301" alt="settings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/9f9b9aea-61a8-4c0b-828b-6a3cdd742e94">

The settings window is divided into two tabs.

### Capture Settings
There is a slider to select the compression ratio of JPG images. And the switch for opening the folder with the resulting images at the end of the capture process.

<img width="721" alt="grabSettings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/1ec51915-3d51-4f50-a0d8-8b10fa4e888b">

### Barcode Settings
The barcode is needed for different tasks and what it should be should be determined by the user. The average color or colors are determined on each frame, their number can be selected. The resolution of the final image may need to be large or small, so there are margins for the size in pixels.

<img width="728" alt="stripSettings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/1c8b032f-1a78-4277-a45a-87e15245423c">

<img width="145" alt="Colors" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/11ed2a66-ecb8-48d5-8616-0c563c68bef9">

# Support
The support by email – [dv.denstr@gmail.com](mailto:dv.denstr@gmail.com).

# License
This software uses code of [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html), compiled with a wrapper [FFmpegKit](https://github.com/arthenica/ffmpeg-kit).

