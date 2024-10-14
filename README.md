# EMMET: Point. Explore. Build.

**A Mobile Application for LEGO® Education Using Rebrickable and YOLOv5 Object Detection Model**
<img src="https://github.com/RobsRoby/emmet/blob/main/assets/images/img_logo.png" alt="logo" width="200">

## Overview

**EMMET** is an innovative mobile application designed to enhance the educational experience with LEGO® blocks. By utilizing the **Rebrickable API** and the **YOLOv5 Object Detection Model**, EMMET allows users to identify LEGO® pieces in real-time through their device’s camera. This app provides an interactive and fun learning experience for users, helping them identify, catalog, and learn more about various LEGO® elements.

This project showcases the integration of AI and computer vision techniques into a mobile application, offering a powerful tool for both education and LEGO® enthusiasts.

## Features

- **Real-Time Object Detection**: Identify LEGO® parts using the YOLOv5 Object Detection Model directly through your camera.
- **Rebrickable Integration**: Fetch detailed LEGO® part information using the Rebrickable API.
- **Catalog and Learn**: Organize and catalog identified LEGO® elements to enhance your learning.
- **Engaging and Educational**: Developed with educational purposes in mind, helping users learn about LEGO® while having fun.

## APK Download

You can download the latest APK from [here](https://github.com/RobsRoby/emmet/releases/download/apk/emmet.apk).

## YOLOv5 Model Evaluations

EMMET uses the YOLOv5 model for real-time object detection. Below is the performance evaluation of various YOLOv5 variants tested in Tensor/TFLite-FP16 with **Patience 50**:

|  Model  |  IOU | mAP@0.5 | mAP@0.5:0.95 | Precision | Recall |  FPS  | Epochs Stopped |
|:-------:|:----:|:-------:|:------------:|:---------:|:------:|:-----:|:--------------:|
| yolov5n | 0.96 |   0.04  |     0.04     |    0.10   |  0.04  | 84.70 |       188      |
| yolov5s | 0.97 |   0.14  |     0.12     |    0.27   |  0.10  | 44.60 |       199      |
| yolov5m | 0.97 |   0.07  |     0.06     |    0.20   |  0.05  | 19.90 |       199      |
| yolov5l | 0.97 |   0.09  |     0.07     |    0.22   |  0.06  | 11.47 |       199      |
| yolov5x | 0.97 |   0.08  |     0.07     |    0.22   |  0.05  |  6.73 |       199      |

## Technologies Used

- **Flutter** for cross-platform mobile development.
- **YOLOv5** for real-time object detection.
- **Rebrickable API** for LEGO® parts data.
- **TensorFlow Lite** for optimized performance on mobile devices.

## How to Install

1. Download the APK from the [release page](https://github.com/RobsRoby/emmet/releases/download/apk/emmet.apk).
2. Install the APK on your Android device.
3. Open the app and start identifying LEGO® elements!

---
