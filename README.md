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
- [License](#license)

# Overview
## Features
### Video import
At startup, a window opens where the user can drag and drop video files. 

<img width="798" alt="drop" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/34400f2c-0b03-46dd-a159-20e6f31c9807">


There is also a classic way to select a file through the navigation bar of the application on top of "File -> Select Video" or keyboard shortcuts ⌘ + O.

<img width="214" alt="menuOpenVideo" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/dde66e40-d247-4ae8-943f-bc7facaede6a">

There is a tabbed element on the navigation bar of the application so that the user can switch between working windows.

### Image grabbing
After importing the video file, the application automatically switches to the image capture tab. Here is a table where we see the selected video with information about the location of the file in the form of a link, duration, number of capture frames at the output at the current interval at the bottom and the progress scale. Below the settings there is a field for a color barcode that will be dynamically drawn with each capture frame. [Barcode](https://thefilmstage.com/movie-barcode-an-entire-feature-film-in-one-image/) - this is the color palette of frames in the film, it reflects the color character of the colors and shades used in the work. There is a button on the barcode field to view the barcode. The last zone is the overall progress of the capture queue with start/stop and cancel buttons.

<img width="799" alt="grab" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/af4c70d4-79e1-4293-8b36-6851a7e26fca">

When you start the process by pressing the Start button, the begins shots [grabbing](#grab). Above the progress school there is a log description of what is happening at the moment, what is the current frame and how many of them there are in total.

<img width="799" alt="grabbing" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/19f2400b-4355-4c72-91b6-a1f9e81bdc81">

And of course it is possible to take screenshots for all imported files. The progress in the table shows the status of each, and the total of the entire queue.

<img width="798" alt="queue" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/a6e82c68-d3bc-4614-955b-fd638e36237f">

### Result

#### Shots
The resulting frames in the process are saved to disk in an automatically created folder with the same name as the video file. The folder location is the same as the file. The name of the frames is the name of the video file with the timecode suffix.

<img width="1032" alt="Output" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/e37c97a6-8c4c-4daf-9e03-f64dc378e3db">

#### Barcode
The resulting color barcode can be viewed by clicking on its field. The file is also saved to the frames folder.

<img width="799" alt="barcode" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/abfcec08-17a5-4e22-94a0-3d1526e5c4a6">

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
This software uses code of <a href=http://ffmpeg.org>FFmpeg</a> licensed under the <a href=http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>LGPLv2.1</a>, compiled with a wrapper [FFmpegKit](https://github.com/arthenica/ffmpeg-kit).

