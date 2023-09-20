[🇬🇧](./) [🇷🇺](./README_RUS.html)

![Cover](https://github.com/DenDmitriev/GrabShot/assets/65191747/a52c4252-d0a7-47d1-8a80-87c8ea5ce7f7)

# GrabShot
An application for capturing frames from videos and extracting colors.

## Content
- [Overview](#overview)
  - [Features](#features)
    - [Video import](#video-import)
    - [Image grabbing](#image-grabbing)
    - [Result](#result)
      - [Shots](#shots)
      - [Barcode](#barcode)
    - [Import images](#import-images)
    - [Image Barcode](#image-barcode)
    - [Result image barcode](#result-image-barcode)
  - [Settings](#settings)
    - [Capture Settings](#capture-settings)
    - [Barcode Settings](#barcode-settings)
- [Support](#support)
- [Privacy Policy](./PrivacyPolicyEn.html)
- [License](#license)

# Overview

https://github.com/DenDmitriev/GrabShot/assets/65191747/6158c9ba-508f-409e-8971-c62ffa3a61f7

## Features

<img width="972" alt="GrabQueue" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/269f89fd-2005-4af9-a944-f009ca635911">

Control panel. There are workspaces in the application

To select a workspace, use the tab navigation bar

<img width="188" alt="ControlPanelOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/b17f91ad-3487-4011-8ed1-3a5426a08236">

To change the application settings, click on the gear

<img width="188" alt="SettingsOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/d3c75fd9-7c05-43d8-b0ea-7772d8e715c3">

### Video import

To get started with the video, import the files. There are several options for this:

Drag and drop files to the Grab queue tab

<img width="408" alt="DropVideoOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/aa8874d6-3cbd-43e8-b6f1-7dfda1fcbfee">

Import files via the application menu

<img width="400" alt="ImportVideoOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/974de05d-366d-4d4d-9ff7-62f4adcad41b">


### Image grabbing
After importing the video, you are taken to the capture queue tab

<img width="972" alt="GrabQueueWork" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/45ce338d-4149-40f1-b019-ce68c9d484ba">

The window consists of a table of imported videos. The first step is to select the export folder. Next, decide on the assortment, you can choose an excerpt or the whole.

<img width="202" alt="GrabControlPanel" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/280056f7-a950-477a-a61a-6f049fb21433">

Specify the frame capture interval in seconds. 

<img width="212" alt="GrabPeriodOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/32ccfaf7-4da3-4cc9-a350-9a05344e871a">

Finally, click the Start button and manage the process.

<img width="289" alt="ControlPanel" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/e650850d-76ca-4325-acd0-9608254293d4">

### Result

<img width="1032" alt="Output" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/e37c97a6-8c4c-4daf-9e03-f64dc378e3db">

#### Shots
The resulting frames in the process are saved to disk at the specified path by the user in an automatically created folder with the same name as the video file. The name of the frames is the name of the video file with the timecode suffix. If the barcode saving switch is enabled in the settings, it will be saved in the same directory. At the end, a file explorer will open with the capture results folder.

#### Barcode
The resulting color barcode can be viewed by clicking on its field. The file is also saved to the frames folder.

<img width="972" alt="StripView" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/9255a632-3e54-4569-b208-029e800285d6">

Below are a few barcodes from different movies.

 - [Severance](https://www.kinopoisk.ru/series/1343318/)
  ![Severance S01E01 1080p rus LostFilm TVStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/a69d156f-1c5a-4e5e-b4c0-0b4ebfbd58ef)

 - [Fantastic Mr. Fox](https://www.kinopoisk.ru/film/86621/?utm_referrer=www.google.com)
![Fantastic Mr Fox 2009 1080p BluRay DTS Rus Eng HDCLUBStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/f5a92065-6a33-40f4-ae3b-0d76d43c1c2f)

 - [Tár](https://www.kinopoisk.ru/film/4511218/)
  ![Tár (2022) BDRip 1080p-V_odne_riloStrip](https://github.com/DenDmitriev/GrabShot/assets/65191747/836774c2-d841-48e8-9eea-cb1b05a5ec18)

### Import images
To automatically import captured frames, you can click on the context menu on the video

<img width="342" alt="ImportFrames" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/f73c58ec-1d3b-40df-8f9c-c5f28ec98cda">

Individual frames can be imported by dragging and dropping into the "Image Colors" tab:

<img width="400" alt="DropImageOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/354feafa-45f0-4f81-acb6-2b6bd0b6d739">

Or through the application menu:

<img width="400" alt="ImportImageOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/d6b0c96c-7e9f-4626-9189-9323ec479186">

### Image Barcode

<img width="972" alt="ImageStripOverview" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/276913ea-fce3-4a6e-963f-426f448dbbad">

Functionality to create a color barcode on an image. Going to the second tab with the photo icon, you need to import images by dragging them into the window. A side navigation bar with images will open. Once you select the one you want, you can see a preview of the barcode that was generated automatically. By clicking on a color cell of the barcode, you can manually select a color with an eyedropper and so on with each segment. To save the result, you must click the “Export” button for a single image or the “Export All” button for the entire queue.

The application offers several algorithms to extract colors.
 - Area Average. Finds the dominant colors of an image by using using a area average algorithm.
 - Dominant Color. Finds the dominant colors of an image by iterating, grouping and sorting pixels using a [color difference formula](https://en.wikipedia.org/wiki/Color_difference).
 - Means Clustering. Finds the dominant colors of an image by using using a k-means clustering algorithm.
   
<img width="619" alt="Algorithm" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/c729283c-5b04-465a-92e2-16b5696742a0">

It is also possible to exclude white and black colors.

<img width="620" alt="Flags" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/fee9093a-3346-4504-8087-a3be0ca74da1">

### Result image barcode

![Blade Runner 2049 00 45 00 Strip](https://github.com/DenDmitriev/GrabShot/assets/65191747/568f1184-0173-4d42-9fd1-e852ed85d672)


## Settings
The operation of the application can be configured. The launch of the window for this lies in an intuitive place - in the upper panel of the system by clicking on the name of the program or by command ⌘ + ,. 

<img width="301" alt="settings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/9f9b9aea-61a8-4c0b-828b-6a3cdd742e94">

Or button on toolbar 

<img width="184" alt="SettingButton" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/dffcd2cb-0a36-4f83-b685-e7aeee302145">

The settings window is divided into two tabs.

### Capture Settings
There is a slider to select the compression ratio of JPG images. And the switch for opening the folder with the resulting images at the end of the capture process.

<img width="786" alt="GrabSettings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/8343f0d1-7094-40ad-acb8-7e6a847616c1">


### Barcode Settings
The barcode is needed for different tasks and what it should be should be determined by the user. The average color or colors are determined on each frame, their number can be selected. The resolution of the final image may need to be large or small, so there are margins for the size in pixels.
The barcode settings for an image consist of the height of the resulting pattern and the number of middle pattern colors.

<img width="786" alt="StripSettings" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/96930db1-15db-4e5b-8c28-59f4e0ca7f97">

<img width="145" alt="Colors" src="https://github.com/DenDmitriev/GrabShot/assets/65191747/11ed2a66-ecb8-48d5-8616-0c563c68bef9">

# Support
The support by email – [dv.denstr@gmail.com](mailto:dv.denstr@gmail.com).

# License
This software uses code of [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html), compiled with a wrapper [FFmpegKit](https://github.com/arthenica/ffmpeg-kit).

